
#### Find isotopes ####
## --------------------

setMethod("findIsotopes", "MSImagingExperiment",
	function(object, tolerance, units = c("ppm", "mz"),
		charge = 1L, spacing = 1.0033548, maxOrder = 3L, maxGroupOrder = 6L,
		ratioBound = 2, fdr = 0.05, ndecoy = 100L,
		runAgg = c("median", "min", "mean"),
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
	if ( maxOrder < 1 || maxGroupOrder < maxOrder )
		.Error("'maxOrder' must be at least 1 and at most 'maxGroupOrder'")
	if ( !is.na(ratioBound) && ratioBound <= 0 )
		.Error("'ratioBound' must be positive or NA")
	if ( fdr <= 0 || fdr >= 1 )
		.Error("'fdr' must be between 0 and 1")
	if ( ndecoy < 1 )
		.Error("'ndecoy' must be at least 1")
	mz <- mz(object)
	if ( length(mz) < 2L || is.unsorted(mz, strictly=TRUE) )
		.Error("m/z values must be unique and sorted")
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
	minGap <- maxGroupOrder * step + 2 * max(tol)
	decoys <- .decoy_pairs(targets$i, mz, minGap, ndecoy)
	.Log("scoring ", nrow(targets), " candidate isotope pairs ",
		"and ", nrow(decoys), " decoy pairs", message=verbose)
	# score pairs by colocalization within runs
	nt <- nrow(targets)
	i <- c(targets$i, decoys$i)
	j <- c(targets$j, decoys$j)
	cors <- .isotope_cor(object, i, j, minPixels,
		verbose=verbose, chunkopts=chunkopts, BPPARAM=BPPARAM, ...)
	runScores <- cors$scores
	nRuns <- rowSums(!is.na(runScores))
	score <- rep.int(NA_real_, length(i))
	ok <- nRuns >= max(1L, minRuns)
	FUN <- match.fun(runAgg)
	score[ok] <- apply(runScores[ok,,drop=FALSE], 1L, FUN, na.rm=TRUE)
	targets$score <- score[seq_len(nt)]
	targets$nRuns <- nRuns[seq_len(nt)]
	decoys$score <- score[-seq_len(nt)]
	decoys$nRuns <- nRuns[-seq_len(nt)]
	# intensity ratios and their all-carbon upper bound (13C only)
	lambda <- 0.0107 * floor(charge * targets$mz_i / 12)
	targets$ratio <- apply(cors$slopes[seq_len(nt),,drop=FALSE], 1L,
		median, na.rm=TRUE)
	targets$ratioMax <- lambda^targets$order / factorial(targets$order)
	# estimate q-values and group isotopes
	targets$q <- .isotope_qvalues(targets$score, decoys$score)
	pass <- !is.na(targets$q) & targets$q <= fdr
	targets$status <- ifelse(is.na(targets$score), "not_evaluable", "fdr")
	if ( !is.na(ratioBound) ) {
		high <- pass & !is.na(targets$ratio) &
			targets$ratio > ratioBound * targets$ratioMax
		targets$status[high] <- "ratio"
		pass <- pass & !high
	}
	if ( !any(pass) )
		.Warn("no isotope pairs pass fdr = ", fdr)
	groups <- .merge_isotopes(length(mz), targets$i[pass], targets$j[pass],
		targets$order[pass], targets$score[pass], targets$residPpm[pass],
		maxGroupOrder)
	targets$status[pass] <- groups$status
	.Log("found ", sum(groups$status == "accepted"), " isotope links ",
		"at fdr = ", fdr, message=verbose)
	# build results
	group <- as.integer(factor(groups$root))
	ans <- MassDataFrame(mz=mz,
		isotopeGroup=group,
		isotopeOrder=groups$order,
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
		ratioBound=ratioBound, fdr=fdr, ndecoy=ndecoy, minGap=minGap,
		runAgg=runAgg, minRuns=minRuns, minPixels=minPixels)
	metadata(ans) <- list(pairs=targets, decoys=decoys,
		runScores=runScores[seq_len(nt),,drop=FALSE], params=params)
	ans
})

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
	# correlations and slopes of j on i
	cors <- sp / sqrt(ss[i,,drop=FALSE] * ss[j,,drop=FALSE])
	slopes <- sp / ss[i,,drop=FALSE]
	cors[!is.finite(cors)] <- NA_real_
	slopes[!is.finite(cors)] <- NA_real_
	npixels <- table(run)
	dimnames(cors) <- dimnames(slopes) <- list(NULL, levels(run))
	list(scores=cors[,npixels >= minPixels,drop=FALSE],
		slopes=slopes[,npixels >= minPixels,drop=FALSE])
}

# target-decoy q-values (decoys pooled over repetitions)
.isotope_qvalues <- function(target, decoy)
{
	q <- rep.int(NA_real_, length(target))
	s <- target[!is.na(target)]
	d <- sort(decoy[!is.na(decoy)])
	if ( length(s) == 0L || length(d) == 0L )
		return(q)
	ntarget <- length(s) - findInterval(s, sort(s), left.open=TRUE)
	# add one decoy and scale to the number of scored targets
	ndecoy <- (length(d) - findInterval(s, d, left.open=TRUE) + 1) *
		length(s) / length(d)
	o <- order(s, decreasing=TRUE)
	qs <- numeric(length(s))
	qs[o] <- rev(cummin(rev((ndecoy / ntarget)[o])))
	q[!is.na(target)] <- pmin(qs, 1)
	q
}

# merge pairs into groups (strongest first) without order conflicts
.merge_isotopes <- function(n, i, j, order, score, resid, maxGroupOrder)
{
	parent <- seq_len(n)
	members <- as.list(parent)
	# isotope orders summed along links
	k <- integer(n)
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
			# a loop must have consistent orders
			status[e] <- if ( k[j[e]] - k[i[e]] == order[e] )
				"redundant" else "order_conflict"
			next
		}
		m <- c(members[[a]], members[[b]])
		km <- c(k[members[[a]]],
			k[members[[b]]] + k[i[e]] + order[e] - k[j[e]])
		km <- km - min(km)
		if ( anyDuplicated(km) ) {
			status[e] <- "order_conflict"
		} else if ( max(km) > maxGroupOrder ) {
			status[e] <- "span"
		} else {
			parent[max(a, b)] <- min(a, b)
			members[[min(a, b)]] <- m
			k[m] <- km
			status[e] <- "accepted"
		}
	}
	list(root=vapply(seq_len(n), root, integer(1L)),
		order=as.integer(k), status=status)
}

