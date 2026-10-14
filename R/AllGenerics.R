
#### Generics from stats ####
## --------------------------
setGeneric("predict")
setGeneric("fitted")

#### Basic getters and setters ####
## ---------------------------------
setGeneric("keys", function(object, ...) standardGeneric("keys"))
setGeneric("keys<-", function(object, ..., value) standardGeneric("keys<-"))
setGeneric("dropkeys", function(object, ...) standardGeneric("dropkeys"))
setGeneric("features", function(object, ...) standardGeneric("features"))
setGeneric("pixels", function(object, ...) standardGeneric("pixels"))
setGeneric("pixelData", function(object) standardGeneric("pixelData"))
setGeneric("pixelData<-", function(object, value) standardGeneric("pixelData<-"))
setGeneric("pixelNames", function(object) standardGeneric("pixelNames"))
setGeneric("pixelNames<-", function(object, value) standardGeneric("pixelNames<-"))
setGeneric("coord", function(object, ...) standardGeneric("coord"))
setGeneric("coord<-", function(object, ..., value) standardGeneric("coord<-"))
setGeneric("coordNames", function(object) standardGeneric("coordNames"))
setGeneric("coordNames<-", function(object, value) standardGeneric("coordNames<-"))
setGeneric("run", function(object, ...) standardGeneric("run"))
setGeneric("run<-", function(object, ..., value) standardGeneric("run<-"))
setGeneric("runNames", function(object) standardGeneric("runNames"))
setGeneric("runNames<-", function(object, value) standardGeneric("runNames<-"))
setGeneric("resultData", function(object, ...) standardGeneric("resultData"))
setGeneric("resultData<-", function(object, ..., value) standardGeneric("resultData<-"))
setGeneric("resultNames", function(object, ...) standardGeneric("resultNames"))
setGeneric("resultNames<-", function(object, ..., value) standardGeneric("resultNames<-"))
setGeneric("modelData", function(object, ...) standardGeneric("modelData"))
setGeneric("modelData<-", function(object, ..., value) standardGeneric("modelData<-"))

#### Pre-processing ####
## ---------------------
setGeneric("process", function(object, ...) standardGeneric("process"))
setGeneric("smoothSignal", function(object, ...) standardGeneric("smoothSignal"))
setGeneric("reduceBaseline", function(object, ...) standardGeneric("reduceBaseline"))
setGeneric("recalibrate", function(object, ...) standardGeneric("recalibrate"))
setGeneric("peakPick", function(object, ...) standardGeneric("peakPick"))
setGeneric("peakAlign", function(object, ...) standardGeneric("peakAlign"))
setGeneric("peakProcess", function(object, ...) standardGeneric("peakProcess"))

#### Co-registration and co-localization ####
## ------------------------------------------
setGeneric("coregister", function(object, ref, ...) standardGeneric("coregister"))
setGeneric("colocalized", function(object, ...) standardGeneric("colocalized"))
setGeneric("groupIsotopes", function(object, ...) standardGeneric("groupIsotopes"))

#### Spatial utilities ####
## ---------------------
setGeneric("findNeighbors", function(x, ...) standardGeneric("findNeighbors"))
setGeneric("spatialWeights", function(x, ...) standardGeneric("spatialWeights"))
setGeneric("spatialDists", function(x, y, ...) standardGeneric("spatialDists"))

#### Statistical analysis and tools ####
## -------------------------------------
setGeneric("topFeatures", function(object, ...) standardGeneric("topFeatures"))
setGeneric("NMF", function(x, ...) standardGeneric("NMF"))
setGeneric("PCA", function(x, ...) standardGeneric("PCA"))
setGeneric("PLS", function(x, y, ...) standardGeneric("PLS"))
setGeneric("OPLS", function(x, y, ...) standardGeneric("OPLS"))
setGeneric("spatialFastmap", function(x, ...) standardGeneric("spatialFastmap"))
setGeneric("spatialKMeans", function(x, ...) standardGeneric("spatialKMeans"))
setGeneric("spatialShrunkenCentroids", function(x, y, ...) standardGeneric("spatialShrunkenCentroids"))
setGeneric("spatialDGMM", function(x, ...) standardGeneric("spatialDGMM"))
setGeneric("meansTest", function(x, ...) standardGeneric("meansTest"))

#### Plotting ####
## ---------------
setGeneric("selectROI", function(object, ...) standardGeneric("selectROI"))
setGeneric("image3D", function(x, ...) standardGeneric("image3D"))
setGeneric("is3D", function(object) standardGeneric("is3D"))

#### Deprecated ####
## ------------------

# getters and setters
setGeneric("iData", function(x, i, ...) standardGeneric("iData"))
setGeneric("iData<-", function(x, i, ..., value) standardGeneric("iData<-"))
setMethod("iData", "ANY", function(x, i, ...) {
		.Defunct("spectra")
	})
setReplaceMethod("iData", "ANY", function(x, i, ..., value) {
		.Defunct("spectra")
	})

# preprocessing
setGeneric("mzAlign", function(object, ref, ...) standardGeneric("mzAlign"))
setMethod("mzAlign", c("ANY", "ANY"), function(object, ref, ...) {
		.Defunct("recalibrate")
	})
setGeneric("mzBin", function(object, ref, ...) standardGeneric("mzBin"))
setMethod("mzAlign", c("ANY", "ANY"), function(object, ref, ...) {
		.Defunct("bin")
	})
setGeneric("mzFilter", function(object, ...) standardGeneric("mzFilter"))
setMethod("mzFilter", "ANY", function(object, ref, ...) {
		.Defunct("subsetFeatures")
	})
setGeneric("peakBin", function(object, ref, ...) standardGeneric("peakBin"))
setMethod("peakBin", c("ANY", "ANY"), function(object, ref, ...) {
		.Defunct("bin")
	})
setGeneric("peakFilter", function(object, ...) standardGeneric("peakFilter"))
setMethod("mzFilter", "ANY", function(object, ref, ...) {
		.Defunct("subsetFeatures")
	})

# apply
setGeneric("featureApply", function(.object, .fun, ...) standardGeneric("featureApply"))
setMethod("featureApply", "ANY", function(.object, .fun, ...) {
		.Defunct()
	})
setGeneric("pixelApply", function(.object, .fun, ...) standardGeneric("pixelApply"))
setMethod("pixelApply", "ANY", function(.object, .fun, ...) {
		.Defunct()
	})
setGeneric("spatialApply", function(.object, .r, .fun, ...) standardGeneric("spatialApply"))
setMethod("spatialApply", "ANY", function(.object, .r, .fun, ...) {
		.Defunct()
	})
