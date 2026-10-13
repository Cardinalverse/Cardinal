
#### Find isotopes ####
## --------------------

setMethod("findIsotopes", "MSImagingExperiment",
	function(object, tolerance = NA, units = c("ppm", "mz"),
		charge = 1L, spacing = 1.0033548, maxOrder = 3L, maxGroupOrder = 6L,
		fdr = 0.05, ndecoy = 20L, runAgg = c("median", "min", "mean"),
		minRuns = 1L, minPixels = 20L,
		verbose = getCardinalVerbose(), chunkopts = list(),
		BPPARAM = getCardinalBPPARAM(), ...)
{
	if ( missing(units) && !missing(tolerance) )
		units <- get_units_from_names(tolerance, units)
	units <- match.arg(units)
	runAgg <- match.arg(runAgg)
	if ( !isTRUE(isCentroided(object)) )
		.Error("spectra must be centroided; use peakProcess() first")
	if ( length(processingData(object)) > 0L )
		.Warn("queued processing steps will be ignored")
	if ( charge < 1 || charge %% 1 != 0 )
		.Error("'charge' must be a positive integer")
	if ( fdr <= 0 || fdr >= 1 )
		.Error("'fdr' must be between 0 and 1")
	mz <- mz(object)
	if ( length(mz) < 2L || is.unsorted(mz, strictly=TRUE) )
		.Error("m/z values must be unique and sorted")
	if ( is.na(tolerance) ) {
		# estimate tolerance as half the peak alignment tolerance
		aligned <- .peak_alignment(object)
		if ( is.null(aligned) )
			.Error("can't estimate tolerance without peak alignment; ",
				"please specify 'tolerance'")
		units <- switch(aligned$units,
			relative=, ppm="ppm", absolute=, mz="mz")
		tolerance <- switch(units,
			ppm=0.5 * 1e6 * aligned$tolerance,
			mz=0.5 * aligned$tolerance)
		.Log("estimated ", units, " tolerance of ", tolerance,
			" from peak alignment", message=verbose)
	}
	step <- spacing / charge
	tol <- switch(units,
		ppm=1e-6 * tolerance * mz,
		mz=rep_len(tolerance, length(mz)))
	if ( tolerance <= 0 || max(tol) >= 0.5 * step )
		.Error("tolerance must be positive and less than ",
			"half the isotope spacing")
	if ( mean(diff(mz) <= tol[-1L]) > 0.5 )
		.Warn("many features are closer than the tolerance; ",
			"check that spectra are peak-picked")
	if ( all(table(run(object)) < minPixels) )
		.Error("no runs with at least ", minPixels, " pixels")
	# find target and decoy pairs
	targets <- .isotope_pairs(mz, tol, step, seq_len(maxOrder))
	if ( nrow(targets) == 0L )
		.Error("no candidate isotope pairs; ",
			"check 'tolerance', 'units', and 'charge'")
	minGap <- maxOrder * step + 2 * max(tol)
	decoys <- .decoy_pairs(targets$i, mz, minGap, ndecoy)
	.Log("scoring ", nrow(targets), " candidate isotope pairs ",
		"and ", nrow(decoys), " decoy pairs", message=verbose)
	# score pairs by colocalization within runs
	nt <- nrow(targets)
	i <- c(targets$i, decoys$i)
	j <- c(targets$j, decoys$j)
	runScores <- .isotope_cor(object, i, j, minPixels,
		verbose=verbose, chunkopts=chunkopts, BPPARAM=BPPARAM, ...)
	nRuns <- rowSums(!is.na(runScores))
	score <- rep.int(NA_real_, length(i))
	ok <- nRuns >= max(1L, minRuns)
	FUN <- match.fun(runAgg)
	score[ok] <- apply(runScores[ok,,drop=FALSE], 1L, FUN, na.rm=TRUE)
	targets$score <- score[seq_len(nt)]
	targets$nRuns <- nRuns[seq_len(nt)]
	decoys$score <- score[-seq_len(nt)]
	decoys$nRuns <- nRuns[-seq_len(nt)]
	# estimate q-values and group isotopes
	targets$q <- .isotope_qvalues(targets$score, decoys$score, decoys$rep)
	pass <- !is.na(targets$q) & targets$q <= fdr
	if ( !any(pass) )
		.Warn("no isotope pairs pass fdr = ", fdr)
	targets$status <- ifelse(is.na(targets$score), "not_evaluable", "fdr")
	groups <- .merge_isotopes(mz, targets$i[pass], targets$j[pass],
		targets$score[pass], targets$residPpm[pass], step, maxGroupOrder)
	targets$status[pass] <- groups$status
	.Log("found ", sum(groups$status == "accepted"), " isotope links ",
		"at fdr = ", fdr, message=verbose)
	# build results
	group <- as.integer(factor(groups$root))
	ans <- MassDataFrame(mz=mz,
		isotopeGroup=group,
		isotopeOrder=as.integer(round((mz - mz[groups$root]) / step)),
		groupSize=tabulate(group)[group],
		linkScore=NA_real_, linkQ=NA_real_)
	linked <- targets[targets$status %in% c("accepted", "redundant"),,drop=FALSE]
	linked <- linked[order(linked$score, decreasing=TRUE),,drop=FALSE]
	k <- as.vector(rbind(linked$i, linked$j))
	best <- !duplicated(k)
	ans$linkScore[k[best]] <- rep(linked$score, each=2L)[best]
	ans$linkQ[k[best]] <- rep(linked$q, each=2L)[best]
	params <- list(tolerance=tolerance, units=units, charge=charge,
		spacing=spacing, maxOrder=maxOrder, maxGroupOrder=maxGroupOrder,
		fdr=fdr, ndecoy=ndecoy, minGap=minGap, runAgg=runAgg,
		minRuns=minRuns, minPixels=minPixels)
	metadata(ans) <- list(pairs=targets, decoys=decoys,
		runScores=runScores[seq_len(nt),,drop=FALSE], params=params)
	ans
})

# get the most recent peak alignment parameters
.peak_alignment <- function(object)
{
	steps <- Filter(function(ps) is.list(ps) &&
		"peak alignment" %in% names(ps), metadata(object))
	if ( length(steps) ) {
		steps[[length(steps)]][["peak alignment"]]
	} else {
		NULL
	}
}

# find candidate pairs (i, j) with mz[j] ~ mz[i] + k * step
.isotope_pairs <- function(mz, tol, step, orders)
{
	ans <- lapply(orders, function(k) {
		lo <- findInterval(mz + k * step - tol, mz, left.open=TRUE) + 1L
		hi <- findInterval(mz + k * step + tol, mz)
		n <- pmax(hi - lo + 1L, 0L)
		i <- rep.int(seq_along(mz), n)
		j <- as.integer(unlist(Map(seq.int, lo[n > 0L], hi[n > 0L])))
		data.frame(i=i, j=j, mz_i=mz[i], mz_j=mz[j],
			order=rep.int(k, length(i)))
	})
	ans <- do.call(rbind, ans)
	ans$residPpm <- 1e6 * ((ans$mz_j - ans$mz_i) - ans$order * step) / ans$mz_i
	ans
}

# pair each anchor with random partners more than minGap away
.decoy_pairs <- function(i, mz, minGap, n)
{
	ok <- mz[i] - mz[1L] > minGap | mz[length(mz)] - mz[i] > minGap
	ans <- lapply(seq_len(n), function(r) {
		j <- rep.int(NA_integer_, length(i))
		todo <- ok
		while ( any(todo) ) {
			j[todo] <- sample.int(length(mz), sum(todo), replace=TRUE)
			todo <- ok & abs(mz[j] - mz[i]) <= minGap
		}
		data.frame(rep=rep.int(r, length(i)), i=i, j=j,
			mz_i=mz[i], mz_j=mz[j])
	})
	do.call(rbind, ans)
}

# Pearson correlation of pairs (i, j) within each run
.isotope_cor <- function(object, i, j, minPixels,
	verbose, chunkopts, BPPARAM, ...)
{
	run <- droplevels(run(object))
	means <- rowStats(spectra(object), stat="mean", group=run,
		simplify=FALSE, verbose=verbose,
		chunkopts=chunkopts, BPPARAM=BPPARAM)$mean
	means <- matrix(as.vector(means), ncol=nlevels(run))
	# sums of squares and cross-products about the run means
	FUN <- isofun(function(x, run, means, i, j) {
		g <- run[attr(x, "index")]
		ss <- matrix(0, nrow=nrow(x), ncol=nlevels(run))
		sp <- matrix(0, nrow=length(i), ncol=nlevels(run))
		for ( r in which(levels(run) %in% g) ) {
			y <- x[,g == levels(run)[r],drop=FALSE] - means[,r]
			ss[,r] <- rowSums(y^2)
			# limit size of pair-by-pixel blocks
			b <- max(1L, floor(1e7 / ncol(y)))
			for ( s in seq.int(1L, length(i), by=b) ) {
				e <- s:min(s + b - 1L, length(i))
				sp[e,r] <- rowSums(y[i[e],,drop=FALSE] * y[j[e],,drop=FALSE])
			}
		}
		list(ss=ss, sp=sp)
	}, CardinalEnv())
	ans <- chunk_colapply(spectra(object), FUN,
		run=run, means=means, i=i, j=j, simplify=list,
		verbose=verbose, chunkopts=chunkopts, BPPARAM=BPPARAM, ...)
	ss <- Reduce(`+`, lapply(ans, `[[`, "ss"))
	sp <- Reduce(`+`, lapply(ans, `[[`, "sp"))
	ans <- sp / sqrt(ss[i,,drop=FALSE] * ss[j,,drop=FALSE])
	ans[!is.finite(ans)] <- NA_real_
	npixels <- table(run)
	dimnames(ans) <- list(NULL, levels(run))
	ans[,npixels >= minPixels,drop=FALSE]
}

# target-decoy q-values (median decoy counts over repetitions)
.isotope_qvalues <- function(target, decoy, rep)
{
	q <- rep.int(NA_real_, length(target))
	s <- target[!is.na(target)]
	if ( length(s) == 0L )
		return(q)
	ntarget <- length(s) - findInterval(s, sort(s), left.open=TRUE)
	ndecoy <- vapply(split(decoy, rep), function(d) {
		# scale to the number of scored targets
		d <- sort(d)
		(length(d) - findInterval(s, d, left.open=TRUE)) * length(s) / length(d)
	}, numeric(length(s)))
	ndecoy <- apply(matrix(ndecoy, nrow=length(s)), 1L, median, na.rm=TRUE)
	o <- order(s, decreasing=TRUE)
	qs <- numeric(length(s))
	qs[o] <- rev(cummin(rev((ndecoy / ntarget)[o])))
	q[!is.na(target)] <- pmin(qs, 1)
	q
}

# merge pairs into groups (strongest first) without order conflicts
.merge_isotopes <- function(mz, i, j, score, resid, step, maxGroupOrder)
{
	parent <- seq_along(mz)
	members <- as.list(parent)
	root <- function(a) {
		while ( parent[a] != a )
			a <- parent[a]
		a
	}
	status <- character(length(i))
	for ( e in order(-score, abs(resid)) ) {
		a <- root(i[e])
		b <- root(j[e])
		if ( a == b ) {
			status[e] <- "redundant"
			next
		}
		m <- c(members[[a]], members[[b]])
		k <- round((mz[m] - min(mz[m])) / step)
		if ( anyDuplicated(k) ) {
			status[e] <- "order_conflict"
		} else if ( max(k) > maxGroupOrder ) {
			status[e] <- "span"
		} else {
			parent[max(a, b)] <- min(a, b)
			members[[min(a, b)]] <- m
			status[e] <- "accepted"
		}
	}
	list(root=vapply(seq_along(mz), root, integer(1L)), status=status)
}

