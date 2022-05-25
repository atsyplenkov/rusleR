#' ls_alpine
#'
#' @description This function calculates an LS-factor from Universal Soil Loss Equation (USLE), as described in \emph{Schmidt et al.} (2019).
#'
#' @param dem SpatRaster, single layer with elevation values. Values should have the same unit as the map units, or in meters when the crs is longitude/latitude
#' @param threshold numeric/double, specifying a flow threshold in meters. Default is 120 m
#' @param saga_obj SAGA-GIS geoprocessor object. Run \code{Rsagacmd::saga_gis(raster_backend = "terra")}
#'
#' @return SpatRaster
#'
#' @references Schmidt, Simon, Simon Tresch, and Katrin Meusburger. “Modification of the RUSLE Slope Length and Steepness Factor (LS-Factor) Based on Rainfall Experiments at Steep Alpine Grasslands.” MethodsX 6 (2019): 219–29. https://doi.org/10.1016/j.mex.2019.01.004.
#'
#' @examples
#' \dontrun{
#' library(Rsagacmd)
#'
#' # initiate a saga object
#' saga <- saga_gis(raster_backend = "terra")
#'
#' # load DEM
#' f <- system.file("extdata/dem.tif", package="rusleR")
#' DEM <- rast(f)
#'
#' # calculate LS-alpine
#' ls <- ls_alpine(dem = DEM)
#'
#' plot(ls)
#' }
#'
#' @export
#'
#' @import terra
#' @import Rsagacmd
ls_alpine <-
  function(dem,
           threshold = 120,
           saga_obj = saga){

    # Spatial resolution of input DEM
    spatres <- terra::res(dem)[1]
    dem_crs <- terra::crs(dem)

    # Calculate slope in radians
    slope_rad <-
      saga_obj$ta_morphometry$slope_aspect_curvature(
        dem,
        method = "poly2zevenbergen",
        slope = tempfile(fileext = ".sgrd"),
        unit_slope = 0,
        .all_outputs = F
      )

    # Calculate slope in percentage
    slope_perc <-
      saga_obj$ta_morphometry$slope_aspect_curvature(
        dem,
        method = "poly2zevenbergen",
        slope = tempfile(fileext = ".sgrd"),
        unit_slope = 2,
        .all_outputs = F
      )

    # Flow accumulation
    flow_acc <-
      saga$ta_hydrology$flow_accumulation_top_down(
        dem,
        # LINEAR_MIN=500, METHOD=5, CONVERGENCE=1.1
        flow = tempfile(fileext = ".sgrd"),
        method = 5,
        linear_min = 500,
        convergence = 1.1,
        .all_outputs = F
      )

    # Setting a threshold (thresh) of 100m to
    # the flow accumulation assuming a spatial
    # resolution (spatres) of 1m of the DEM.
    # We assume that a total of 100 cells with a
    # width of 1m can accumulate
    threshvalue <- threshold / spatres

    flow_acc_tr1 <-
      terra::ifel(flow_acc == 0,
                  spatres,
                  flow_acc)

    FlowAcc_thresh <-
      terra::ifel(flow_acc_tr1 > threshvalue,
                  threshvalue,
                  flow_acc_tr1)

    # Calculation of L-factor
    Beta <-
      (sin(slope_rad) / 0.0896) / (3 * (sin(slope_rad)^0.8) + 0.56)

    Mvalue <-
      Beta / (1 + Beta)

    Lfactor_w_thresh <-
      ((FlowAcc_thresh + (spatres^2))^(Mvalue + 1) - FlowAcc_thresh^(Mvalue + 1))/(spatres^(Mvalue + 2)*22.13^Mvalue)

    # Calculation of S-factor (alpine)
    Salpine <-
      (1/2000)*(slope_perc^2)+0.1795*(slope_perc)-0.4418

    # Remove negative S-factor
    Salpine_cor <-
      terra::ifel(Salpine < 0, 0, Salpine)

    # LS alpine calculation
    LSalpine <-
      Salpine_cor * Lfactor_w_thresh

    terra::set.names(LSalpine, "LSalpine")
    terra::crs(LSalpine) <- dem_crs

    return(LSalpine)

  }
