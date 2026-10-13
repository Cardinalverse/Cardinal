\encoding{UTF-8}

\name{findIsotopes}

\alias{findIsotopes}
\alias{findIsotopes,MSImagingExperiment-method}

\title{Find isotope groups}

\description{
    Group mass features into isotope envelopes based on their m/z spacing and image similarity, with the false discovery rate (FDR) controlled using decoys.
}

\usage{
\S4method{findIsotopes}{MSImagingExperiment}(object, tolerance = NA, units = c("ppm", "mz"),
    charge = 1L, spacing = 1.0033548, maxOrder = 3L, maxGroupOrder = 6L,
    fdr = 0.05, ndecoy = 20L, runAgg = c("median", "min", "mean"),
    minRuns = 1L, minPixels = 20L,
    verbose = getCardinalVerbose(), chunkopts = list(),
    BPPARAM = getCardinalBPPARAM(), \dots)
}

\arguments{
    \item{object}{A centroided (peak-picked) imaging experiment.}

    \item{tolerance}{The tolerance for matching the m/z spacing of an isotope pair. If \code{NA}, then half the tolerance used by \code{\link{peakAlign}} is used.}

    \item{units}{The units for the above tolerance.}

    \item{charge}{The charge state (a positive integer for either polarity). The isotopes are spaced \code{spacing / charge} apart in m/z.}

    \item{spacing}{The mass difference between isotopes (13C - 12C by default).}

    \item{maxOrder}{The largest isotope order k (for M+k) to search for directly. Longer envelopes are still grouped through shorter links.}

    \item{maxGroupOrder}{The largest isotope order allowed in a group.}

    \item{fdr}{The FDR threshold (q-value) for accepting an isotope pair.}

    \item{ndecoy}{The number of times decoy pairs are sampled.}

    \item{runAgg}{The function used to summarize the image similarity of a pair across runs.}

    \item{minRuns}{The minimum number of runs in which a pair must be scored.}

    \item{minPixels}{Runs with fewer pixels than this are not used.}

    \item{verbose}{Should progress messages be printed?}

    \item{chunkopts}{Chunk processing options. See \code{\link{chunkApply}} for details.}

    \item{BPPARAM}{An optional instance of \code{BiocParallelParam}. See documentation for \code{\link{bplapply}}.}

    \item{\dots}{Options passed to \code{\link[matter]{chunk_colapply}}.}
}

\details{
    First, candidate isotope pairs are found by matching features that are k * \code{spacing / charge} apart (for k = 1, ..., \code{maxOrder}) within the \code{tolerance}. Each pair is scored by the Pearson correlation of its ion images, calculated separately within each run and then summarized by \code{runAgg}.

    The FDR is estimated using decoys in a target-decoy approach inspired by METASPACE (Palmer et al., 2017). The lighter feature of each candidate pair is paired with a randomly selected feature far enough away that it can't be an isotope, and this is repeated \code{ndecoy} times. The FDR at a score is the median number of decoys with that score or higher divided by the number of candidate pairs with that score or higher. Each pair is assigned a q-value (Käll et al., 2008), and pairs with q-values less than or equal to \code{fdr} are accepted. If no pairs are accepted, a warning is given and each feature is assigned to its own group.

    Accepted pairs are merged into groups in order of decreasing score. A merge is refused if it would put two features at the same isotope order or extend a group beyond \code{maxGroupOrder}. This prevents a single false pair from joining two envelopes.

    Isotope order 0 is the lightest observed feature in a group, which is not necessarily the monoisotopic peak if that peak was not detected. Keeping the features with order 0 keeps one feature per group.

    Co-localized species with nearly the same m/z as an isotope can be mistaken for it. For example, two 13C atoms and two hydrogens (one double bond) differ by 0.0089 Da, which is within a 10 ppm tolerance above m/z 894. A tolerance close to the mass accuracy of the data reduces this. Weak isotopes with many zero intensities have lower correlations and may be missed. The FDR is controlled for pairs, not groups.
}

\value{
    A \code{MassDataFrame} with one row for each feature of \code{object}, in the same order, with columns:

    \itemize{
        \item \code{mz}: The m/z values.

        \item \code{isotopeGroup}: The isotope group, numbered in order of m/z.

        \item \code{isotopeOrder}: The isotope order k (for M+k) relative to the lightest feature in the group.

        \item \code{groupSize}: The number of features in the group.

        \item \code{linkScore}, \code{linkQ}: The score and q-value of the best accepted pair involving the feature (or \code{NA} for single features).
    }

    The \code{metadata()} contains the candidate pairs and their status (\code{pairs}), the decoy pairs (\code{decoys}), the scores of the candidate pairs in each run (\code{runScores}), and the parameters (\code{params}).
}

\references{
    Palmer, A., Phapale, P., Chernyavsky, I., et al. (2017). FDR-controlled metabolite annotation for high-resolution imaging mass spectrometry. Nature Methods, 14, 57-60.

    Käll, L., Storey, J. D., MacCoss, M. J., and Noble, W. S. (2008). Assigning significance to peptides identified by tandem mass spectrometry using decoy databases. Journal of Proteome Research, 7, 29-34.
}

\author{
	Ethan Rogers
}

\seealso{
    \code{\link{colocalized}},
    \code{\link{peakProcess}}
}

\examples{
set.seed(1, kind="L'Ecuyer-CMRG")
pdata <- PositionDataFrame(coord=expand.grid(x=1:16, y=1:16))
mono <- c(412.2, 640.4, 903.6)
fdata <- MassDataFrame(mz=as.vector(outer(0:2 * 1.0033548, mono, "+")))

# simulate isotope envelopes (M+0, M+1, M+2) sharing an image
for ( k in seq_along(mono) ) {
    nm <- paste0("m", k)
    pdata <- addShape(pdata, center=runif(2, 4, 13), size=4, name=nm)
    fdata[[nm]] <- ifelse(rep(seq_along(mono), each=3) == k, c(10, 8, 6), 0)
}
mse <- simulateImage(pdata, fdata, resolution=5000, by=100, centroided=TRUE)

# find isotopes and keep one feature per group
iso <- findIsotopes(mse, tolerance=10)
iso
mse[iso$isotopeOrder == 0L,]
}

\keyword{methods}
