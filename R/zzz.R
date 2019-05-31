extra <- NULL

.onLoad <- function(libname, pkgname) {
    extra <<- reticulate::import_from_path("extra", path=system.file("python", package=pkgname))
}
