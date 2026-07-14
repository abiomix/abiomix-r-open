(function() { # can validate output format
    expect_null(STITCH:::validate_output_format("bgen"))
    expect_null(STITCH:::validate_output_format("bgvcf"))
    expect_error(STITCH:::validate_output_format(NA))
    expect_error(STITCH:::validate_output_format("word"))
    expect_error(STITCH:::validate_output_format(FALSE))
    expect_error(STITCH:::validate_output_format(1))
    expect_error(STITCH:::validate_output_format(1.1))
})()


(function() { # output_filename throws an error when too short
    expect_error(validate_output_filename("A", "bgvcf"), "output_filename must have at least 8 characters and end with .vcf.gz, and you have supplied:A")
})()

(function() { # bgen_output_name throws an error when too short
    expect_error(validate_bgen_output_name("A"), "bgen")
})()

(function() { # output_filename throws an error if no .vcf.gz
    expect_error(validate_output_filename("A.vcf", "bgvcf"), "output_filename must have at least 8 characters and end with .vcf.gz, and you have supplied:A.vcf")
})()

(function() { # bgen_output_name throws an error no bgen
    expect_error(validate_bgen_output_name("Awer.bge"), "bgen")
})()

(function() { # vcf_output_name can be OK
    expect_equal(validate_vcf_output_name("A.vcf.gz"), NULL)
})()

(function() { # output_filename can be OK
    expect_equal(validate_output_filename("A.vcf.gz", "bgvcf"), NULL)
    expect_equal(validate_output_filename("A.bgen", "bgen"), NULL)
})()



(function() { # if output_filename does not have a folder, it is placed in outputdir
    output_filename <- "jimmy.vcf.gz"
    outputdir <- "/path/to/folder"
    regionName <- "20.10.20"
    output_vcf <- get_output_filename(output_filename, outputdir, regionName, output_format = "gvcf")
    expect_equal(
        output_vcf,
        file.path(outputdir, "jimmy.vcf.gz")
    )
})()

(function() { # if vcf_output_name has a folder, this is the path to the file
    vcf_output_name <- file.path("path", "to", "jimmy.vcf.gz")
    outputdir <- "/path/to/folder"
    regionName <- "20.10.20"
    output_vcf <- get_output_filename(vcf_output_name, outputdir, regionName, ".gvcf")
    expect_equal(
        output_vcf,
        vcf_output_name
    )
})()

(function() { # if output_filename is NULL, output_filename is constructed in the default way
    output_filename <- NULL
    outputdir <- "/path/to/folder"
    regionName <- "20.10.20"
    output_vcf <- get_output_filename(output_filename, outputdir, regionName, "bgvcf")
    expect_equal(
        output_vcf,
        file.path(
            outputdir,
            paste0("stitch.", regionName, ".vcf.gz")
        )
    )
})()
