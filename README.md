
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rusleR

<!-- badges: start -->
<!-- badges: end -->

This package offers an `R` implementation of Universal Soil Loss
Equation
([USLE](https://en.wikipedia.org/wiki/Universal_Soil_Loss_Equation)).
You can find here a collection of functions to estimate main factors:
R-factor, K-factor, LS-factor and C-factor. The package
uses[`terra`](https://github.com/rspatial/terra) and
[`Rsagacmd`](https://github.com/stevenpawley/Rsagacmd/) in the
background. [`SAGA GIS`](https://sourceforge.net/projects/saga-gis/)
needs to be install on your machine as well.

## Installation

You can install the development version of rusleR from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("atsyplenkov/rusleR")
```

## Example

``` r
library(rusleR)
## basic example code
```

This is a basic example which shows you how to calculate LS_alpine
([Schmidt et al.,
2019](https://www.sciencedirect.com/science/article/pii/S2215016119300056)):

``` r
library(Rsagacmd)
library(terra)

# initiate a saga object
saga <- saga_gis(raster_backend = "terra")

# load DEM
f <- system.file("extdata/dem.tif", package="rusleR")
DEM <- rast(f)

# calculate LS-alpine
ls <- ls_alpine(dem = DEM)
```

As a result of `ls_alpine()` you receive a `SpatRaster` object:

``` r
ls
#> class       : SpatRaster 
#> dimensions  : 78, 54, 1  (nrow, ncol, nlyr)
#> resolution  : 27.30756, 27.30756  (x, y)
#> extent      : 337615.4, 339090, 4814626, 4816756  (xmin, xmax, ymin, ymax)
#> coord. ref. : WGS 84 / UTM zone 38N (EPSG:32638) 
#> source      : memory 
#> name        : LSalpine 
#> min value   :        0 
#> max value   : 114.6034
```

<img src="man/figures/README-pressure-1.png" width="50%" />

## To add

-   K-factor functions
-   R-factor function to crop GLOREDA
-   C-factor???
