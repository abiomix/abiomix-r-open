#' Locate a packaged native executable
#'
#' @param tool One of `bcftools`, `bgzip`, `tabix`, `htsfile`, `annot-tsv`, or
#'   `ref-cache`.
#'
#' @return The normalized absolute path to the executable.
#' @export
rbcftools_binary <- function(
  tool = c("bcftools", "bgzip", "tabix", "htsfile", "annot-tsv", "ref-cache")
) {
  tool <- match.arg(tool)
  path <- switch(
    tool,
    bcftools = bcftools_path(),
    bgzip = bgzip_path(),
    tabix = tabix_path(),
    htsfile = htsfile_path(),
    `annot-tsv` = annot_tsv_path(),
    `ref-cache` = ref_cache_path()
  )

  if (!nzchar(path) || !file.exists(path)) {
    stop("Packaged executable is unavailable: ", tool, call. = FALSE)
  }

  normalizePath(path, mustWork = TRUE)
}

#' @rdname rbcftools_binary
#' @export
bcftools_path <- function() {
  system.file("bcftools", "bin", "bcftools", package = "RBCFTools")
}

#' @rdname rbcftools_binary
#' @export
bgzip_path <- function() {
  system.file("htslib", "bin", "bgzip", package = "RBCFTools")
}

#' @rdname rbcftools_binary
#' @export
tabix_path <- function() {
  system.file("htslib", "bin", "tabix", package = "RBCFTools")
}

#' @rdname rbcftools_binary
#' @export
htsfile_path <- function() {
  system.file("htslib", "bin", "htsfile", package = "RBCFTools")
}

#' @rdname rbcftools_binary
#' @export
annot_tsv_path <- function() {
  system.file("htslib", "bin", "annot-tsv", package = "RBCFTools")
}

#' @rdname rbcftools_binary
#' @export
ref_cache_path <- function() {
  system.file("htslib", "bin", "ref-cache", package = "RBCFTools")
}

#' Locate packaged tool directories
#'
#' @return The package path for the requested binary or plugin directory.
#' @name rbcftools_directories
NULL

#' @rdname rbcftools_directories
#' @export
bcftools_bin_dir <- function() {
  system.file("bcftools", "bin", package = "RBCFTools")
}

#' @rdname rbcftools_directories
#' @export
htslib_bin_dir <- function() {
  system.file("htslib", "bin", package = "RBCFTools")
}

#' @rdname rbcftools_directories
#' @export
bcftools_plugins_dir <- function() {
  system.file("bcftools", "libexec", "bcftools", package = "RBCFTools")
}

#' @rdname rbcftools_directories
#' @export
htslib_plugins_dir <- function() {
  system.file("htslib", "libexec", "htslib", package = "RBCFTools")
}

#' List packaged tools and plugins
#'
#' @return A character vector of installed names.
#' @name rbcftools_inventory
NULL

#' @rdname rbcftools_inventory
#' @export
bcftools_tools <- function() {
  list.files(bcftools_bin_dir())
}

#' @rdname rbcftools_inventory
#' @export
htslib_tools <- function() {
  list.files(htslib_bin_dir())
}

#' @rdname rbcftools_inventory
#' @export
bcftools_plugins <- function() {
  files <- list.files(
    bcftools_plugins_dir(),
    pattern = "\\.(so|dylib|dll)$",
    ignore.case = TRUE
  )
  sort(unique(sub("\\.(so|dylib|dll)$", "", files, ignore.case = TRUE)))
}

#' Configure native-tool plugin lookup for the current R process
#'
#' Child processes launched by `rbcftools_run()` receive these values without
#' mutating the R process. Call this function only when another launcher needs
#' the variables in the current environment.
#'
#' @return Invisibly, the previous named values of `HTS_PATH` and
#'   `BCFTOOLS_PLUGINS`.
#' @export
setup_hts_env <- function() {
  variables <- c("HTS_PATH", "BCFTOOLS_PLUGINS")
  previous <- Sys.getenv(variables, unset = NA_character_)
  do.call(Sys.setenv, list(
    HTS_PATH = htslib_plugins_dir(),
    BCFTOOLS_PLUGINS = bcftools_plugins_dir()
  ))
  invisible(previous)
}

#' Run a packaged native tool
#'
#' @param tool One of the names accepted by `rbcftools_binary()`.
#' @param args A character vector passed directly to the executable.
#' @param stdin Optional standard input accepted by [processx::run()].
#' @param error_on_status Whether a non-zero exit status raises an error.
#' @param echo Whether to echo child output while the process runs.
#' @param timeout Process timeout in milliseconds; `Inf` disables it.
#' @param env Optional named environment overrides.
#'
#' @return A `processx::run()` result with `status`, `stdout`, and `stderr`.
#' @export
rbcftools_run <- function(
  tool,
  args = character(),
  stdin = NULL,
  error_on_status = TRUE,
  echo = FALSE,
  timeout = Inf,
  env = character()
) {
  if (!is.character(args) || anyNA(args)) {
    stop("args must be a character vector without missing values", call. = FALSE)
  }
  if (length(env) && (is.null(names(env)) || any(!nzchar(names(env))))) {
    stop("env must be a named character vector", call. = FALSE)
  }

  runtime_env <- c(
    HTS_PATH = htslib_plugins_dir(),
    BCFTOOLS_PLUGINS = bcftools_plugins_dir()
  )
  if (length(env)) {
    runtime_env[names(env)] <- env
  }

  processx::run(
    command = rbcftools_binary(tool),
    args = args,
    stdin = stdin,
    stdout = "|",
    stderr = "|",
    error_on_status = error_on_status,
    echo = echo,
    timeout = timeout,
    env = runtime_env
  )
}

#' Run the packaged bcftools executable
#'
#' @inheritParams rbcftools_run
#' @return A `processx::run()` result with `status`, `stdout`, and `stderr`.
#' @export
bcftools_run <- function(
  args = character(),
  stdin = NULL,
  error_on_status = TRUE,
  echo = FALSE,
  timeout = Inf,
  env = character()
) {
  rbcftools_run(
    tool = "bcftools",
    args = args,
    stdin = stdin,
    error_on_status = error_on_status,
    echo = echo,
    timeout = timeout,
    env = env
  )
}
