#' Transport capacity
#'
#' @description Transport capacity (\eqn{kg·m^{−1}·yr^{−1}}) per unit width of the grid
#' cells is assumed to be proportional to the potential to rill erosion,
#' which is described by a power function of slope length and gradient
#' (Van Rompaey et al., 2001).
#'
#' @param .dem SpatRaster. A single layer with elevation values.
#' Values should have the same unit as the map units, or in meters when
#' the crs is longitude/latitude.
#' @param .ls SpatRaster. An output from \code{\link[rusleR]{ls_2d}}
#' @param .r_factor SpatRaster or Numeric. Rainfall erosivity from RUSLE but
#' divided by \code{10000} to get \eqn{MJ·mm·m^{−2}·h^{−1}·yr^{−1}}.
#' @param .k_factor SpatRaster or Numeric. Soil erodibility from RUSLE but
#' multiplied by \code{1000} to get \eqn{kg·h·MJ^{−1}·mm^{−1}}.
#' @param .ktc SpatRaster. Tranport capacity coefficient \eqn{K_{TC}}.
#' An output from \code{\link[rusleR]{watem_ktc}}
#' @param saga_obj SAGA-GIS geoprocessor object from \code{\link[Rsagacmd]{saga_gis}} with \code{raster_backend = "terra"}
#'
#' @return SpatRaster
#'
#' @references Van Rompaey, A., Verstraeten, G., Van Oost, K., Govers, G., and Poesen, J.: Modelling mean annual sediment yield using a distributed approach, Earth Surf. Proc. Land., 26, 1221–1236, https://doi.org/10.1002/esp.275, 2001.
#'
#' @import terra
#' @import Rsagacmd
#'
#' @export
watem_tc <-
  function(
    .dem,
    .ls,
    .r_factor, # divide by 10000
    .k_factor, # multiply by 1000
    .ktc,
    saga_obj = saga
  ){

    dem_crs <- terra::crs(.dem)

    slope_path <-
      tempfile(fileext = ".sgrd")

    # Calculate slope in percentage
    slope_mm <-
      saga_obj$ta_morphometry$slope_aspect_curvature(
        .dem,
        method = "poly2zevenbergen",
        slope = slope_path,
        unit_slope = 2,
        .all_outputs = F
      ) / 100

    terra::crs(slope_mm) <- dem_crs

    tc <-
      .ktc * .r_factor * .k_factor * (.ls - (4.12 * slope_mm ^ 0.8))

    tc_reclass <-
      terra::ifel(
        tc < 0,
        0,
        tc
      )
    terra::set.names(tc_reclass, "TC")

    if (file.exists(slope_path)) {
      #Delete file if it exists
      file.remove(slope_path)
    }

    return(tc_reclass)

  }


