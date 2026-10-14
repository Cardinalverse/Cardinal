require(testthat)
require(Cardinal)

context("findIsotopes")

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

test_that("findIsotopes", {

	set.seed(1, kind="L'Ecuyer-CMRG")
	mono <- c(1012.2, 1118.3, 1240.4, 1241.9, 1377.5, 1503.6)
	x <- simulateIsotopes(mono, nrun=2L)
	fdata <- metadata(x)$design$featureData

	iso <- findIsotopes(x, tolerance=10)
	pairs <- metadata(iso)$pairs

	expect_is(iso, "MassDataFrame")
	expect_equal(nrow(iso), nrow(x))
	expect_equal(mz(iso), mz(x))
	expect_setequal(names(metadata(iso)),
		c("pairs", "decoys", "runScores", "params"))
	expect_equal(iso$isotopeOrder, fdata$order)
	expect_equal(iso$isotopeGroup, as.integer(factor(fdata$mol, unique(fdata$mol))))
	expect_true(all(iso$groupSize == 3L))
	expect_equal(nrow(x[iso$isotopeOrder == 0L,]), length(mono))
	expect_false(is.unsorted(rev(pairs$q[order(pairs$score)])))
	expect_true(all(pairs$q > 0))
	expect_true(all(pairs$status %in% c("accepted", "redundant", "ratio", "fdr")))
	linked <- pairs[pairs$status %in% c("accepted", "redundant"),]
	best <- vapply(seq_len(nrow(iso)), function(f)
		max(linked$score[linked$i == f | linked$j == f]), numeric(1L))
	expect_equal(iso$linkScore, best)

	# per-run scores match Pearson correlation
	p <- pairs[1L,]
	r1 <- run(x) == "run1"
	y <- as.matrix(spectra(x))
	expect_equal(unname(metadata(iso)$runScores[1L,"run1"]),
		cor(y[p$i,r1], y[p$j,r1]))

	# scores are the same for different chunks
	set.seed(1, kind="L'Ecuyer-CMRG")
	iso1 <- findIsotopes(x, tolerance=10, chunkopts=list(nchunks=1L))
	set.seed(1, kind="L'Ecuyer-CMRG")
	iso2 <- findIsotopes(x, tolerance=10, chunkopts=list(nchunks=7L))
	expect_equal(metadata(iso1)$decoys, metadata(iso2)$decoys)
	expect_equal(iso1, iso2)

	# scores are the same for sparse spectra
	xs <- x
	spectra(xs) <- matter::sparse_mat(as.matrix(spectra(x)))
	set.seed(1, kind="L'Ecuyer-CMRG")
	iso3 <- findIsotopes(xs, tolerance=10, chunkopts=list(nchunks=7L))
	expect_equal(iso1, iso3)

	# features missing from runs
	iso4 <- findIsotopes(x[,run(x) == "run1"], tolerance=10)
	expect_equal(colnames(metadata(iso4)$runScores), "run1")
	expect_true(all(metadata(iso4)$pairs$nRuns <= 1L))
	expect_warning(iso5 <- findIsotopes(x, tolerance=10, minRuns=3L))
	expect_true(all(metadata(iso5)$pairs$status == "not_evaluable"))
	expect_true(all(iso5$isotopeOrder == 0L))

})

test_that("findIsotopes - charge", {

	set.seed(1, kind="L'Ecuyer-CMRG")
	mono <- c(1012.2, 1118.3, 1240.4, 1377.5, 1503.6)
	x <- simulateIsotopes(mono, charge=2L)
	fdata <- metadata(x)$design$featureData

	iso <- findIsotopes(x, tolerance=10, charge=2L)
	expect_equal(iso$isotopeOrder, fdata$order)

	iso2 <- suppressWarnings(findIsotopes(x, tolerance=10, charge=1L))
	expect_true(all(iso2$groupSize < 3L))

})

test_that("findIsotopes - order conflict", {

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

	iso <- findIsotopes(x, tolerance=30, ratioBound=NA)
	pairs <- metadata(iso)$pairs
	pc341 <- which(fdata$mol == 6L)

	expect_equal(iso$isotopeOrder, fdata$order)
	expect_true(any(pairs$j == pc341 & pairs$status == "order_conflict"))

	# PC 34:1 is too intense to be the M+2 of PC 34:2
	iso2 <- findIsotopes(x, tolerance=30)
	pairs2 <- metadata(iso2)$pairs
	expect_true(any(pairs2$j == pc341 & pairs2$status == "ratio"))
	expect_equal(iso2$isotopeOrder[pc341], 0L)

})

test_that("findIsotopes - tolerance and errors", {

	set.seed(1, kind="L'Ecuyer-CMRG")
	mono <- c(1012.2, 1118.3, 1240.4, 1377.5, 1503.6)
	x <- simulateIsotopes(mono)

	iso <- findIsotopes(x, tolerance=10)
	expect_equal(metadata(iso)$params$units, "ppm")
	iso2 <- findIsotopes(x, tolerance=c(mz=0.005))
	expect_equal(metadata(iso2)$params$units, "mz")

	expect_error(findIsotopes(x))
	expect_error(findIsotopes(x, tolerance=0.6, units="mz"))
	expect_error(findIsotopes(x, tolerance=10, charge=1.5))
	expect_error(findIsotopes(x, tolerance=10, maxOrder=7L))
	expect_error(findIsotopes(x, tolerance=10, ndecoy=0L))
	expect_error(findIsotopes(x, tolerance=10, ratioBound=0))
	expect_error(findIsotopes(x, tolerance=10, spacing=0.3)) # no candidates
	expect_error(findIsotopes(x, tolerance=10, minPixels=1000L))

	# nothing passes when isotopes are not colocalized
	y <- x
	k <- metadata(x)$design$featureData$order > 0L
	spectra(y)[k,] <- t(apply(spectra(y)[k,], 1L, sample))
	expect_warning(iso3 <- findIsotopes(y, tolerance=10))
	expect_true(all(iso3$isotopeOrder == 0L))
	expect_true(all(metadata(iso3)$pairs$status == "fdr"))

	centroided(x) <- FALSE
	expect_error(findIsotopes(x, tolerance=10))

})
