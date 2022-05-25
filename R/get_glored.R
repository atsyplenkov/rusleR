#' Download Global Rainfall Erosivity
#'
#' @description This function download Global Rainfall Erosivity Database (GLORED) created by \emph{Panagos et al.} (2017) and crop it to the shapefile boundaries.
#'
#' @param aoi SpatVector. A polygon layer with area of interest.
#' @param warp logical. If TRUE, reproject the GLORED raster to \code{aoi} projection
#'
#' @return SpatRaster
#'
#' @references Panagos, Panos, Pasquale Borrelli, Katrin Meusburger, Bofu Yu, Andreas Klik, Kyoung Jae Lim, Jae E. Yang, et al. “Global Rainfall Erosivity Assessment Based on High-Temporal Resolution Rainfall Records.” Scientific Reports 7, no. 1 (June 23, 2017): 4175. https://doi.org/10.1038/s41598-017-04282-8.
#'
#' @examples
#' library(terra)
#'
#' f <- system.file("extdata/extent.shp", package="rusleR")
#' v <- vect(f)
#'
#' r_factor <- get_glored(v)
#'
#' plot(r_factor)
#'
#' @export
get_glored <- function(aoi,
                       warp = TRUE){

  # Some check
  stopifnot(
    "Input vector must be polygons" =
      terra::geomtype(aoi) == "polygons"
  )

  # Get shapefiles CRS
  aoi_crs <- terra::crs(aoi, proj = TRUE)

  # LOAD COG
  glored <- terra::rast("/vsicurl/https://storage.yandexcloud.net/glored/out.tiff")

  # Get GLORED CRS
  glored_crs <- terra::crs(glored, proj = TRUE)

  # Project shapefile
  aoi_proj <- terra::project(aoi, glored_crs)

  # Crop GLORED to AOI
  glored_mask <- terra::crop(glored, aoi_proj, mask = TRUE)

  # Should we project final raster?
  if (warp) {

    glored_proj <- terra::project(glored_mask, aoi_crs)
    return(glored_proj)

  } else {

    return(glored_mask)

  }

}
