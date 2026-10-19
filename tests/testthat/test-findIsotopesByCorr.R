require(testthat)
require(Cardinal)

context("findIsotopesByCorr")

# simulate isotope envelopes (M+0, M+1, M+2) sharing an image
simulateIsotopes <- function(mono, height = c(10, 8, 6),
	nrun = 1L, charge = 1L, ...)
{
	step <- 1.0033548 / charge
	coord <- expand.grid(x=1:16, y=1:16)
	pdata <- lapply(seq_len(nrun), function(r)
		PositionDataFrame(coord=coord, run=paste0("run", r)))
	pdata <- do.call(rbind, pdata)
	mz <- as.vector(outer(c(0, step, 2 * step), mono, "+"))
	mol <- rep(seq_along(mono), each=3L)
	o <- order(mz)
	fdata <- MassDataFrame(mz=mz[o], mol=mol[o],
		order=rep(0:2, length(mono))[o])
	for ( k in seq_along(mono) ) {
		nm <- paste0("s", k)
		pdata <- addShape(pdata, center=runif(2, 4, 13),
			size=runif(1, 3, 5), name=nm)
		fdata[[nm]] <- ifelse(fdata$mol == k, height[fdata$order + 1L], 0)
	}
	simulateImage(pdata, fdata, resolution=5000, by=100,
		centroided=TRUE, ...)
}

test_that("findIsotopesByCorr", {

	set.seed(1, kind="L'Ecuyer-CMRG")
	mono <- c(1012.2, 1118.3, 1240.4, 1241.9, 1377.5, 1503.6)
	x <- simulateIsotopes(mono, nrun=2L)
	fdata <- metadata(x)$design$featureData

	iso <- findIsotopesByCorr(x, tolerance=10)
	pairs <- metadata(iso)$pairs

	expect_is(iso, "DataFrame")
	expect_equal(nrow(iso), nrow(x))
	expect_equal(iso$i, seq_len(nrow(x)))
	expect_equal(iso$mz, mz(x))
	expect_setequal(names(metadata(iso)),
		c("pairs", "decoys", "runScores", "params"))
	expect_equal(iso$isotope, fdata$order)
	expect_equal(iso$group, match(fdata$mol, unique(fdata$mol)))
	expect_true(all(iso$size == 3L))
	m <- monoisotopes(iso)
	expect_equal(m$i, which(fdata$order == 0L))
	expect_equal(nrow(x[m$i,]), length(mono))
	expect_error(monoisotopes(pairs))

	# decoys are far enough away and distinct for each candidate pair
	decoys <- metadata(iso)$decoys
	minGap <- metadata(iso)$params$minGap
	expect_true(all(abs(mz(x)[decoys$j] - mz(x)[decoys$i]) > minGap))
	once <- decoys$i %in% which(tabulate(pairs$i, nrow(x)) == 1L)
	expect_false(anyDuplicated(decoys[once,c("i", "j")]) > 0L)
	expect_lt(nrow(decoys), 100L * nrow(pairs))
	expect_false(is.unsorted(rev(pairs$decoyRate[order(pairs$score)])))
	expect_true(all(pairs$decoyRate > 0))
	expect_true(all(pairs$status %in%
		c("accepted", "redundant", "ratio", "decoy_rate")))
	linked <- pairs[pairs$status %in% c("accepted", "redundant"),]
	best <- vapply(seq_len(nrow(iso)), function(f)
		max(linked$score[linked$i == f | linked$j == f]), numeric(1L))
	expect_equal(iso$score, best)

	# per-run scores match Pearson correlation
	p <- pairs[1L,]
	r1 <- run(x) == "run1"
	y <- as.matrix(spectra(x))
	expect_equal(unname(metadata(iso)$runScores[1L,"run1"]),
		cor(y[p$i,r1], y[p$j,r1]))

	# scores are the same for different chunks
	set.seed(1, kind="L'Ecuyer-CMRG")
	iso1 <- findIsotopesByCorr(x, tolerance=10, chunkopts=list(nchunks=1L))
	set.seed(1, kind="L'Ecuyer-CMRG")
	iso2 <- findIsotopesByCorr(x, tolerance=10, chunkopts=list(nchunks=7L))
	expect_equal(metadata(iso1)$decoys, metadata(iso2)$decoys)
	expect_equal(iso1, iso2)

	# scores are the same for sparse spectra
	xs <- x
	spectra(xs) <- matter::sparse_mat(as.matrix(spectra(x)))
	set.seed(1, kind="L'Ecuyer-CMRG")
	iso3 <- findIsotopesByCorr(xs, tolerance=10, chunkopts=list(nchunks=7L))
	expect_equal(iso1, iso3)

	# features missing from runs
	iso4 <- findIsotopesByCorr(x[,run(x) == "run1"], tolerance=10)
	expect_equal(colnames(metadata(iso4)$runScores), "run1")
	expect_true(all(metadata(iso4)$pairs$nruns <= 1L))
	expect_warning(iso5 <- findIsotopesByCorr(x, tolerance=10, minRuns=3L))
	expect_true(all(metadata(iso5)$pairs$status == "not_evaluable"))
	expect_true(all(iso5$isotope == 0L))

	# a group can't exceed maxGroupOrder
	iso6 <- findIsotopesByCorr(x, tolerance=10, maxOrder=1L, maxGroupOrder=1L)
	expect_true(any(metadata(iso6)$pairs$status == "span"))
	expect_true(all(iso6$size <= 2L))

	# unknown centroiding and extra arguments
	y <- x
	centroided(y) <- NA
	expect_no_error(findIsotopesByCorr(y, tolerance=10))
	expect_no_error(findIsotopesByCorr(x, tolerance=10, nchunks=4L))

	# decoy rates match a direct calculation
	s <- c(0.95, 0.9, 0.85, 0.8, 0.3, 0.2)
	d <- c(0.82, 0.25, rep(0.1, 10))
	r <- Cardinal:::.decoy_rates(s, d)
	# rate = (decoys >= s + 1) * (6 / 12) / (targets >= s)
	rate <- c(1/1, 1/2, 1/3, 2/4, 2/5, 3/6) * 0.5
	expect_equal(r, rev(cummin(rev(rate))))

})

test_that("findIsotopesByCorr - charge", {

	set.seed(1, kind="L'Ecuyer-CMRG")
	mono <- c(1012.2, 1118.3, 1240.4, 1377.5, 1503.6)
	x <- simulateIsotopes(mono, charge=2L)
	fdata <- metadata(x)$design$featureData

	iso <- findIsotopesByCorr(x, tolerance=10, charge=2L)
	expect_equal(iso$isotope, fdata$order)

	iso2 <- suppressWarnings(findIsotopesByCorr(x, tolerance=10, charge=1L))
	expect_true(all(iso2$size < 3L))

})

test_that("findIsotopesByCorr - order conflict", {

	set.seed(1, kind="L'Ecuyer-CMRG")
	# PC 34:2 [M+H]+ envelope with PC 34:1 [M+H]+ near its M+2
	mono <- c(412.2, 518.3, 640.4, 758.5694, 903.6)
	x <- simulateIsotopes(mono)
	pdata <- pixelData(x)
	fdata <- as.data.frame(metadata(x)$design$featureData)
	fdata <- rbind(fdata, data.frame(mz=760.5851, mol=6L, order=0L,
		s1=0, s2=0, s3=0, s4=8, s5=0))
	fdata <- fdata[order(fdata$mz),]
	fdata <- MassDataFrame(mz=fdata$mz, fdata[-1L])
	x <- simulateImage(pdata, fdata, resolution=5000, by=100,
		centroided=TRUE)

	iso <- findIsotopesByCorr(x, tolerance=30, ratioBound=NA)
	pairs <- metadata(iso)$pairs
	pc341 <- which(fdata$mol == 6L)

	expect_equal(iso$isotope, fdata$order)
	expect_true(any(pairs$j == pc341 & pairs$status == "order_conflict"))

	# PC 34:1 is too intense to be the M+2 of PC 34:2
	iso2 <- findIsotopesByCorr(x, tolerance=30)
	pairs2 <- metadata(iso2)$pairs
	expect_true(any(pairs2$j == pc341 & pairs2$status == "ratio"))
	expect_equal(iso2$isotope[pc341], 0L)

	# a pair rejected by the ratio bound can't join through another pair
	g <- Cardinal:::.merge_isotopes(3L, i=c(2L, 1L), j=c(3L, 3L),
		order=c(1L, 2L), score=c(0.9, 0.8), resid=c(0, 0),
		maxGroupOrder=6L, ri=1L, rj=2L)
	expect_equal(g$status, c("accepted", "ratio_conflict"))
	expect_equal(g$order, c(0L, 0L, 1L))

})

test_that("findIsotopesByCorr - tolerance and errors", {

	set.seed(1, kind="L'Ecuyer-CMRG")
	mono <- c(1012.2, 1118.3, 1240.4, 1377.5, 1503.6)
	x <- simulateIsotopes(mono)

	iso <- findIsotopesByCorr(x, tolerance=10)
	expect_equal(metadata(iso)$params$units, "ppm")
	iso2 <- findIsotopesByCorr(x, tolerance=c(mz=0.005))
	expect_equal(metadata(iso2)$params$units, "mz")

	expect_error(findIsotopesByCorr(x))
	expect_error(findIsotopesByCorr(x, tolerance=0.6, units="mz"))
	expect_error(findIsotopesByCorr(x, tolerance=10, charge=1.5))
	expect_error(findIsotopesByCorr(x, tolerance=10, maxOrder=7L))
	expect_error(findIsotopesByCorr(x, tolerance=10, ndecoy=0L))
	expect_error(findIsotopesByCorr(x, tolerance=10, ratioBound=0))
	expect_error(findIsotopesByCorr(x, tolerance=c(5, 10)))
	expect_error(findIsotopesByCorr(x, tolerance=NA))
	expect_error(findIsotopesByCorr(x, tolerance=10, decoyRate=NA))
	expect_error(findIsotopesByCorr(x, tolerance=10, charge=5L)) # no candidates
	expect_error(findIsotopesByCorr(x, tolerance=10, minPixels=1000L))

	# nothing passes when isotopes are not colocalized
	y <- x
	k <- metadata(x)$design$featureData$order > 0L
	spectra(y)[k,] <- t(apply(spectra(y)[k,], 1L, sample))
	expect_warning(iso3 <- findIsotopesByCorr(y, tolerance=10))
	expect_true(all(iso3$isotope == 0L))
	expect_true(all(metadata(iso3)$pairs$status == "decoy_rate"))

	centroided(x) <- FALSE
	expect_error(findIsotopesByCorr(x, tolerance=10))

})
