#' Calculate K-factor
#'
#' @param sand SpatRaster. Single layer raster with sand proportion (%).
#' Outcome of the [rusleR::aggregate_soilgrids()]
#' @param clay SpatRaster. Single layer raster with clay proportion (%).
#' Outcome of the [rusleR::aggregate_soilgrids()]
#' @param silt SpatRaster. Single layer raster with silt proportion (%).
#' Outcome of the [rusleR::aggregate_soilgrids()]
#' @param soc SpatRaster. Single layer raster with weight percentage of organic carbon (%).
#' Outcome of the [rusleR::aggregate_soilgrids()]
#' @param method string. One or more of these options: \code{'williams1983'} (see Details)
#'
#'
#' @details
#' Currently, this function supports the following equations:
#' - \code{'williams1983'} -- An equation from Williams and Renard (1983) as cited in Chen et al. (2011)
#'
#' @return SpatRaster
#' @export
#'
#' @references
#' Williams, J. R., K. G. Renard, and P. T. Dyke. “EPIC: A New Method for Assessing Erosion’s Effect on Soil Productivity.” Journal of Soil and Water Conservation 38, no. 5 (September 1, 1983): 381–83.
#'
#' Chen, Liangang, Xin Qian, and Yong Shi. “Critical Area Identification of Potential Soil Loss in a Typical Watershed of the Three Gorges Reservoir Region.” Water Resources Management 25, no. 13 (June 25, 2011): 3445. https://doi.org/10.1007/s11269-011-9864-4.
#'
#' @examples
#' library(purrr)
#'
#' f <- system.file("extdata/extent.shp", package="rusleR")
#' v <- vect(f)
#'
#' sand <- get_soilgrids(v, layer = "sand")
#' silt <- get_soilgrids(v, layer = "silt")
#' clay <- get_soilgrids(v, layer = "clay")
#' soc <- get_soilgrids(v, layer = "soc")
#'
#' sand_mean <- aggregate_soilgrids(sand)
#' silt_mean <- aggregate_soilgrids(silt)
#' clay_mean <- aggregate_soilgrids(clay)
#' soc_mean <- aggregate_soilgrids(soc)
#'
#' k <- k_factor(sand_mean, silt_mean, clay_mean, soc_mean)
#' k
#'
#' @import terra
#' @md
k_factor <-
  function(sand,
           silt,
           clay,
           soc,
           method = c("williams1983")){

  Sa <- sand
  Si <- silt
  Cl <- clay
  sn <- 1 - (sand / 100)
  C <- soc

  if (method == "williams1983") {

  fsand <- 0.3 * exp(0.0256 * Sa * (1 - Si/100))
  fclsi <- (Si / (Cl + Si))^0.3
  forg <- 1 - ((0.25 * C) / (C + exp(3.72 - 2.95 * C)))
  fhisand <- 1 - ((0.7 * sn) / (sn + exp(-5.51 + 22.9*sn)))

  kfactor <- 0.1317 * (0.2 + fsand * fclsi * forg * fhisand)

  set.names(kfactor, "K_williams1983")

  return(kfactor)

  } else {
    warning("Currently, this version of package supports only Williams et al. (1983) equation")
  }
  }
