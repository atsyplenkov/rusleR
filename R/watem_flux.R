#' WATEM/SEDEM
#'
#' @param .dem SpatRaster.
#' @param .erosion SpatRaster.
#' @param .transport_capacity SpatRaster.
#' @param saga_obj SAGA-GIS geoprocessor object from \code{\link[Rsagacmd]{saga_gis}} with \code{raster_backend = "terra"}
#'
#' @return List.
#'
#' @import terra
#' @import Rsagacmd
#'
#' @export
watem_flux <-
  function(
    .dem,
    .erosion,
    .transport_capacity,
    saga_obj = saga
  ){

    # Spatial resolution of input DEM
    spatres <- terra::res(.dem)[1]
    dem_crs <- terra::crs(.dem)

    # Get temporary file locations
    flux_path <- tempfile(fileext = ".sgrd")
    deposition_path <- tempfile(fileext = ".sgrd")

    flux <-
      saga_obj$grid_analysis$accumulation_functions(
        surface = .dem,
        input = .erosion,
        control = .transport_capacity,
        operation = 1,
        flux = flux_path,
        state_out = deposition_path
      )

    # Sediment Flux in ???
    flux_rast <-
      flux[[1]]
    terra::set.names(flux_rast, "SedFlux")
    terra::crs(flux_rast) <- dem_crs

    # Deposition in kg/m2
    dep_rast <-
      flux[[2]]
    terra::set.names(dep_rast, "Deposition")
    terra::crs(dep_rast) <- dem_crs

    # Erosion-Deposition in kg/m2
    erdep_rast <-
      dep_rast - .erosion
    terra::set.names(erdep_rast, "ErosionDeposition")

    # Sediment load
    erdep_ton <- (erdep_rast * spatres ^ 2) / 1000
    sedload <-
      terra::global(erdep_ton, "sum", na.rm = TRUE)$sum

    watem <-
      list(
        "Deposition" = dep_rast,
        "Erosion" = .erosion,
        "ErosionDeposition" = erdep_rast,
        "SedimentLoad" = sedload
      )

    if (file.exists(flux_path)) {
      #Delete file if it exists
      file.remove(flux_path)
    }

    return(watem)

  }
