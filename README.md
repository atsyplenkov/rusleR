
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rusleR

<!-- badges: start -->
<!-- badges: end -->

The goal of rusleR is to …

## Installation

You can install the development version of rusleR from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("atsyplenkov/rusleR")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(rusleR)
## basic example code
```

What is special about using `README.Rmd` instead of just `README.md`?
You can include R chunks like so:

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

You’ll still need to render `README.Rmd` regularly, to keep `README.md`
up-to-date. `devtools::build_readme()` is handy for this. You could also
use GitHub Actions to re-render `README.Rmd` every time you push. An
example workflow can be found here:
<https://github.com/r-lib/actions/tree/v1/examples>.

You can also embed plots, for example:

<img src="man/figures/README-pressure-1.png" width="50%" />

In that case, don’t forget to commit and push the resulting figure
files, so they display on GitHub and CRAN.
