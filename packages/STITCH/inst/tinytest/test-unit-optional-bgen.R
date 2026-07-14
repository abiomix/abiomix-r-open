(function() { # BGVCF output does not require rrbgen
    expect_null(STITCH:::validate_output_format("bgvcf"))
})()

(function() { # the optional BGEN dependency fails with a direct explanation
    if (requireNamespace("rrbgen", quietly = TRUE)) { message("Skipped: condition met"); return(invisible(NULL)) }
    expect_error(
        STITCH:::require_rrbgen_for_bgen(),
        "output_format='bgen' requires the optional rrbgen package"
    )
})()

(function() { # an installed BGEN dependency satisfies the declared minimum
    if (!requireNamespace("rrbgen", quietly = TRUE)) { message("Skipped: package not installed: ", "rrbgen"); return(invisible(NULL)) }
    if (utils::packageVersion("rrbgen") < "0.0.4") {
        expect_error(STITCH:::require_rrbgen_for_bgen(), "requires rrbgen >= 0.0.4")
    } else {
        expect_null(STITCH:::require_rrbgen_for_bgen())
    }
})()
