#' Download SoilGrids layers
#'
#' @param aoi SpatVector. A polygon layer with area of interest.
#' @param layer character. A string indicating what layers should be downloaded. Either one of the following: \code{'all'}, \code{'sand'}, \code{'clay'}, \code{'silt'} or \code{'soc'}
#'
#' @return SpatRaster
#'
#' @examples
#' library(terra)
#' library(purrr)
#'
#' f <- system.file("extdata/extent.shp", package="rusleR")
#' v <- vect(f)
#'
#' sand <- get_soilgrids(v, layer = "sand")
#'
#' plot(sand)
#'
#' @export
get_soilgrids <- function(aoi,
                          layer = "all"){

  # Some check
  stopifnot(
    "Input vector must be polygons" =
      terra::geomtype(aoi) == "polygons"
  )

  # Get shapefiles CRS
  aoi_crs <- terra::crs(aoi, proj = TRUE)

  # Transform to IGH projection
  igh <- '+proj=igh +lat_0=0 +lon_0=0 +datum=WGS84 +units=m +no_defs'
  aoi_proj <- terra::project(aoi, igh)

  # Download links
  sg_url <- "/vsicurl/https://files.isric.org/soilgrids/latest/data/"
  props <- c("sand", "silt", "clay", "soc")
  layers <- c("0-5", "5-15", "15-30")

  vrt_sand <- paste0(props[1], "/",
                     props[1], "_",
                     layers,
                     "cm_mean.vrt")

  vrt_silt <- paste0(props[2], "/",
                     props[2], "_",
                     layers,
                     "cm_mean.vrt")

  vrt_clay <- paste0(props[3], "/",
                     props[3], "_",
                     layers,
                     "cm_mean.vrt")

  vrt_soc <- paste0(props[4], "/",
                    props[4], "_",
                    layers,
                    "cm_mean.vrt")


  # Download function
  soilgrids_download <- function(list_vrt, # download url
                                 shape_igh){ # AOI shape in IGH proj


    r <- terra::rast(paste0(sg_url, list_vrt)) # read raster
    r_crop <- terra::crop(r, shape_igh, mask = TRUE) # crop to bounding box

    cat(".")

    return(r_crop)

  }

  if (layer == "all") {

    # Download
    cat("Downloading Sand rasters")
    sand_rasters <-
      purrr::map(vrt_sand,
                 ~soilgrids_download(list_vrt = .x,
                                     shape_igh = aoi_proj)) |>
      terra::rast() |>
      terra::project(aoi_crs)

    cat("Downloading Silt rasters")
    silt_rasters <-
      purrr::map(vrt_silt,
                 ~soilgrids_download(list_vrt = .x,
                                     shape_igh = aoi_proj)) |>
      terra::rast() |>
      terra::project(aoi_crs)

    cat("Downloading Clay rasters")
    clay_rasters <-
      purrr::map(vrt_clay,
                 ~soilgrids_download(list_vrt = .x,
                                     shape_igh = aoi_proj)) |>
      terra::rast() |>
      terra::project(aoi_crs)

    cat("Downloading SOC rasters")
    soc_rasters <-
      purrr::map(vrt_soc,
                 ~soilgrids_download(list_vrt = .x,
                                     shape_igh = aoi_proj)) |>
      terra::rast() |>
      terra::project(aoi_crs)

    cat("\n")

    # Return
    list(sand_rasters,
         silt_rasters,
         clay_rasters,
         soc_rasters)

  } else if (layer == "sand") {

    cat("Downloading Sand rasters")

    sand_rasters <-
      purrr::map(vrt_sand,
                 ~soilgrids_download(list_vrt = .x,
                                     shape_igh = aoi_proj)) |>
      terra::rast() |>
      terra::project(aoi_crs)

    cat("\n")

    return(sand_rasters)

  } else if (layer == "silt") {

    cat("Downloading Silt rasters")

    silt_rasters <-
      purrr::map(vrt_silt,
                 ~soilgrids_download(list_vrt = .x,
                                     shape_igh = aoi_proj)) |>
      terra::rast() |>
      terra::project(aoi_crs)

    cat("\n")

    return(silt_rasters)

  } else if (layer == "clay") {

    cat("Downloading Clay rasters")

    clay_rasters <-
      purrr::map(vrt_clay,
                 ~soilgrids_download(list_vrt = .x,
                                     shape_igh = aoi_proj)) |>
      terra::rast() |>
      terra::project(aoi_crs)

    cat("\n")

    return(clay_rasters)

  } else if (layer == "soc") {

    cat("Downloading SOC rasters")

    soc_rasters <-
      purrr::map(vrt_soc,
                 ~soilgrids_download(list_vrt = .x,
                                     shape_igh = aoi_proj)) |>
      terra::rast() |>
      terra::project(aoi_crs)

    cat("\n")

    return(soc_rasters)

  } else {

    warning("layer argument should one of the follows: 'all', 'sand', 'clay', 'silt' or 'soc'")

  }

}
