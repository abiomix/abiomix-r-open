(function() { # HWE in C++ is the same as in R

    mat <- rbind(
        c(0, 0, 0),
        c(0, 0, 1),
        c(0, 1, 0),
        c(1, 0, 0),
        c(0, 1, 1),
        c(1, 0, 1),
        c(1, 1, 0),
        c(1, 1, 1),
        c(5, 10, 20),
        c(20, 10, 5),
        c(10000, 100, 10),
        c(10000, 101, 10),
        c(10000, 102, 10),
        c(10000, 103, 10),
        c(10000, 10000, 10),
        c(44102, 39965, 9218), ## threw error before long int
        c(100000, 100, 1),
        c(1000000, 100, 1)
    )

    apply(mat, 1, function(x) {
        expect_equal(
            STITCH:::calculate_hwe_p(x),
            rcpp_calculate_hwe_p(x)
        )
    })

})()

(function() { # HWE aggregation resolves parallel from its namespace
    expect_match(
        paste(deparse(body(generate_hwe_on_counts)), collapse = "\n"),
        "parallel::mclapply"
    )
    expect_length(
        generate_hwe_on_counts(rbind(c(10, 20, 10), c(5, 2, 7)), 2L, 1L),
        2L
    )
})()
