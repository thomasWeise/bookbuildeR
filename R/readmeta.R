#' @title A very Primitive Method to Read YAML Metadata Key-Value Pairs
#' @description A very primitive method to read the key-value pairs from YAML
#'   metadata in a file.
#' @param srcfile the file to read from
#' @return a list with key-value pairs from the YAML metadata
#' @export metadata.read
metadata.read <- function(srcfile) {
  srcfile <- check.file(srcfile);
  
  tryCatch({
    handle <- file(srcfile, "rt");
  })
}