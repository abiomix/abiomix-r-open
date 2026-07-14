(function() { # compression and VCF indexing use STITCH's linked HTSlib
    expect_true(is.function(STITCH::bgzip_file))
    expect_true(is.function(STITCH::index_vcf))
    expect_false(grepl(
        "check_program_dependency",
        paste(deparse(body(QUILT::QUILT)), collapse = "\n"),
        fixed = TRUE
    ))
    namespace <- asNamespace("QUILT")
    expect_true(exists("get_sample_names", envir = namespace, inherits = TRUE))
    expect_true(exists("getSampleRange", envir = namespace, inherits = TRUE))
    expect_match(
        paste(deparse(body(get("quilt_map_Z_to_all_symbols", namespace))), collapse = "\n"),
        "STITCH::calc_dist_between_rhb_t_and_hap"
    )
    expect_match(
        paste(deparse(body(STITCH::generate_hwe_on_counts)), collapse = "\n"),
        "parallel::mclapply"
    )
})()

(function() { # msPBWT symbol mapping does not require an attached STITCH package
    mapper <- get("quilt_map_Z_to_all_symbols", asNamespace("QUILT"))
    all_symbols <- list(cbind(value = c(0L, 3L), symbol = c(10L, 11L)))
    expect_identical(typeof(mapper(1L, all_symbols)), "integer")
    expect_length(mapper(1L, all_symbols), 1L)
})()
