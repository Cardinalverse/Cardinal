
# Cardinal 3.15.0 (2026-10-14)

## New features

* Added 'findIsotopesByCorr()' for grouping isotope peaks by m/z spacing
        and image correlation, with a target-decoy score cutoff

* Added 'monoisotopes()' for keeping one feature per isotope group

# Cardinal 3.13.4 (2026-04-24)

## Major changes

* Converted NEWS to NEWS.md

# Cardinal 3.13.4 (2026-04-22)

## Major changes

* Removed deprecated functions (color palettes, etc.)
* Removed defunct functions (color palettes, etc.)
* Deprecated 'fetch()' and 'flash()'

# Cardinal 3.13.2 (2026-04-22)

## Bug fixes

* Fix 'mass.range' bug in 'convertMSImagingExperiment2Arrays()'

# Cardinal 3.13.1 (2026-03-18)

## Major changes

* Remove dependency on EBImage

# Cardinal 3.12.1 (2026-02-12)

## Bug fixes

* Add na.rm parameter to 'meansTest()'
* Fix spectrumRepresentation logic in 'writeImzML()'
* Rename 'bi' to 'bilateral' in smoothing functions

# Cardinal 3.11.1 (2025-10-14)

## New features

* Added 'contrastTest()' method for post-hoc contrasts on 'MeansTest' objects
* New 'ContrastTest' class for storing contrast analysis results
* Added support for 'use_lmer=TRUE' in 'meansTest()' to use lmerTest::lmer
* Integration with 'emmeans' package for estimated marginal means and contrasts
* Support for various contrast methods: pairwise, trt.vs.ctrl, custom contrasts
* Added 'emm_adjust' parameter for multiple comparison adjustments

## Major changes

* When 'use_lmer=TRUE' in 'meansTest()', likelihood ratio tests are not 
        performed; use 'contrastTest()' for post-hoc comparisons instead
* Suggests 'lmerTest' and 'emmeans' packages for enhanced functionality

# Cardinal 3.8.3 (2024-12-18)

## Bug fixes

* Fix error in 'selectROI()' for whole-experiment images

# Cardinal 3.8.2 (2024-12-11)

## Major changes

* Update 'peakAlign()' with 'binfun' parameter
* Previous (3.6) behavior corresponds to 'binfun="median"'

## Bug fixes

* Fix error in 'peakAlign()' for high resolution peaks
* Set minimum relative alignment resolution of 0.5 ppm
* Set minimum absolute alignment resolution of 0.0001 mz
* Fix 'peakProcess()' not processing centroided 'MSImagingArrays'

# Cardinal 3.8.1 (2024-12-10)

## Bug fixes

* Fix error in 'simulateSpectra()' when 'mz' is unsorted
* Add 'resolution' and 'fmax' to 'simulateImage()'

# Cardinal 3.7.8 (2024-10-26)

## Major changes

* Deprecate 'slice()' in factor of 'sliceImage()'
        to avoid conflicts with users attaching dplyr

# Cardinal 3.7.7 (2024-10-24)

## Major changes

* Update 'peakAlign()' with 'binratio' parameter

# Cardinal 3.7.6 (2024-10-16)

## New features

* Reading/writing imzML now preserves 'metadata' slot
* Reading/writing imzML now supports parallel processing

## Major changes

* Update 'estimateDomain()' to select resolution
        based on 'median', 'min', 'max', or 'mean'
* Update 'peakAlign()' to build domain bins based on
        the minimum of peak gaps (instead of the median)
* Write log file when writing imzML/Analyze files

## Bug fixes

* Fix bug in 'process()' resulting in output matrix
        with 'list' elements under certain conditions

# Cardinal 3.7.5 (2024-09-03)

## New features

* Add 'setCardinalParallel()' for setting a parallelization
        backend with reasonably-selected defaults

## Major changes

* Add 'SAR=FALSE' option to 'simulateImage()' for faster
        simulation if spatial autoregressive model is not needed
* Change default array order for 'MSImagingArrays' so that
        'intensity' is first array and 'mz' is second array
* Improved logging with pre-processing functions

## Bug fixes

* Fix leaky 'meansTest()' closures

# Cardinal 3.7.4 (2024-08-28)

## New features

* Add 'saveCardinalLog()' for saving log file
* Add 'getCardinalLogger()' + 'setCardinalLogger()'
* Add 'fetch()' and 'flash()' methods for moving
        spectra between shared memory and temporary files

## Major changes

* Update compatibility with matter 2.7.6
* Changes to 'simulateSpectra()' and 'simulateImage()'
        in parallelization and spectral noise generation
* RNG in 'simulateSpectra()' and 'simulateImage()'
        now warn if 'RNGkind()' is not "L'Ecuyer-CMRG"

## Bug fixes

* Fix calculation of "adaptive" spatial weights
        in 'spatialWeights()' for accuracy and stability

# Cardinal 3.7.3 (2024-07-29)

## Major changes

* Add 'setCardinalChunksize()' + 'getCardinalChunksize()'
* Update vignettes due to spectral processing updates

## Bug fixes

* Fix plot() and image() not always respecting dimnames
* Fix plot() and image() not plotting multiple columns
* Fix plot() and image() failing for non-syntactic names

# Cardinal 3.7.2 (2024-07-13)

## Bug fixes

* Merge bug fix from 3.6.4.

# Cardinal 3.7.1 (2024-05-18)

## New features

* Update 'spectrapply()' so index array is optional
* Update 'plot()' to support 2 domains (e.g., for ion mobility)
* Add plotting methods for 'XDataFrame' and 'PositionDataFrame'

## Bug fixes

* Fix default 'tolerance' in 'pixels()'

# Cardinal 3.6.6 (2024-08-23)

## Bug fixes

* Fixes for 'simulateImage()' and 'simulateSpectra()'

# Cardinal 3.6.5 (2024-08-09)

## Bug fixes

* Fix 'spatialShrunkenCentroids()' failing when 'r=0'
        or when a pixel has no neighboring pixels

# Cardinal 3.6.4 (2024-07-13)

## Bug fixes

* ## Bug fixes for 'plot()' on spectra with queued processing

# Cardinal 3.6.3 (2024-06-26)

## Bug fixes

* ## Bug fixes for 'meansTest()' when random effects are specified

# Cardinal 3.6.2 (2024-06-10)

## Bug fixes

* Version bump for 'matter' 2.6.2 bugfixes

# Cardinal 3.6.1 (2024-05-17)

## Major changes

* Add 'mass.range' and tolerance' arguments to 'bin()'

## Bug fixes

* Fix 'readImzML' error if imzML fails conversion to 'ImzMeta'

# Cardinal 3.5.6 (2024-04-26)

## Major changes

* Add optional 'run' argument to 'slice()'
* Add optional 'plotly' support for all plotting methods

# Cardinal 3.5.5 (2024-04-25)

## Bug fixes

* Fix bug in 'selectROI()' region plot updates

# Cardinal 3.5.4 (2024-04-24)

## New features

* Re-add support for 3D coordinates and 'image3D()'

## Major changes

* Export 'vizi_style()' and 'vizi_engine()' functions
* Add 'check' argument to 'readMSIData()' for uuid+checksum

## Bug fixes

* Fix bug in plotting PLS/OPLS coefficients
* Fix removing position columns with 'coord()<-'

# Cardinal 3.5.3 (2024-04-13)

## New features

* Add support for multiple instance learning for 'PLS()'
        and 'spatialShrunkenCentroids()' with 'bags' argument
* Add 'estimateReferenceMz()' for more easily estimating
        profile m/z-values from 'MSImagingArrays'

## Bug fixes

* Make sure 'bin()' still respects 'resolution' when 'ref' is
        specified (in which case the range is taken from 'ref')
* Fix 'crossValidate()' for multiple instance learning

# Cardinal 3.5.2 (2024-04-13)

## Bug fixes

* Fix passing 'tolerance' in 'peakProcess()' when not needed
* Fix bugs in 'selectROI()' not updating the plot
* Fix bugs in 'selectROI()' selecting wrong pixels
* Make sure 'peakAlign()' produces similar results when
        re-aligning peaks with the same tolerance

# Cardinal 3.5.1 (2024-04-07)

## New features

* Ground-up rewrite to take advantage of matter v2.5 features
* New class 'SpectraArrays' for arrays of spectra
* New class 'SpectralImagingData' for spectral imaging data
* New class 'SpectralImagingArrays' for raw spectra
* New class 'SpectralImagingExperiment' for centroided spectra
* New class 'MSImagingArrays' for raw mass spectra
* Updated class 'MSImagingExperiment'
* Updated class 'XDataFrame'
* Updated classes 'PositionDataFrame' and 'MassDataFrame'
* New apply method 'spectrapply()'
* New processing method 'recalibrate()'
* New processing method 'bin()'
* New processing method 'peakProcess()'
* New classes 'SpatialResults' and 'ResultsList'
* Updated spatial methods 'findNeighbors()' and 'spatialWeights()'
* Updated spatial methods 'colocalized()'
* Updated projection methods 'PCA()' and 'spatialFastmap()'
* New projection method 'NMF()'
* Updated stats methods 'PLS()' and 'OPLS()'
* Updated stats method 'spatialKMeans()'
* Updated stats method 'spatialShrunkenCentroids()'
* Updated stats method 'spatialDGMM()'
* Improved visualization methods 'plot()' and 'image()'

## Major changes

* Deprecated 'smoothSignal()' -- use 'smooth()'
* Deprecated 'mzBin()' -- use 'bin()'
* Deprecated 'mzAlign()' -- use 'recalibrate()'
* Deprecated 'mzFilter()' -- use 'subsetFeatures()'
* Deprecated 'peakFilter()' -- use 'subsetFeatures()'
* Deprecated 'aggregate()' -- use 'summarizeFeatures()'
* Deprecated 'featureApply()' -- use 'summarizeFeatures()'
* Deprecated 'pixelApply()' -- use 'summarizePixels()'

# Cardinal 3.4.3 (2023-11-22)

## Bug fixes

* Fixed default calculation of reference peaks in 'peakAlign()'

# Cardinal 3.4.2 (2023-11-16)

## Bug fixes

* Fixed error in 'readImzML()' if spectrum representation is missing
* Fixed bug in 'writeImzML()' causing overlapping offsets

# Cardinal 3.4.1 (2023-10-25)

## Bug fixes

* Fixed bug in 'writeImzML()' causing malformed cvParam tag

# Cardinal 3.3.5 (2023-10-19)

## Bug fixes

* Allow 'guess.max=Inf' in 'readImzML()'

# Cardinal 3.3.4 (2023-10-19)

## Major changes

* Bin peaks when importing centroid spectra with 'readImzML()'
* Replaced all functions from deprecated 'sp' package

# Cardinal 3.3.3 (2023-08-08)

## Bug fixes

* Fixed I/O bugs introduced by matter v2.3.13 changes

# Cardinal 3.3.2 (2023-08-05)

## Bug fixes

* Fixed I/O bugs introduced by matter v2.3.11 changes
* Other I/O bugs fixed by matter v2.3.13 changes

# Cardinal 3.3.1 (2023-05-02)

## Bug fixes

* Merged 3.2.1 fixes to resolve R CMD check warnings

# Cardinal 3.2.1 (2023-05-02)

## Bug fixes

* Cleaned up escaped LaTeX specials in documentation
* Fixed 'sprintf()' => 'snprintf()' warning in C code

# Cardinal 3.0.1 (2022-11-14)

## Major changes

* Overwriting existing MSI files is now a warning instead of an error

## Bug fixes

* Fixed issue in 'peakAlign()' reference m/z's being sort and unique

# Cardinal 2.99.1 (2022-10-31)

## Major changes

* Updated vignettes for Cardinal 3
* Widened default m/z 'tolerance' for sparse spectra
* Switched to linear interpolation for sparse spectra

# Cardinal 2.99.0 (2022-10-26)

## Major changes

* Updated out-of-memory backend to Matter 2.0
* Removed support for legacy classes and methods

# Cardinal 2.11.3 (2021-09-15)

## Bug fixes

* Fix strange behavior from random number generation in R >= 4.1.1

# Cardinal 2.11.2 (2021-08-05)

## Bug fixes

* Fix reference naming scheme for binning and alignment methods

# Cardinal 2.11.1 (2021-07-26)

## Bug fixes

* Use as(x, 'DFrame') instead of as(x, 'DataFrame')
* Fix logical length > 1 error in 'segmentationTest()'

# Cardinal 2.7.2 (2020-10-21)

## Major changes

* For 'mzAlign()', the 'ref' parameter now expects a vector
        of reference m/z-values rather than a complete spectrum

# Cardinal 2.7.1 (2020-06-30)

## Bug fixes

* Fixed issue where 'spatialDGMM()' would sometimes
        fail for features with singular segmentations
* Suppressed warnings on 'Mclust()' initialization
        to 'spatialDGMM()' caused by R 4.0 changes
* Fixed pixel/feature mapping in 'spatialDGMM()' metadata

# Cardinal 2.5.12 (2020-04-24)

## Bug fixes

* Drawing a region-of-interest using 'selectROI()' should
        now update the plot properly in RStudio devices
* Fixed issues with automatically guessing a reasonable
        mass tolerance for certain pre-processing methods
* In 'mzBin()', the previous value of 'centroided()'
        from the original dataset is now preserved after binning

# Cardinal 2.5.11 (2020-04-23)

## Bug fixes

* Fixed bug in 'spatialShrunkenCentroids()' that produced
        in NaNs when discriminant scores were very large
* Fixed bug in 'spatialFastmap()' where subsetting produced
        vectors instead of matrices due to omitting 'drop=FALSE'

# Cardinal 2.5.10 (2020-04-22)

## New features

* Added 'topFeatures()' method for 'spatialKMeans()'
* Added coercion to 'DataFrame' from 'MSImagingExperiment'

## Major changes

* Deprecated legacy classes (MSImageSet, etc.):
        class definitions will remain for supporting
        datasets from CardinalWorkflows, but methods
        operating on them will be defunct in BioC 3.12

# Cardinal 2.5.9 (2020-04-22)

## New features

* Added 'aggregate()' method for imaging experiments
        including 'summarizePixels()' and 'summarizeFeatures()'
* Added 'subset()' method for imaging experiments
        including 'subsetPixels()' and 'subsetFeatures()'

## Major changes

* Deprecated 'dplyr' verbs in favor of the above functions;
        this is to remove the (rather large) dependency on
        the tidyverse for a relatively small functionality

## Bug fixes

* Fix bug in 'spatialDGMM()' printing caused by a change in
        default.stringsAsFactors() == FALSE in R 4.0

# Cardinal 2.5.8 (2020-04-18)

## New features

* Automatic estimation of mass resolution will now work
        for 'processed' imzML with centroid spectra
* New getter/setter options for Cardinal options such as
        'getCardinalBPPARAM()' and 'setCardinalBPPARAM()'

## Major changes

* Default BPPARAM backend is now set to 'SerialParam()';
        use 'setCardinalBPPARAM()' to change the backend
* Expose '.view' argument of 'matter::chunk_apply()' in
        'pixelApply()', 'featureApply()', and 'spatialApply()'
* Previously-deprecated functions 'generateSpectrum()'
        and 'generateImage()' are now defunct
* Removed defunct functions 'Binmat()' and 'topLabels()'

## Bug fixes

* Fix large intensity text cutoffs in 'image()' colorkey

# Cardinal 2.5.7 (2020-03-30)

## Bug fixes

* Fix bug when using 'rbind()' or 'cbind()' on
        'MassDataFrame' and 'PositionDataFrame'

# Cardinal 2.5.6 (2020-03-24)

## Bug fixes

* Fix bug when assigning a dense matrix via iData()<-
        for an 'MSProcessedImagingExperiment' object

# Cardinal 2.5.5 (2020-03-14)

## Bug fixes

* Fix bug in 'show' method for 'SimpleImageList'
        caused by class(matrix) -> c("matrix", "array")

# Cardinal 2.5.4 (2020-03-13)

## Bug fixes

* Fix bugs in legacy classes caused by a change in
        default.stringsAsFactors() == FALSE in R 4.0

# Cardinal 2.5.3 (2020-03-13)

## Major changes

* The 'resolution' argument in all methods has been
        redefined to always mean full bin width
        for both "mz" and "ppm" units

# Cardinal 2.5.2 (2020-03-02)

## Major changes

* The 'pixelApply()', 'featureApply()', and 'spatialApply()'
        methods now internally use 'matter::chunk_apply()'

# Cardinal 2.5.1 (2020-01-22)

## Bug fixes

* Fixed bug in 'mzBin()' binning spectra incorrectly
* Fixed bug in contrast enhancement with missing intensities

# Cardinal 2.3.18 (2019-10-27)

## Major changes

* Processing in 'crossValidate()' now allows processing
        unprocessed data by performing peak-picking
        on the mean spectra of the training sets

## Bug fixes

* Fixed some errors in user messages during peak processing

# Cardinal 2.3.17 (2019-10-25)

## Major changes

* Default for 'peakBin()' argument 'type' is now "area"
* In 'peakBin()', peak boundaries should be calculated
        more accurately now, and general speed improvements
* In 'peakAlign()', peak centers are now calculated as
        weighted average mass rather than the highest point

# Cardinal 2.3.16 (2019-10-14)

## New features

* New class 'ImagingSummary' with sub-classes including
        'SparseImagingSummary' and 'MSImagingSummary' with
        appropriate 'plot()' and 'image()' methods

## Major changes

* The 'summarize()' method for 'SparseImagingExperiment'
        now returns a 'SparseImagingSummary', to more closely
        reflect "tidy" data principles by returning an object
        of a similar class; the previous behavior can be
        reproduced by specifying '.as="DataFrame"' 

# Cardinal 2.3.15 (2019-10-13)

## New features

* For methods requiring 'resolution' or 'tolerance',
        the default arguments have been updated to
        automatically guess based on the data

# Cardinal 2.3.14 (2019-05-26)

## New features

* Add spectraData() as an alias for 'imageData()'
        for 'MSImagingExperiment' sub-classes
* Formalize 'mzData()' and 'intensityData()' getters
        and setters for 'MSProcessedImagingExperiment'
* Add 'peaks()' and 'peakData()' methods for extracting
        peak matrices and/or peak information
* Add 'isCentroided()' method for guessing whether spectra
        are centroided (without using the @centroided slot)

## Major changes
    
* Allow 'NA' for @centroided slot for 'MSImagingExperiment'
* 'mzBin()' method now sets centroided = NA
* Update 'mzFilter()' with parameter defaults so that
        'thresh.max = NA' and new arg 'rm.zero = TRUE'
* Log more pre-processing information (e.g., method name)

# Cardinal 2.3.13 (2019-05-23)

## Bug fixes

* Try using 'parent.frame(1)' instead of 'parent.frame(2)'
        to fix NSE methods when used in LHS of a maggritr pipe
* Fix weird 'iData()<-' missing argument 'i' bug

# Cardinal 2.3.12 (2019-05-22)

## Major changes

* Changed default 'peakPick()' method to 'mad'
* In 'peakPick()' method 'mad', change the default
        number of blocks to 1 (no adaptive smoothing)
* In 'peakPick()' method 'mad', update w/ new arguments
        w/ new defaults 'fun=median' and 'tform=diff'

## Bug fixes

* In 'peakPick()' methods 'simple' and 'adaptive', warn
        if kurtosis cannot be estimated and try to recover
* In 'normalize()' method 'reference', provide a warning
        if the reference value is 0 for a pixel

# Cardinal 2.3.11 (2019-05-19)

## Major changes

* Improved speed in 'spatialFastmap()'
* Improved speed in 'spatialShrunkenCentroids()'
* New dissimilarity metrics for 'spatialFastmap()'
        including a new default metric='average'

## Bug fixes

* Fix error in 'print()' for facet plots where lims=NULL

# Cardinal 2.3.10 (2019-05-18)

## Major changes

* Improved speed in 'spatialDGMM()', by moving spatial
        filtering of probabilities to C code, up to 10x faster
* Linesearch in 'spatialDGMM()' now uses 'optimize()'
        rather than 'optim()' -- results may differ slightly

# Cardinal 2.3.9 (2019-05-17)

## New features

* Added 'Cardinal.history()' and 'Cardinal.version()'

## Major changes

* Removed under-used setter generic function definitions

## Bug fixes

* Cleaned up generics to reflect ProtGenerics >= 1.17.2

# Cardinal 2.3.8 (2019-05-16)

## New features

* Added boxplot, histogram, and bar chart functionality
        to the 'plot()' method for 'XDataFrame'
* Added 'plot()' plotting for 'AnnotatedImageList'
* Added 'plot()' methods for 'SpatialDGMM',
        'MeansTest', and 'SegmentationTest' result classes
* Added 'image()' method for 'MeansTest' result class

## Major changes

* Updated 'plot()' and 'image()' methods for 'SpatialDGMM',
        'MeansTest', and 'SegmentationTest' result classes

## Bug fixes

* Various ## Bug fixes in object printing and plot auto-layout

# Cardinal 2.3.7 (2019-05-13)

## New features

* Added 'image()' plotting for 'AnnotatedImageList'

## Bug fixes

* Plotting with 'add=TRUE' now respects 'par('usr')' coordinates

# Cardinal 2.3.6 (2019-05-13)

## New features

* Add 'AnnotatedImageList' class for list of 'AnnotatedImage' objects
* Add 'AnnotatedImagingExperiment' class for containing data for
        an optical imaging experiment (e.g., a microscopy experiments)
* Add 'image()' plotting for 'AnnotatedImagingExperiment'

## Major changes

* Redefine '@featureData' slot of a 'SparseImagingExperiment'
        to be a 'DataFrame' rather than requiring an 'XDataFrame'

## Bug fixes

* Respect 'layout' and 'byrow' passed through ... args
        to 'print()' method on facet plot objects

# Cardinal 2.3.5 (2019-05-11)

## Major changes

* Moved some S4 method definitions from 'ImagingExperiment'
        to 'SparseImagingExperiment' so that the former can be
        more flexible for a wider variety of imaging modalities

## Bug fixes

* Pass more ... args through to 'par()' in plotting functions

# Cardinal 2.3.4 (2019-05-10)

## New features

* Added 'AnnotatedImage' class for optical images

# Cardinal 2.3.3 (2019-05-10)

## Major changes

* Improved facet plotting when 'add=TRUE'

## Bug fixes

* Better 'cex.axis' defaults and user setting for colorkeys

# Cardinal 2.3.2 (2019-05-09)

## Major changes

* Improved 'writeMSIData()' for 3D and non-gridded data

# Cardinal 2.3.1 (2019-05-08)

## New features

* Output directly to imzML while processing with 'process()'

## Major changes

* Improved auto-layout for visualization with multiple runs
* Added 'parse.only' option to 'readImzML()' for parsing only

# Cardinal 2.2.4 (2019-05-08)

## Bug fixes

* Fix large external array offsets in 'writeImzML'

# Cardinal 2.2.3 (2019-05-08)

## Bug fixes

* Cleaned up some 'writeImzML' mapping validity issues

# Cardinal 2.2.2 (2019-05-07)

## Bug fixes

* Removed curly braces around UUID when writing imzML

# Cardinal 2.2.1 (2019-05-06)

## Bug fixes

* Fixed bug in plotting results where 'column' argument
        would get matched before the 'col' argument

# Cardinal 2.1.30 (2019-04-30)

## Bug fixes

* Fixed bug where 'spatialShrunkenCentroids' classification
        would change the user 'options(Cardinal.progress)'

# Cardinal 2.1.29 (2019-04-29)

## Bug fixes

* Coercing to 'SpatialShrunkenCentroids2' now drops
        empty classes for segmentations (as expected)

# Cardinal 2.1.28 (2019-04-28)

## Bug fixes

* Fixed 'topFeatures' method for 'SpatialShrunkenCentroids2'
        where 'statistic' was actually printing the 'centers'
* The 'collect' method for 'MSProcessedImagingExperiment'
        now preserves sparseness when pulling into memory

# Cardinal 2.1.27 (2019-04-26)

## Major changes

* Added 'mzFilter' as an alias for 'peakFilter' with more
        suitable defaults for non-peak-picked spectra

## Bug fixes

* Minor fixes to 'print' method for plots and images
* Minor fixes to margin padding for 'colorkey' in images

# Cardinal 2.1.26 (2019-04-25)

## Bug fixes

* Fixed 'print' method for plots and images to respect
        updating plotting parameters via '...' arguments

# Cardinal 2.1.25 (2019-04-25)

## Major changes

* Add 'run' argument to 'pixels' for 'MSImagingExperiment'
* Add 'run' argument to 'plot' for 'MSImagingExperiment'

## Bug fixes

* Fixed bug in 'ylab' with one-sided formulas in 'plot'
* Relaxed errors for out-of-range m/z values in 'features'
* Value range of 'colorkey' now obeys 'zlim' argument
* NULL values for plot limits no longer give errors

# Cardinal 2.1.24 (2019-04-24)

## Major changes

* Documented new 'options(Cardinal.dark=FALSE)' default

## Bug fixes

* Fixed linear subsetting of models using '['' for
        'SparseImagingResult' objects
* Check length of 'classControl' in 'segmentationTest'

# Cardinal 2.1.23 (2019-04-24)

## New features

* Added 'slice' for slicing imaging datasets (as a data cube)
* Added 'alpha.power' argument for 'image' methods

## Major changes

* Added documentation for options() under '?Cardinal'

# Cardinal 2.1.22 (2019-04-24)

## New features

* Added new 'Cardinal 2: Statistical methods' vignette

# Cardinal 2.1.21 (2019-04-23)

## New features

* Added 'image3D' methods for new classes

# Cardinal 2.1.20 (2019-04-23)

## Major changes

* Updated documentation and simulation examples

## Bug fixes

* Fixed bug in 'summary' for 'SpatialShrunkenCentroids2'

# Cardinal 2.1.19 (2019-04-23)

## New features

* Added 'colocalized' method for colocalization

# Cardinal 2.1.19 (2019-04-23)

## New features

* Added 'colocalized' method for colocalization

# Cardinal 2.1.18 (2019-04-23)

## Major changes

* Updated 'Cardinal 2: User guide' vignette

## Bug fixes

* Fixed bug in 'simulateSpectrum' when n > 1

# Cardinal 2.1.17 (2019-04-22)

## New features

* Added 'topFeatures' method for extracting top-ranked
        features from statistical analyses
* Added 'summary' methods for new results objects
* Added 'SummaryDataFrame' for printing result summaries

## Major changes

* Deprecated 'topLabels' method -> use 'topFeatures'

# Cardinal 2.1.16 (2019-04-20)

## New features

* Added dplyr verbs for 'DataFrame' and "XDataFrame'

# Cardinal 2.1.15 (2019-04-19)

## New features

* Added new 'PCA' method for 'SparseImagingExperiment'
* Added new 'PLS' method for 'SparseImagingExperiment'
* Added new 'OPLS' method for 'SparseImagingExperiment'

## Major changes

* The 'selectROI' method will now use the last plot
        if no additional plotting arguments are given
* Setting 'resolution' on 'MSProcessedImagingExperiment'
        will now update the m/z values binning scheme
* The 'select' and 'filter' methods now using integers
        as row/col IDs without the '.id' argument

## Bug fixes

* Fixed bug in 'OPLS' methods causing cross-validation 
        to produce slightly optimistic results

# Cardinal 2.1.14 (2019-04-18)

## New features

* New 'mzAlign' processing method for spectral alignment
* New 'mzBin' processing method for spectral binning
* New 'crossValidate' method that cleans up 'cvApply' output
* New normalization methods: 'rms' and 'reference'
* New baseline reduction method: 'locmin'
* New peak picking method: 'mad'
* New 'darkmode' and 'lightmode' plotting options
* Added 'cvApply' methods for new classes

## Major changes

* Image plotting now uses different 'colorkey' legend
        placed beside plot that no longer obscures the image
* All plotting now uses different 'strip' labels
        placed above plot that no longer obscures the plot area
* All plotting now accept hidden 'dark=TRUE' argument to
        switch to plotting in new "dark mode"
* Changed/updated presets for 'presetImageDef' which
        provides presets for 'simulateImage' function

# Cardinal 2.1.13 (2019-04-15)

## Major changes

* Added message when printing a 'SparseImagingExperiment'
        object without un-applied pre-processing steps

## Bug fixes

* Added C routine registration with "C_" prefix for .Call
* Cleaned up '.o' objects in /src created by accident

# Cardinal 2.1.12 (2019-04-14)

## New features

* Added 'meansTest' method for linear model-based
        hypothesis tests of mean-summarized images
* Added 'segmentationTest' method for linear model-based
        hypothesis tests of spatially-segmented images

# Cardinal 2.1.11 (2019-04-12)

## Major changes

* Added option to set the probability regularization
        parameter (p0) to 'spatialDGMM' method
* Added option to initialize 'spatialDGMM' algorithm
        with either k-means or Gaussian mixture model

# Cardinal 2.1.10 (2019-04-12)

## Major changes

* Changed default colorscale for images to 'viridis'
* Updated 'simulateImage' presets to handle multiple runs

# Cardinal 2.1.9 (2019-04-11)

## New features

* Added 'spatialDGMM' method for fitting feature-wise
        spatially-aware Dirichlet Gaussian mixture models
* Added 'predict' method for 'SpatialShrunkenCentroids2'

## Bug fixes

* Fixed 'spatialShrunkenCentroids' classification methods
        for new ('SparseImagingExperiment'-based) classes
* Cleaned up unit tests for statistical methods

# Cardinal 2.1.8 (2019-04-01)

## Bug fixes

* Updated 'PositionDataFrame' initialization
        due to change in S4Vectors [<-,DataFrame behavior
* Updated 'MassDataFrame' initialization due to change
        in S4Vectors [<-,DataFrame behavior

# Cardinal 2.1.7 (2019-02-21)

## Bug fixes

* Updated 'filter' signature due to dplyr changes

# Cardinal 2.1.6 (2019-01-04)

## Major changes

* Added ImmunoOncology biocViews term

# Cardinal 2.1.5 (2018-12-14)

## Bug fixes

* Updated read/write methods for 'matter' filemode changes

# Cardinal 2.1.4 (2018-12-12)

## Major changes

* In 'readImzML' and 'readAnalyze', changed defaults
        from 'attach.only=FALSE' to 'attach.only=TRUE'
* In 'readImzML' and 'readAnalyze', changed defaults
        from 'as=MSImageSet' to 'as=MSImagingExperiment'

## Bug fixes

* Subsetting large 'SparseImagingExperiment' objects
        with 'sparse_mat' imageData should no longer hang

# Cardinal 2.1.3 (2018-12-12)

## New features

* Added 'ImagingResult' class for results
        of statistical analyses of imaging experiments
* Added 'spatialFastmap' method for 'SparseImagingExperiment'
* Updated 'summarize' to accept a '.group_by' argument
* Added 'simulateSpectrum' and 'simulateImage' functions

## Major changes

* Automatically detect and setup 'layout' for new classes
* Using 'layout' now assumes (row, column) order
        when creating facet plots for new classes (only)
* Updated examples in documentation to use new classes

## Bug fixes

* Fixed bug in 'spatialKMeans' that caused 'spatialFastmap'
        to fail for datasets with fewer features than components
* Fixed bug where 'plot' did not facet over runs
        of a 'SparseImagingExperiment' when using 'plusminus'

# Cardinal 2.1.2 (2018-11-30)

## Major changes

* Updated 'spatialKMeans' to use new 'spatialFastmap'
* Updated 'spatialShrunkenCentroids' to use new
        spatially-aware discriminant scores calculation

# Cardinal 2.1.1 (2018-11-30)

## New features

* Added 'spatialFastmap' method for performing
        spatially-aware FastMap projection more easily

# Cardinal 2.0.2 (2018-11-30)

## Bug fixes

* Fixed bug in 'reduceDimension.peaks' that caused
        peak intensities to be binned incorrectly

# Cardinal 2.0.1 (2018-11-14)

## Major changes

* Updated 'peakFilter' to check for freq.min >= 1 to
        accomodate old behavior (counts)

# Cardinal 1.99.2 (2018-10-28)

## Major changes

* Updated vignettes for Cardinal 2.0

## Bug fixes

* Removed a unit test broken on Windows

# Cardinal 1.99.1 (2018-10-26)

## New features

* Added vignettes and documentation for Cardinal 2.0

# Cardinal 1.99.0 (2018-10-25)

## Major changes

* Version bump for Cardinal v2 release candidate

# Cardinal 1.13.3 (2018-10-24)

## New features

* Added 'process' method for queueing delayed processing
        functions to an imaging dataset and applying them
* Added new processing methods for Cardinal v2 including 
        new versions of 'normalize', 'smoothSignal', 'reduceBaseline',
        'peakPick', 'peakAlign', and 'peakFilter'
* Added new 'peakBin' function for binning peaks
* Updated 'show' method for new Cardinal v2 classes
* New support for exporting 'processed' imzML files
        via the 'writeImzML' function

# Cardinal 1.13.2 (2018-07-22)

## New features

* Added new classes for Cardinal v2 including 'XDataFrame',
        'PositionDataFrame', 'MassDataFrame', 'ImagingExperiment', 'SparseImagingExperiment', and 'MSImagingExperiment'

# Cardinal 1.13.1 (2018-07-22)

## Major changes

* Updated installation instructions for "CardinalWorkflows"

# Cardinal 1.12.1 (2018-07-22)

## Bug fixes

* Fixed bug in reading Analyze 7.5 files

# Cardinal 1.11.2 (2017-12-02)

## New features

* Added 'writeMSIData', 'writeImzML', and 'writeAnalyze'
        methods for writing MSI data to supported file formats
* Added support for on-disk 'processed' imzML (via argument
        'attach.only' in 'readImzML' method)

## Major changes

* Package 'matter' is used for all file I/O now
* Switched from using 'Hashmat' to using 'sparse_mat'
        class from 'matter' for 'processed' imzML data

## Bug fixes

* Changed compiler settings for parsing XML so reading
        large imzML files should use much less memory now
        (but may take slightly longer for smaller files)

# Cardinal 1.11.1 (2017-10-25)

## Major changes

* Use 'drop=NULL' from now on instead of 'drop=NA' to do
        endomorphic subsetting of 'SimageData' objects

## Bug fixes

* Use 'keys' and 'keys<-' generic from 'matter'

# Cardinal 1.9.2 (2017-10-25)

## Bug fixes

* Corrected author name in all documentation

# Cardinal 1.9.1 (2017-10-23)

## Bug fixes

* Fixed bug in package dependency 'matter' affecting the size
        of datasets that can be processed with 'batchProcess'
* Fixed bug where bin sizes for units='ppm' were twice as wide
        as they should be in 'readImzML' and 'reduceDimension'

# Cardinal 1.7.2 (2017-03-22)

## Major changes

* In 'image' method, 'superpose = TRUE' now supports multiple LHS
        arguments in the formula (e.g., formula = a + b ~ x * y)

# Cardinal 1.7.1 (2016-11-29)

## New features

* PCA is now supported for larger-than-memory on-disk datasets
* External 'matter' matrices replace 'Binmat' matrices for on-disk support
* Added 'image3D' aliases for all 'ResultSet' subclasses

## Major changes

* Added 'matter' package to Depends list

# Cardinal 1.5.2 (2016-10-06)

## Major changes

* Updated 'batchProcess' to support reduceDimension and peakAlign
* Now 'peakAlign' looks for an existing 'mean' column in featureData
* Added 'matter' support to readAnalyze (previously only readImzML)

## Bug fixes

* Fixed bug when indexing into data cube using 'imageData' method

# Cardinal 1.5.1 (2016-09-21)

## Bug fixes

* Corrected author and maintainer contact information

# Cardinal 1.5.0 (2016-05-25)

## New features

* Added experimental support for 'matter' on-disk matrices, from
        package 'matter', hosted at https://github.com/kuwisdelu/matter,
        as a replacement for 'Binmat' matrices

## Bug fixes

* Fixed subsetting SImageData objects with variables

# Cardinal 1.3.3 (2016-04-20)

## Bug fixes

* Subsetting the S4 part of Binmat objects by row is now an error
* Providing non-positive m/z values to 'readImzML' is now an error
* Elements of 'imageData' that fail to 'combine' or which
        are missing from one or more of the objects are now
        dropped from the result with warning rather than failing
* Moved unit tests in 'ints/tests' to 'tests/testthat'

# Cardinal 1.3.2 (2016-03-29)

## New features

* Added 'image3D' method for plotting 3D images
* Added 'batchProcess' method for batch pre-processing

# Cardinal 1.3.1 (2016-03-14)

## Major changes

* Added 'mass.accuracy' and 'units.accuracy' arguments for
        controlling the m/z accuracy when reading 'processed' imzML
* Function 'reduceDimension.bin' now takes argument 'units' with
        value 'ppm' or 'mz', and new corresponding defaults

## Bug fixes

* Fixed bug in reading 'processed' imzML format that caused
        mass spectra to be reconstructed in the wrong order
* Improved speed accessing columns of Hashmat sparse matrices
* In 'pixelApply' and 'featureApply', zero-length return values
        are no longer returned as a list when '.simplify=FALSE'
* Function 'peakAlign.diff' should be more memory efficient now

# Cardinal 1.3.0 (2015-12-16)

## New features

* Added experimental Binmat class for working with on-disk matrices
* Added experimental support for 3D files from benchmark datasets
* Added experimental support for plotting 3D images
* Added experimental support for 'processed' imzML format

## Major changes

* Added 'attach.only' argument to readImzML and readAnalyze

## Bug fixes

* Fixed bug in plotting 3D image slices in the z dimension
* Fixed bug where large imzML files could not be read due to byte
        offsets being stored as ints; they are now stored as doubles.
* Fixed bug with strip labels in 3D plotting and with mixed labels
* Fixed bug with unique m/z feature names for high mass resolutions

# Cardinal 1.1.0 (2015-10-01)

## Bug fixes

* Fixed bug in formatting m/z labels affecting R 3.2.2
* Removed dependency on 'fields' because 'maps' is broken on Windows

# Cardinal 0.99.6 (2015-04-05)

## Major changes

* Bioconductor Release Candidate 7
* Added CITATION file for citing Cardinal

## Bug fixes

* In 'readAnalyze' and 'readMSIData', removed endianness check
      in Analyze 7.5 headers because some ABSciex data files
      specify an incorrect header size, thereby fixing a bug where
      bits would be swapped wrongly and file read incorrectly.

# Cardinal 0.99.5 (2015-03-03)-

## Major changes

* Bioconductor Release Candidate 6
* Added new vignette for Cardinal design and development
* Now using ProtGenerics generics for 'spectra', 'peaks', and 'mz'

# Cardinal 0.99.4 (2015-02-15)--

## Major changes

* Bioconductor Release Candidate 5
* Updated vignette with biological examples
* Added new citations to vignette

# Cardinal 0.99.3 (2015-02-03)-

## Major changes


* Bioconductor Release Candidate 4
* In plot and image methods, 'groups' arg now coerced to factor

## Bug fixes

* Fixed bug in subset arg in select method
* Fixed bug in plot and image methods with NA in 'groups' arg

# Cardinal 0.99.2 (2015-01-20)--

## Major changes


* Bioconductor Release Candidate 3
* Adjusts NIPALS unit tests for Windows build

# Cardinal 0.99.1 (2015-01-12)--

## Major changes

* Bioconductor Release Candidate 2
* Cleaned up biocViews

## Bug fixes

* Fixed bug in SImageData coord factor levels not being
      properly updated when SImageSet is subsetted


# Cardinal 0.99.0 (2014-12-22)---

## Major changes

* Bioconductor Release Candidate 1

# Cardinal 0.9.0 (2014-12-22)--

## Major changes

* Added standardizeSamples method for between-sample normalization

# Cardinal 0.8.9 (2014-12-05)-

## Major changes

* Improved plot methods for object summaries
* Fixed minor issurs in walkthrough vignette

# Cardinal 0.8.8 (2014-11-27)--

## Major changes

* Changed modelData for ResultSet from facors to original parameters
* Added plot method for summaries of ResultSet objects
* Added 'normalize.image' argument for image method
* Improved plot and image methods for CrossValidated

# Cardinal 0.8.7 (2014-11-23)--

## Major changes

* Completed Cardinal-walkthrough vignette

## Bug fixes

* Fixed bug in plotting vectors from ResultSet
* Fixed bug in PCA summary in reporting explained variance

# Cardinal 0.8.6 (2014-11-21)

## Major changes

* Completed walkthrough vignettes
* Added ImagingMassSpectrometry biocView

# Cardinal 0.8.5 (2014-11-20)--

## Major changes

* Added 'show' and 'print' methods for most objects
* Changed 'combine' method for IAnnotatedDataFame, SImageData, and SImageSet
* Completed .Rd documentation for all public methods
* Cleaned up R CMD check warnings (except C++ .hpp headers)

## Bug fixes

* Fixed bug in between-cluster SS calculation for spatialKMeans
* Fixed bug with pre-processing 1-pixel datasets


# Cardinal 0.8.4 (2014-10-16)--

## Major changes

* Changed 'topIons' to 'topLabels' method for summarization
* Added MSImageData class for peakData and mzData methods
* Changed naming scheme for SImageData (.iData => iData)

## Bug fixes

* Fixed bug in plotting of classes for SpatialShrunkenCentroids
* Fixed bug in fopen in readAnalyze and readImzML affecting Windows

# Cardinal 0.8.3 (2014-09-18)-

## Major changes

* Added 'coregistration' for SpatialKMeans
* Added 'summary' methods for all ResultSet subclasses
* Added 'topIons' method for summarization
* Added plotting methods for 'ResultSet' classes
* Added 'cvApply' method for cross-validation
* Added additional statistics to SpatialKmeans class results
* Changed 'auto.key' argument to 'key' in plotting methods

## Bug fixes

* Fixed bug in spatialShrunkenCentroids with prior probabilties
* Fixed bug in OPLS with proper scaling of data matrices during prediction


# Cardinal 0.8.2 (2014-07-23)-

## Major changes


* Added 'peakFilter' method
* Minor fixes to documentation

# Cardinal 0.8.1 (2014-07-10)-

## Major changes

* Changed 'parameters' argument to 'model' for ResultSet plot and image
* Added 'auto.key' to plot and image for when 'groups' are specified
* Added strip labels to plot and image when using base graphics
* Added 'coregister' method for 'SpatialShrunkenCentroids'
* Method 'image' is now vectorized for argument 'mz'
* Method 'plot' is now vectorized for argument 'coord'

## Bug fixes

* Fixed a bug where conditions are plotted in an incorrect order

# Cardinal 0.8.0 (2014-06-16)-

## Major changes

* First public beta available for ASMS 2014.

# Cardinal 0.7 (2014-06-02)

## Major changes

* Refactored version of the package prepared for internal testing.
* New processing methods, renamed to 'normalize', 'smoothSignal',
    	'reduceBaseline', 'peakPick', 'peakAlign', 'reduceDimension'.
* New function 'readMSIData' for reading supported formats.
* Native support for imzML added (no longer requires Java).
* Methods 'pixels' and 'features' replaced with updated versions.
* In 'features' method, m/z matching now done using bisection search.
* New analysis method, renamed to spatialShrunkenCentroids.
* Analysis methods now return a new class: 'ResultSet'.
* New method 'select' to replace 'selectROI' and 'selectPixels'.

# Cardinal 0.6 (2013-02-19)

## Major changes

* Major revision to use Bioconductor base packages.
* New dependencies on BiocGenerics and Biobase.
* New virtual class iSet for generic imaging data.
* New classes ImageSet, SImageSet, ImageData, and SImageData.
* Revised MSImageSet that uses new parent classes.
* New class MIAPE-Imaging for Minimum Information About
    	a Protemics Experiment - Imaging.
* New class MSImageProcess for pre-processing information.
* Revised functions for importing Analyze 7.5 and imzML
* New plotting and image methods using lattice-style formula interface.
* New pixelApply and featureApply methods.

# Cardinal 0.5 (2013-11-08)

## Major changes

* Added image coregistration for 3D sections.
* Added 'volume' method for 3D visualization.

# Cardinal 0.4 (2013-11-07)

## Major changes

* Added 'summaryPlot' method for segmentation visualization.
* Exposed 'calibrateSegmentation' method to calibrate colors
    	between multiple MSImageSegmentation objects.
* Added more thorough verbose output for 'spatialSparseCluster'
    	and 'spatialSparseKMeans' methods.
* Improved behavior of 'intensities' method when reconstructing
    	complex datacubes and with non-contiguous pixel requests.
* Changed 'trellisImage' to plot all coordinates for dimensions
    	omitted from 'fixCoord' by default.
* Minor changes to the 'MSImageSegmentation' class structure.
* Improved 'likPlot' method and added AIC and BIC results and
    	the resulting number of classes.

# Cardinal 0.3 (2013-07-05)

## Major changes

* Improved speed of imaging processing (smoothing and interpolation)
    	methods for use with 'image' and 'trellisImage'.
* Added option for verbose output and hooks for GUI progress bars.
* For prediction on 'MSImageSegmentation' objects, 'autoDimNames'
    	is now automatically passed along from the original call.
* Changed 'MSImageSegmentation' to an S4 class derived from 'list'.
* Added option for plotting the probabilities of an 'MSImageSegmentation'
    	using overlaid transparency masks for improved visualization.

# Cardinal 0.2 (2013-06-20)

## Major changes

* Package renamed from internal code-name "Canary" to "Cardinal".
* Split off GUI to a new package called "CardinaliView".
* New GUI in "CardinaliView" now based on gWidgets and RGtk2.
* Added slot 'peaks' to 'MSImageSet' class.
* Changed 'MSPeakFrame' and 'MSPeakList' to S4 classes, and added
    	new class 'MSPeak Alignment'.
* Changed how the 'estimateNoise' method estimates noise.
* Changed options in the 'detectPeaks' method to be more useful.
* Changed the 'alignPeaks' methods to align to the mean spectrum
    	as a reference when aligning a list of peaks.
* Added 'interpolate' option for images.
* Added new method "selectPeaks" for manual peak selection.
* Modified the 'type' arguments in the plotting methods.
* Changed 'crossValidate' method to now return predictions for the
    	full dataset for every fold instead of the test set only.

## Bug fixes

* Fixed bug where plotting mass spectra for multiple pixels fails
      on datasets with missing mass spectra.
* Fixed bug where the 'unload' method did not remove the object.
* Fixed bug in the 'crossValidate' method where the dots arguments
      were not passed to the 'predict' method.

# Cardinal 0.1 (2013-06-06)

## Major changes

* First internal release for Stanford Canary Center for Cancer
    	Early Detection as primary beta testers.
* Implementation of MSImageSet S4 class; mass spectra are stored as a
    	flat matrix with rows as features and columns as pixels; original
    	data cube can be reconstructed dynamically using a position array;
    	spectra stored using environments to prevent redundant data copying.
* Visualization that includes plotting ion images and mass spectra,
    	using both base graphics and lattice graphics, allowing trellis
    	display of multiple ion images and multipe mass spectra.
* Pre-processing for that includes normalization, baseline correct,
    	peak-picking, peak-alignment, resampling, and binning.
* Multivaritate statistical analysis includes PCA, PLS, and OPLS.
* Supervised analysis includes a spatially-aware version of nearest
    	shrunken centroids, PLS-DA, and OPLS-DA.
* Unsupervised analysis includes spatially-aware clustering based on
    	nearest shrunken centroids, and an implementation based on sparse
    	k-means.
* GUI based on tcltk using rpanel that supports all major
    	processing and statistical analysis methods in the package,
    	except for PLS and OPLS.

