#' Parcel trapping efficiency
#'
#' @description Parcel trapping efficiency \eqn{P_{TEF}} parameter from
#' WATEM/SEDEM (Van Oost et al., 2000). It corresponds to the proportion of
#' the flow accumulation that is routed downstream (Batista et al., 2022).
#'
#' @param .weights SpatRaster. Landuse/Landcover map
#' @param .m Vector. A reclassification vector used in
#'  \code{\link[terra]{classify}}
#' @param .include.lowest Logical.
#'
#' @return SpatRaster
#'
#' @references Batista PVG, Fiener P, Scheper S, Alewell C. 2022. A conceptual-model-based sediment connectivity assessment for patchy agricultural catchments. Hydrology and Earth System Sciences 26 : 3753–3770. DOI: 10.5194/hess-26-3753-2022
#' @references Van Oost K, Govers G, Desmet P. 2000. Evaluating the effects of changes in landscape structure on soil erosion by water and tillage. Landscape Ecology 15 : 577–589. DOI: 10.1023/A:1008198215674
#'
#' @import terra
#'
#' @export
watem_ptef <-
  function(
    .weights, # input raster
    .m, # reclassification matrix
    .include.lowest = TRUE
  ) {

    # Convert classification vector to matrix
    rlcmat <-
      matrix(.m,
             ncol = 3,
             byrow = TRUE)

    # Reclassify weights raster
    ptef_rast <-
      terra::classify(
        .weights,
        rlcmat,
        include.lowest = .include.lowest
      )

    terra::set.names(ptef_rast, "PTEF")

    return(ptef_rast)

  }
