library(RBCFTools)
library(tinytest)

expected_tools <- c("bcftools", "bgzip", "tabix", "htsfile")
paths <- vapply(expected_tools, rbcftools_binary, character(1L))

expect_true(all(file.exists(paths)))
expect_true(all(nzchar(paths)))

versions <- rbcftools_versions()
expect_identical(names(versions), c("bcftools", "htslib"))
expect_true(all(grepl("^[0-9]+\\.[0-9]+", versions)))

result <- bcftools_run("--version-only")
expect_identical(result$status, 0L)
expect_true(grepl("\\+htslib-", result$stdout))

plugins <- bcftools_plugins()
expect_true(all(c("liftover", "score") %in% plugins))

exports <- getNamespaceExports("RBCFTools")
expect_false(any(grepl("duck|arrow|parquet|vep", exports, ignore.case = TRUE)))
