# Adding Python functionality to an R package

This guide demonstrates how to distribute Python code with your R package. The key ingredient is the [reticulate](https://rstudio.github.io/reticulate/index.html) package, which exposes Python code to an R session. To begin, ensure that Python and R are installed on your system. We will also make use of several R packages to make our lives easier. Install them by running the following command in R:

``` r
install.packages( c("devtools","usethis","reticulate") )
```

## Create an R package

Create a skeleton for your package by running the following in R:

``` r
usethis::create_package( "~/projects/pypkg" )
usethis::use_package( "reticulate" )
```

replacing `~/project/pypkg` with the desired name and path. The two commands instantiate an empty package called `pypkg` and ensure that `reticulate` is listed as its dependency. You may choose to add additional customization (such as authors, URL, etc.) by calling other [usethis functions](https://usethis.r-lib.org/).

## Add Python code

Inside your package create a `inst/python/` subdirectory. By placing `python/` directory inside `inst/`, you ensure that it will appear at the top level once the package is installed. Following the example above, let's create **~/projects/pypkg/inst/python/extra.py** and fill it with the following content:

``` python
import numpy as np

def pyadd(x,y):
    return x+y

def pymat():
    return np.arange(6).reshape(2,3)
```

The file defines two functions, the latter of which interacts with an external Python package [numpy](https://docs.scipy.org/doc/numpy/).

## Expose Python code to R

Following the [documentation for reticulate](https://rstudio.github.io/reticulate/articles/package.html), create a new file **~/projects/pypkg/R/zzz.R** with the following:

``` r
extra <- NULL

.onLoad <- function(libname, pkgname) {
    extra <<- reticulate::import_from_path("extra", path=system.file("python", package=pkgname))
}
```

As mentioned above, `inst/python/` subdirectory will appear as `python/` at the top level once the package is installed. The file above simply tells R to import the Python code we wrote above as `extra` module. For demonstration purposes, we use a global variable here. However, a better programming practice would be to write an accessor function that encapsulates the Python interface ([see example](https://github.com/ArtemSokolov/indRa/blob/0c2403228df846e4752c261c5637d7fb9472e5b7/R/indra.R#L4)).

## Install the R package

That's it! You're done! Install your new package with

``` r
devtools::install( "~/projects/pypkg" )
```

and take it out for a spin:

``` r
library( pypkg )

## If using virtualenv to manage your external Python packages
reticulate::use_virtualenv( "/path/to/virtualenv" )

## If using conda instead of virtualenv
reticulate::use_condaenv( "/path/to/condaenv" )

extra
# Module(extra)

extra$pyadd(2,3)
# [1] 5

extra$pymat()
#      [,1] [,2] [,3]
# [1,]    0    1    2
# [2,]    3    4    5
```
