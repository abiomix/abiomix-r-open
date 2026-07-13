#' Inspect packaged native-tool versions
#'
#' @return `rbcftools_versions()` returns a named character vector.
#'   `bcftools_version()` and `htslib_version()` return one version string.
#' @name rbcftools_versions
NULL

#' @rdname rbcftools_versions
#' @export
rbcftools_versions <- function() {
  output <- trimws(bcftools_run("--version-only")$stdout)
  parts <- strsplit(output, "+htslib-", fixed = TRUE)[[1L]]
  if (length(parts) != 2L || any(!nzchar(parts))) {
    stop("Unexpected bcftools version output: ", output, call. = FALSE)
  }
  c(bcftools = parts[[1L]], htslib = parts[[2L]])
}

#' @rdname rbcftools_versions
#' @export
bcftools_version <- function() {
  unname(rbcftools_versions()[["bcftools"]])
}

#' @rdname rbcftools_versions
#' @export
htslib_version <- function() {
  unname(rbcftools_versions()[["htslib"]])
}

#' Report the installed binary surface
#'
#' @return A list containing versions, executables, and bcftools plugins.
#' @export
rbcftools_capabilities <- function() {
  tools <- c("bcftools", "bgzip", "tabix", "htsfile", "annot-tsv", "ref-cache")
  paths <- vapply(tools, function(tool) {
    tryCatch(rbcftools_binary(tool), error = function(error) "")
  }, character(1L), USE.NAMES = TRUE)

  list(
    versions = rbcftools_versions(),
    executables = paths[nzchar(paths)],
    plugins = bcftools_plugins()
  )
}
