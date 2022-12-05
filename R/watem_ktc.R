#' Transport capacity coefficient
#'
#' @description Calculates \eqn{K_{TC}} from WATEM/SEDEM (Van Oost et al., 2000). It is
#' a land-use-dependent transport capacity coefficient (m). The transport
#' capacity is the maximum sediment mass that can be transported by the overland
#'  flow. If the sediment production is higher than this transport capacity,
#'  sediment will be deposited. Thus, the higher the transport capacity coefficient,
#'  the more sediment can be transported downslope (Van Oost et al., 2000).
#'
#' @param .c_factor SpatRaster. It is a cover management factor (dimensionless)
#' @param .ktc_low Numeric. The lower limit of possible \eqn{K_{TC}}
#' @param .ktc_high Numeric. The upper limit of \eqn{K_{TC}}
#' @param .c_max Numeric. A threshold C-factor value needs to be
#' given to indicate for which areas the high \eqn{K_{TC}} needs to
#'  be used. Usually, roads are given a very high \eqn{K_{TC}} such
#'  that no sediment deposition is modelled on road surfaces. The default is \code{0.1}.
#' @param .seed Numeric.
#'
#' @return SpatRaster
#'
#' @details The \eqn{K_{TC}} usually requires calibration (\emph{cf.} Batista et al., 2022).
#' Here we used an approach suggested in Batista et al. (2022). \eqn{K_{TC}}
#' value is sampled from an uniform distribution using the \code{\link[stats]{runif}}
#' function.
#'
#' @references Batista PVG, Fiener P, Scheper S, Alewell C. 2022. A conceptual-model-based sediment connectivity assessment for patchy agricultural catchments. Hydrology and Earth System Sciences 26 : 3753–3770. DOI: 10.5194/hess-26-3753-2022
#' @references Van Oost K, Govers G, Desmet P. 2000. Evaluating the effects of changes in landscape structure on soil erosion by water and tillage. Landscape Ecology 15 : 577–589. DOI: 10.1023/A:1008198215674
#'
#' @import terra
#'
#' @export
watem_ktc <-
  function(.c_factor,
           .ktc_low = 75,
           .ktc_high = 250,
           .c_max = 0.1, # Transport capacity coef limit
           .seed = 1234){

    set.seed(.seed)
    # Ktc values will be sampled from uniform distributions
    KtcHigh <- round(runif(1, .ktc_low, .ktc_high)) #choose the range -- in this case min = 1 and max = 200
    KtcLow <- round(runif(1, .ktc_low, ifelse(
      KtcHigh < 100, KtcHigh - 1, 100))
    ) # choose the range -- in this case min = 1 and max = KtcHigh - 1

    ktc_rast <-
      terra::ifel(
        .c_factor >= .c_max,
        KtcHigh,
        KtcLow
      )

    return(ktc_rast)

  }
