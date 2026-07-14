#' Compress a file with linked HTSlib BGZF support
#'
#' @param input Path to an existing uncompressed file.
#' @param output Destination for the BGZF-compressed file.
#' @param threads Number of HTSlib compression threads.
#' @param overwrite Whether an existing destination may be replaced.
#' @param remove_input Whether to remove `input` after successful compression.
#'
#' @return The normalized output path, invisibly.
#' @export
bgzip_file <- function(
    input,
    output = paste0(input, ".gz"),
    threads = 1L,
    overwrite = FALSE,
    remove_input = FALSE
) {
    input <- normalizePath(input, mustWork = TRUE)
    output <- normalizePath(output, mustWork = FALSE)
    threads <- as.integer(threads)

    if (identical(input, output)) {
        stop("`input` and `output` must be different files", call. = FALSE)
    }
    if (length(threads) != 1L || is.na(threads) || threads < 1L) {
        stop("`threads` must be one positive integer", call. = FALSE)
    }
    if (file.exists(output) && !isTRUE(overwrite)) {
        stop("Output already exists: ", output, call. = FALSE)
    }
    if (file.exists(output) && unlink(output) != 0L) {
        stop("Could not replace existing output: ", output, call. = FALSE)
    }

    cpp_bgzf_compress(input, output, threads)
    if (isTRUE(remove_input) && unlink(input) != 0L) {
        warning("BGZF output was written but input could not be removed: ", input)
    }
    invisible(output)
}

#' Build a tabix index for a BGZF-compressed VCF
#'
#' @param file Path to a BGZF-compressed VCF.
#' @param threads Number of HTSlib indexing threads.
#' @param overwrite Whether an existing `.tbi` index may be replaced.
#'
#' @return The normalized tabix index path, invisibly.
#' @export
index_vcf <- function(file, threads = 1L, overwrite = FALSE) {
    file <- normalizePath(file, mustWork = TRUE)
    index <- paste0(file, ".tbi")
    threads <- as.integer(threads)

    if (length(threads) != 1L || is.na(threads) || threads < 1L) {
        stop("`threads` must be one positive integer", call. = FALSE)
    }
    if (file.exists(index) && !isTRUE(overwrite)) {
        stop("Index already exists: ", index, call. = FALSE)
    }
    if (file.exists(index) && unlink(index) != 0L) {
        stop("Could not replace existing index: ", index, call. = FALSE)
    }

    cpp_index_vcf(file, threads)
    if (!file.exists(index)) {
        stop("HTSlib did not create the expected index: ", index, call. = FALSE)
    }
    invisible(normalizePath(index, mustWork = TRUE))
}
