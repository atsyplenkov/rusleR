#' \eqn{LS_{2D}}
#'
#' @description This function calculates an LS-factor from WATEM/SEDEM
#' model as described in \emph{Batista et al.} (2022).
#'
#' @param .dem SpatRaster. A single layer with elevation values. Values should have the same unit as the map units, or in meters when the crs is longitude/latitude
#' @param .weights SpatRaster.
#' @param .threshold Numeric. A value specifying a flow threshold in meters. Default is 120 m
#' @param saga_obj SAGA-GIS geoprocessor object from \code{\link[Rsagacmd]{saga_gis}} with \code{raster_backend = "terra"}
#'
#' @return SpatRaster
#'
#' @references Batista, P. V. G., Fiener, P., Scheper, S., and Alewell, C.: Data and code for: A conceptual model-based sediment connectivity assessment for patchy agricultural catchments, Zenodo, https://doi.org/10.5281/zenodo.6560226, 2022.
#'
#' @import terra
#' @import Rsagacmd
#'
#' @export
ls_2d <-
  function(
    .dem,
    .weights,
    .threshold = 120,
    saga_obj = saga
  ){

    # Spatial resolution of input DEM
    spatres <- terra::res(.dem)[1]
    dem_crs <- terra::crs(.dem)

    # Get temporary file locations
    flow_path <- tempfile(fileext = ".sgrd")
    flow_filename <- gsub("(\\.sgrd)$", "", flow_path)
    slope_path <- tempfile(fileext = ".sgrd")
    slope_filename <- gsub("(\\.sgrd)$", "", slope_path)

    # Flow accumulation
    flow_acc <-
      saga_obj$ta_hydrology$flow_accumulation_top_down(
        .dem,
        flow = flow_path,
        weights = .weights,
        method = 4, #multiple flow direction
        linear_do = F,
        convergence = 1.1,
        .all_outputs = F
      )

    # Reclassifying flow accumulation

    # Setting a threshold (thresh) of 100m to
    # the flow accumulation assuming a spatial
    # resolution (spatres) of 1m of the DEM.
    # We assume that a total of 100 cells with a
    # width of 1m can accumulate
    threshvalue <- .threshold * spatres

    # Make the zero value equal to spatial resolution
    # of the input DEM
    flow_acc_tr1 <-
      terra::ifel(flow_acc == 0,
                  spatres,
                  flow_acc)

    # Set an upper limit to the Flow Accumulation
    # equal to a threshold
    FlowAcc_thresh <-
      terra::ifel(flow_acc_tr1 > threshvalue,
                  threshvalue,
                  flow_acc_tr1)

    terra::crs(FlowAcc_thresh) <-
      dem_crs

    # Calculate slope in radians
    slope_rad <-
      saga_obj$ta_morphometry$slope_aspect_curvature(
        .dem,
        method = "poly2zevenbergen",
        slope = slope_path,
        unit_slope = 0,
        .all_outputs = F
      )

    # Calculate LS factor
    ls2d <-
      saga_obj$ta_hydrology$ls_factor(
        slope = slope_rad,
        area = FlowAcc_thresh,
        ls = tempfile(fileext = ".sgrd"),
        method = 1 # Desmet & Govers, 1996
      )

    terra::set.names(ls2d, "LS2D")
    terra::crs(ls2d) <- dem_crs

    # Clear up by yourself
    if (file.exists(flow_path)) {
      #Delete file if it exists
      file.remove(flow_path)
      file.remove(paste0(flow_filename, ".sdat"))
    }

    if (file.exists(slope_path)) {
      #Delete file if it exists
      file.remove(slope_path)
      file.remove(paste0(slope_filename, ".sdat"))
    }

    return(ls2d)

  }


