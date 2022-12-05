#' Calculates water erosion
#'
#' @param .r_factor SpatRaster or Numeric. Rainfall erosivity from RUSLE but
#' divided by \code{10000} to get \eqn{MJ·mm·m^{−2}·h^{−1}·yr^{−1}}.
#' @param .k_factor SpatRaster or Numeric. Soil erodibility from RUSLE but
#' multiplied by \code{1000} to get \eqn{kg·h·MJ^{−1}·mm^{−1}}.
#' @param .c_factor SpatRaster. It is a cover management factor (dimensionless)
#' @param .ls_factor SpatRaster. \eqn{LS} factor. An output from \code{\link[rusleR]{ls_2d}}
#'
#' @return SpatRaster.
#'
#' @import terra
#'
#' @export
watem_erosion <-
  function(
    .r_factor,
    .k_factor,
    .c_factor,
    .ls_factor
  ){

    erosion <-
      .r_factor * .k_factor * .c_factor * .ls_factor

    terra::set.names(erosion, "Erosion")

    return(erosion)

  }
