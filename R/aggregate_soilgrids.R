#' Aggregate SoilGrids rasters
#'
#' It allows to transform and aggregate SoilGrids rasters. I.e. from
#' SoilGrids one would download several layers (0-5, 5-15, 15-30, etc.).
#' This function will take an average among them and convert to conventional
#' units (see \href{https://www.isric.org/explore/soilgrids/faq-soilgrids#What_do_the_filename_codes_mean}{SoilGrids FAQ})
#'
#' @param r SpatRaster, single/multiple layer with soil characteristics.
#' Outcome of the [rusleR::get_soilgrids()] function.
#'
#' @return SpatRaster
#'
#' @examples
#' library(purrr)
#'
#' f <- system.file("extdata/extent.shp", package="rusleR")
#' v <- vect(f)
#'
#' sand <- get_soilgrids(v, layer = "sand")
#' sand
#'
#' sand_agg <- aggregate_soilgrids(sand)
#' sand_agg
#'
#' @export
#'
#' @import terra
#' @md
aggregate_soilgrids <-
  function(r){

    raster_names <- names(r)

    if (all(grepl("sand", raster_names))) {

      r_scale <- r / 10
      r_mean <- mean(r_scale, na.rm = T)

      set.names(r_mean, "sand")

      return(r_mean)

    } else if (all(grepl("silt", raster_names))){

      r_scale <- r / 10
      r_mean <- mean(r_scale, na.rm = T)

      set.names(r_mean, "silt")

      return(r_mean)

    } else if (all(grepl("clay", raster_names))){

      r_scale <- r / 10
      r_mean <- mean(r_scale, na.rm = T)

      set.names(r_mean, "clay")

      return(r_mean)

    } else if (all(grepl("soc", raster_names))){

      r_scale <- r / 100
      r_mean <- mean(r_scale, na.rm = T)

      set.names(r_mean, "soc")

      return(r_mean)

    } else if (all(grepl("phh2o", raster_names))){

      r_scale <- r / 10
      r_mean <- mean(r_scale, na.rm = T)

      set.names(r_mean, "phh2o")

      return(r_mean)

    }

    else {

      warning("Current version supports only sand, silt, clay, soc and phh2o layers. For more info visit https://www.isric.org/explore/soilgrids/faq-soilgrids#What_do_the_filename_codes_mean")

    }
  }
