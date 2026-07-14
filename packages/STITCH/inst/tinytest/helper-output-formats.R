stitch_test_output_formats <- function() {
    has_supported_rrbgen <- requireNamespace("rrbgen", quietly = TRUE) &&
        utils::packageVersion("rrbgen") >= "0.0.4"
    c("bgvcf", if (has_supported_rrbgen) "bgen")
}
