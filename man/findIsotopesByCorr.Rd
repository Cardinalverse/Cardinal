\encoding{UTF-8}

\name{findIsotopesByCorr}

\alias{findIsotopesByCorr}
\alias{findIsotopesByCorr,MSImagingExperiment-method}
\alias{monoisotopes}

\title{Find isotope peaks by correlation}

\description{
    Group mass features into isotope envelopes based on their m/z spacing and image similarity, using decoy pairs to choose a score cutoff.
}

\usage{
\S4method{findIsotopesByCorr}{MSImagingExperiment}(object, tolerance, units = c("ppm", "mz"),
    charge = 1L, maxOrder = 3L, maxGroupOrder = 6L,
    ratioBound = 2, decoyRate = 0.05, ndecoy = 100L,
    minRuns = 1L, minPixels = 20L,
    verbose = getCardinalVerbose(), chunkopts = list(),
    BPPARAM = getCardinalBPPARAM(), \dots)

monoisotopes(object)
}

\arguments{
    \item{object}{A centroided (peak-picked) imaging experiment. For \code{monoisotopes()}, the result of \code{findIsotopesByCorr()}.}

    \item{tolerance}{The tolerance for matching the m/z spacing of an isotope pair. This should be close to the mass accuracy of the data (see Details).}

    \item{units}{The units for the above tolerance.}

    \item{charge}{The charge state (a positive integer for either polarity). The isotopes are spaced 1.0033548 / \code{charge} apart in m/z (13C - 12C).}

    \item{maxOrder}{The largest isotope order k (for M+k) to search for directly. Longer envelopes are still grouped through shorter links.}

    \item{maxGroupOrder}{The largest isotope order allowed in a group.}

    \item{ratioBound}{Pairs whose intensity ratio is more than \code{ratioBound} times the largest ratio possible for 13C isotopes are rejected. Use \code{NA} to keep them (e.g., for ions with chlorine or bromine).}

    \item{decoyRate}{The largest decoy rate for accepting an isotope pair (see Details).}

    \item{ndecoy}{The number of times decoy pairs are sampled. More decoys make the results depend less on the random seed. Scoring time and memory grow roughly in proportion to \code{ndecoy}.}

    \item{minRuns}{The minimum number of runs in which a pair must be scored.}

    \item{minPixels}{Runs with fewer pixels than this are not used.}

    \item{verbose}{Should progress messages be printed?}

    \item{chunkopts}{Chunk processing options. See \code{\link{chunkApply}} for details.}

    \item{BPPARAM}{An optional instance of \code{BiocParallelParam}. See documentation for \code{\link{bplapply}}.}

    \item{\dots}{Ignored.}
}

\details{
    First, candidate isotope pairs are found by matching features that are k * 1.0033548 / \code{charge} apart (for k = 1, ..., \code{maxOrder}) within the \code{tolerance}. Each pair is scored by the Pearson correlation of its ion images, calculated separately within each run and then summarized by the median.

    The score cutoff is chosen using decoys in a target-decoy approach inspired by METASPACE (Palmer et al., 2017). The lighter feature of each candidate pair is paired with a randomly selected feature far enough away that it can't be an isotope, and this is repeated \code{ndecoy} times. As in METASPACE, the decoys from all repetitions are pooled. The decoy rate at a score is the number of decoys with that score or higher, plus one, divided by \code{ndecoy} and by the number of candidate pairs with that score or higher. Adding one avoids a decoy rate of zero when few pairs are accepted. Each pair is assigned the lowest decoy rate at its score or lower, and pairs with decoy rates less than or equal to \code{decoyRate} are accepted. The decoy rate is a guide for choosing a cutoff, not an estimated error rate. If no pairs are accepted, a warning is given and each feature is assigned to its own group.

    The intensity ratio of a pair is the slope of the heavier feature's intensities regressed on the lighter feature's intensities, calculated within each run and summarized by the median. Unlike a ratio of mean intensities, this is not affected by background. Noise in the lighter feature biases the ratio downward, so the limit below is conservative. A 13C isotope can't be more intense than it would be for a molecule made only of carbon, so the ratio of an M+k pair is limited to about lambda^k / k!, where lambda = (0.0107 / 0.9893) * floor(charge * mz / 12). Accepted pairs with ratios more than \code{ratioBound} times this limit are rejected. This often rejects a co-localized species that overlaps an isotope peak, but ions with chlorine, bromine, or many sulfur atoms can exceed it.

    Accepted pairs are merged into groups in order of decreasing score. Isotope orders are summed along the merged pairs. A merge is refused if it would put two features at the same isotope order or extend a group beyond \code{maxGroupOrder}. This prevents a single false pair from joining two envelopes.

    Isotope order 0 is the lightest observed feature in a group, which is not necessarily the monoisotopic peak if that peak was not detected. Use \code{monoisotopes()} to keep the features with order 0, which keeps one feature per group.

    Co-localized species with nearly the same m/z as an isotope can be mistaken for it. For example, two 13C atoms and two hydrogens (one double bond) differ by 0.0089 Da, which is within a 10 ppm tolerance above m/z 894. A tolerance close to the mass accuracy of the data reduces this. The m/z errors of the candidate pairs are given by \code{ppm} in \code{metadata(object)$pairs}, and the accepted pairs can be used to check the tolerance. Weak isotopes with many zero intensities have lower correlations and may be missed. Decoy rates are calculated for pairs, not groups.
}

\value{
    For \code{findIsotopesByCorr()}, a data frame with one row for each feature of \code{object}, in the same order, with columns:

    \itemize{
        \item \code{i}: The feature index.

        \item \code{mz}: The m/z values.

        \item \code{group}: The isotope group, numbered in order of m/z.

        \item \code{isotope}: The isotope order k (for M+k) relative to the lightest feature in the group.

        \item \code{size}: The number of features in the group.

        \item \code{score}, \code{decoyRate}: The score and decoy rate of the best accepted pair involving the feature (or \code{NA} for single features).
    }

    The \code{metadata()} contains the candidate pairs with their m/z errors (\code{ppm}), scores, number of runs scored (\code{nruns}), intensity ratios (\code{ratio}), ratio limits (\code{bound}), decoy rates (\code{decoyRate}), and status (\code{pairs}), the decoy pairs (\code{decoys}), the scores of the candidate pairs in each run (\code{runScores}), and the parameters (\code{params}). The status of a pair is one of \code{"accepted"} (used to merge groups), \code{"redundant"} (both features were already in the same group), \code{"order_conflict"} or \code{"span"} (the merge was refused), \code{"ratio"} (the intensity ratio was too high), \code{"decoy_rate"} (the decoy rate was greater than \code{decoyRate}), or \code{"not_evaluable"} (the pair could not be scored).

    For \code{monoisotopes()}, the rows of \code{object} with isotope order 0.
}

\references{
    Palmer, A., Phapale, P., Chernyavsky, I., et al. (2017). FDR-controlled metabolite annotation for high-resolution imaging mass spectrometry. Nature Methods, 14, 57-60.
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
mono <- c(1012.2, 1240.4, 1503.6)
fdata <- MassDataFrame(mz=as.vector(outer(0:2 * 1.0033548, mono, "+")))

# simulate isotope envelopes (M+0, M+1, M+2) sharing an image
for ( k in seq_along(mono) ) {
    nm <- paste0("m", k)
    pdata <- addShape(pdata, center=runif(2, 4, 13), size=4, name=nm)
    fdata[[nm]] <- ifelse(rep(seq_along(mono), each=3) == k, c(10, 8, 6), 0)
}
mse <- simulateImage(pdata, fdata, resolution=5000, by=100, centroided=TRUE)

# find isotopes and keep one feature per group
iso <- findIsotopesByCorr(mse, tolerance=10)
iso
mono <- monoisotopes(iso)
mse[mono$i,]
}

\keyword{methods}
