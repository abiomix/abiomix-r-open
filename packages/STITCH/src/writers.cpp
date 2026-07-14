#include <RcppArmadillo.h>
#include <string>
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <vector>

#include "htslib/bgzf.h"
#include "htslib/tbx.h"


// [[Rcpp::depends(RcppArmadillo)]]
using namespace Rcpp;

// [[Rcpp::export]]
void cpp_bgzf_compress(
    const std::string& input_path,
    const std::string& output_path,
    const int n_threads
) {
    FILE* input = fopen(input_path.c_str(), "rb");
    if (input == nullptr) {
        Rcpp::stop("Cannot open input file for BGZF compression: %s", input_path);
    }

    BGZF* output = bgzf_open(output_path.c_str(), "w");
    if (output == nullptr) {
        fclose(input);
        Rcpp::stop("Cannot open output file for BGZF compression: %s", output_path);
    }

    bool failed = false;
    std::string failure_message;
    if (n_threads > 1 && bgzf_mt(output, n_threads, 256) != 0) {
        failed = true;
        failure_message = "Cannot initialize HTSlib BGZF worker threads";
    }

    std::vector<unsigned char> buffer(1024 * 1024);
    while (!failed) {
        const size_t bytes_read = fread(buffer.data(), 1, buffer.size(), input);
        if (bytes_read > 0) {
            const ssize_t bytes_written = bgzf_write(output, buffer.data(), bytes_read);
            if (bytes_written < 0 || static_cast<size_t>(bytes_written) != bytes_read) {
                failed = true;
                failure_message = "HTSlib failed while writing the BGZF output";
                break;
            }
        }
        if (bytes_read < buffer.size()) {
            if (ferror(input)) {
                failed = true;
                failure_message = "Failed while reading the input file";
            }
            break;
        }
    }

    if (fclose(input) != 0 && !failed) {
        failed = true;
        failure_message = "Failed while closing the input file";
    }
    if (bgzf_close(output) != 0 && !failed) {
        failed = true;
        failure_message = "HTSlib failed while closing the BGZF output";
    }

    if (failed) {
        std::remove(output_path.c_str());
        Rcpp::stop("%s: %s", failure_message, output_path);
    }
}

// [[Rcpp::export]]
void cpp_index_vcf(const std::string& vcf_path, const int n_threads) {
    const int status = tbx_index_build3(
        vcf_path.c_str(),
        nullptr,
        0,
        n_threads,
        &tbx_conf_vcf
    );
    if (status != 0) {
        Rcpp::stop("HTSlib could not build a tabix VCF index for %s (status %d)",
                   vcf_path, status);
    }
}

//' @export
// [[Rcpp::export]]
Rcpp::StringVector rcpp_make_column_of_vcf(
    const arma::mat& gp_t,
    const bool use_read_proportions,
    const bool use_state_probabilities,
    const bool add_x_2_cols,
    const arma::mat& read_proportions,
    const arma::mat& q_t,
    const arma::mat& x_t    
) {
    // ## write out genotype, genotype likelihood, and dosage
    // ##GT:GL:DS
    // ##FORMAT=<ID=GT:,Number=1,Type=String,Description="Best Guessed Genotype with posterior probability threshold of 0.9">
    // ##FORMAT=<ID=GL,Number=3,Type=Float,Description="Posterior probability of 0/0, 0/1, and 1/1">
    // ##FORMAT=<ID=DS,Number=1,Type=Float,Description="Dosage">
    // ## 1/1:0,0.054,0.946:1.946
    // ## add one samples worth of info to a VCF
    const int T = gp_t.n_cols;
    Rcpp::StringVector output(T);
    int t = 0;
    int k;
    char buffer[30];
    const int K = q_t.n_rows;
    for(t=0; t < T; t++) {
      output(t) = "";
      // first, get genotype at the start
      if (gp_t(0, t) < gp_t(1, t)) {
	if (gp_t(1, t) < gp_t(2, t)) {
	  if (0.90 <= gp_t(2, t)) {
	    output(t) = "1/1";
	  } else {
	    output(t) = "./.";
	  }
	} else {
	  if (0.90 <= gp_t(1, t)) {
	    output(t) = "0/1";	  
	  } else {
	    output(t) = "./.";
	  }
	}
      } else {
	if (gp_t(0, t) < gp_t(2, t)) {
	  if (0.90 <= gp_t(2, t)) {
	    output(t) = "1/1";	  	  
	  } else {
	    output(t) = "./.";
	  }
	} else {
	  if (0.90 <= gp_t(0, t)) {
	    output(t) = "0/0";
	  } else {
	    output(t) = "./.";
	  }
	}
      }
      // now, add on gp
      sprintf(buffer, ":%.3f,%.3f,%.3f:%.3f", gp_t(0, t), gp_t(1, t), gp_t(2, t), gp_t(1, t) + 2 * gp_t(2, t));
      output(t) += buffer;
      if (use_read_proportions) {
	sprintf(buffer, ":%.3f,%.3f,%.3f,%.3f",
		read_proportions(t, 0),
		read_proportions(t, 1),
		read_proportions(t, 2),
		read_proportions(t, 3));
	output(t) += buffer;	
      }
      if (use_state_probabilities) {
	// ok, here, can I do each, one at a time?
	output(t) += ":";
	for(k = 0; k < K; k++) {
	  // add to string
	  sprintf(buffer, "%.3f", q_t(k, t));
	  output(t) += buffer;
	  // add comma is not last one
	  if (k < (K - 1)) {
	    output(t) += ",";	    
	  }
	}
      }
      if (add_x_2_cols) {
	output(t) += ":";
	for(k = 0; k < 2; k++) {
	  // add to string
	  sprintf(buffer, "%.3f", x_t(k, t));
	  output(t) += buffer;
	  // add comma is not last one
	  if (k < (K - 1)) {
	    output(t) += ",";	    
	  }
	}
      }
    }
    return output;
}
