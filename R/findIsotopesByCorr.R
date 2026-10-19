
#### Find isotopes by correlation ####
## ------------------------------------

setMethod("findIsotopesByCorr", "MSImagingExperiment",
	function(object, tolerance, units = c("ppm", "mz"),
		charge = 1L, maxOrder = 3L, maxGroupOrder = 6L,
		ratioBound = 2, decoyRate = 0.05, ndecoy = 100L,
		minRuns = 1L, minPixels = 20L,
		verbose = getCardinalVerbose(), chunkopts = list(),
		BPPARAM = getCardinalBPPARAM(), ...)
{
	if ( missing(units) && !missing(tolerance) )
		units <- get_units_from_names(tolerance, units)
	units <- match.arg(units)
	if ( isFALSE(centroided(object)) )
		.Error("spectra must be centroided; use peakProcess() first")
	if ( length(processingData(object)) > 0L )
		.Warn("queued processing steps will be ignored")
	if ( length(tolerance) != 1L || !isTRUE(tolerance > 0) )
		.Error("'tolerance' must be a single positive number")
	if ( charge < 1 || charge %% 1 != 0 )
		.Error("'charge' must be a positive integer")
	if ( maxOrder < 1 || maxGroupOrder < maxOrder )
		.Error("'maxOrder' must be at least 1 and at most 'maxGroupOrder'")
	if ( !is.na(ratioBound) && ratioBound <= 0 )
		.Error("'ratioBound' must be positive or NA")
	if ( !isTRUE(decoyRate > 0 && decoyRate < 1) )
		.Error("'decoyRate' must be between 0 and 1")
	if ( ndecoy < 1 )
		.Error("'ndecoy' must be at least 1")
	mz <- mz(object)
	if ( length(mz) < 2L || is.unsorted(mz, strictly=TRUE) )
		.Error("m/z values must be unique and sorted")
	step <- 1.0033548 / charge
	tol <- switch(units,
		ppm=1e-6 * tolerance * mz,
		mz=rep_len(tolerance, length(mz)))
	if ( max(tol) >= 0.5 * step )
		.Error("tolerance must be less than half the isotope spacing")
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
	# score each distinct pair once
	key <- paste(i, j)
	u <- !duplicated(key)
	cors <- .isotope_cor(object, i[u], j[u], minPixels,
		verbose=verbose, chunkopts=chunkopts, BPPARAM=BPPARAM)
	k <- match(key, key[u])
	runScores <- cors$scores[k,,drop=FALSE]
	nruns <- rowSums(!is.na(runScores))
	score <- rep.int(NA_real_, length(i))
	ok <- nruns >= max(1L, minRuns)
	score[ok] <- apply(runScores[ok,,drop=FALSE], 1L, median, na.rm=TRUE)
	targets$score <- score[seq_len(nt)]
	targets$nruns <- nruns[seq_len(nt)]
	decoys$score <- score[-seq_len(nt)]
	decoys$nruns <- nruns[-seq_len(nt)]
	# intensity ratios and their all-carbon upper bound (13C only)
	lambda <- 0.0107 / 0.9893 * floor(charge * targets$mz.i / 12)
	targets$ratio <- apply(cors$slopes[k[seq_len(nt)],,drop=FALSE], 1L,
		median, na.rm=TRUE)
	targets$bound <- lambda^targets$order / factorial(targets$order)
	# estimate decoy rates and group isotopes
	targets$decoyRate <- .decoy_rates(targets$score, decoys$score)
	pass <- !is.na(targets$decoyRate) & targets$decoyRate <= decoyRate
	targets$status <- ifelse(is.na(targets$score), "not_evaluable", "decoy_rate")
	high <- logical(nt)
	if ( !is.na(ratioBound) ) {
		high <- pass & !is.na(targets$ratio) &
			targets$ratio > ratioBound * targets$bound
		targets$status[high] <- "ratio"
		pass <- pass & !high
	}
	if ( !any(pass) )
		.Warn("no isotope pairs pass decoyRate = ", decoyRate)
	groups <- .merge_isotopes(length(mz), targets$i[pass], targets$j[pass],
		targets$order[pass], targets$score[pass], targets$ppm[pass],
		maxGroupOrder, targets$i[high], targets$j[high])
	targets$status[pass] <- groups$status
	.Log("found ", sum(groups$status == "accepted"), " isotope links ",
		"at decoyRate = ", decoyRate, message=verbose)
	# build results
	group <- as.integer(factor(groups$root))
	scores <- data.frame(group=group, isotope=groups$order,
		size=tabulate(group)[group], score=NA_real_, decoyRate=NA_real_)
	linked <- targets$status %in% c("accepted", "redundant")
	linked <- targets[linked,,drop=FALSE]
	linked <- linked[order(linked$score, decreasing=TRUE),,drop=FALSE]
	k <- as.vector(rbind(linked$i, linked$j))
	best <- !duplicated(k)
	scores$score[k[best]] <- rep(linked$score, each=2L)[best]
	scores$decoyRate[k[best]] <- rep(linked$decoyRate, each=2L)[best]
	ans <- .rank_featureData(object, scores, "none")
	params <- list(tolerance=tolerance, units=units, charge=charge,
		maxOrder=maxOrder, maxGroupOrder=maxGroupOrder,
		ratioBound=ratioBound, decoyRate=decoyRate, ndecoy=ndecoy, minGap=minGap,
		minRuns=minRuns, minPixels=minPixels)
	metadata(ans) <- list(pairs=targets, decoys=decoys,
		runScores=runScores[seq_len(nt),,drop=FALSE], params=params)
	ans
})

# keep the lightest feature in each isotope group
monoisotopes <- function(object)
{
	if ( !all(c("i", "isotope") %in% names(object)) )
		.Error("'object' must be the result of findIsotopesByCorr()")
	object[object$isotope == 0L,,drop=FALSE]
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
		data.frame(i=i, j=j, mz.i=mz[i], mz.j=mz[j],
			order=rep.int(k, length(i)))
	})
	ans <- do.call(rbind, ans)
	ans$ppm <- 1e6 * ((ans$mz.j - ans$mz.i) - ans$order * step) / ans$mz.i
	ans
}

# pair each anchor with up to n distinct partners more than minGap away
.decoy_pairs <- function(i, mz, minGap, n)
{
	# partners are features 1..lo and hi+1..length(mz)
	lo <- findInterval(mz[i] - minGap, mz, left.open=TRUE)
	hi <- findInterval(mz[i] + minGap, mz)
	m <- lo + length(mz) - hi
	j <- lapply(seq_along(i), function(a) {
		u <- sample.int(m[a], min(n, m[a]))
		ifelse(u <= lo[a], u, u + hi[a] - lo[a])
	})
	data.frame(i=rep.int(i, lengths(j)), j=as.integer(unlist(j)))
}

# Pearson correlation of pairs (i, j) within each run
.isotope_cor <- function(object, i, j, minPixels,
	verbose, chunkopts, BPPARAM)
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
		verbose=verbose, chunkopts=chunkopts, BPPARAM=BPPARAM)
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

# decoy rates (decoys pooled over repetitions)
.decoy_rates <- function(target, decoy)
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
# or both features of a pair rejected by the ratio bound (ri, rj)
.merge_isotopes <- function(n, i, j, order, score, resid, maxGroupOrder,
	ri = integer(), rj = integer())
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
		} else if ( any(ri %in% m & rj %in% m) ) {
			status[e] <- "ratio_conflict"
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

