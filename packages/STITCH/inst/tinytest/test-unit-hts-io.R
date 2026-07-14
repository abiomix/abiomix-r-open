(function() { # linked HTSlib compresses and indexes a VCF
    vcf <- tempfile(fileext = ".vcf")
    bgzf <- paste0(vcf, ".gz")
    writeLines(c(
        "##fileformat=VCFv4.2",
        "##contig=<ID=chr1,length=1000>",
        "#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO",
        "chr1\t10\t.\tA\tG\t.\tPASS\t."
    ), vcf)

    compressed <- bgzip_file(vcf, bgzf, remove_input = TRUE)
    expect_true(file.exists(compressed))
    expect_false(file.exists(vcf))
    expect_equal(readLines(gzfile(compressed)), c(
        "##fileformat=VCFv4.2",
        "##contig=<ID=chr1,length=1000>",
        "#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO",
        "chr1\t10\t.\tA\tG\t.\tPASS\t."
    ))

    index <- index_vcf(compressed)
    expect_true(file.exists(index))
    expect_error(index_vcf(compressed), "Index already exists")
})()

(function() { # compression does not overwrite output implicitly
    input <- tempfile()
    output <- tempfile()
    writeLines("input", input)
    writeLines("existing", output)

    expect_error(bgzip_file(input, output), "Output already exists")
    expect_equal(readLines(output), "existing")
})()
