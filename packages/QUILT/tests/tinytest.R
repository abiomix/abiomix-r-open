if (requireNamespace("tinytest", quietly = TRUE)) {
    local({
        suppressPackageStartupMessages(library(tinytest))

        test_scope <- "QUILT:test-internals"
        attach(
            as.list(asNamespace("QUILT"), all.names = TRUE),
            pos = 2L,
            name = test_scope,
            warn.conflicts = FALSE
        )
        on.exit(detach(test_scope, character.only = TRUE), add = TRUE)

        profile <- tolower(Sys.getenv("ABIOMIX_TEST_PROFILE", "unit"))
        if (!profile %in% c("unit", "acceptance")) {
            stop("ABIOMIX_TEST_PROFILE must be one of: unit, acceptance")
        }

        acceptance_tools <- c("samtools", "bcftools", "bgzip", "tabix")
        missing_tools <- acceptance_tools[!nzchar(Sys.which(acceptance_tools))]

        run_acceptance <- profile == "acceptance"

        if (profile == "acceptance" && length(missing_tools)) {
            stop(
                "QUILT acceptance tests require: ",
                paste(missing_tools, collapse = ", ")
            )
        }

        pattern <- if (run_acceptance) {
            "^test-(unit|acceptance).*\\.[rR]$"
        } else {
            "^test-unit.*\\.[rR]$"
        }

        tinytest::test_package("QUILT", pattern = pattern)
    })
}
