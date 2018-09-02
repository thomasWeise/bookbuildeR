#' @title Pre-Process a Document File
#' @description Pre-process the root file of a hierarchically structured
#'   document to a single monolithic output.
#' @param sourceFile the source file
#' @param destName the name of the destination file (to be created in the same
#'   folder as the source file)
#' @param bibliography the bibliography
#' @return the canonical path to the destination file
#' @include logger.R
#' @include preprocessorInput.R
#' @include preprocessorPlain.R
#' @include preprocessorTextblock.R
#' @export preprocess.doc
preprocess.doc <- function(sourceFile, destName, bibliography=TRUE) {
  # get the canonical path of the source file
  sourceFile <- check.file(sourceFile);
  sourceDir <- check.dir(dirname(sourceFile));

  # create dest file
  destFile <- normalizePath(file.path(sourceDir, destName), mustWork = FALSE);
  if(file.exists(destFile)) {
    exit("Destination file '", destFile, "' already exists.");
  }

  # load the text
  text <- preprocess.input(sourceFile);
  
  logger("Now preprocessing the ",
          nchar(text), " characters loaded from '",
          sourceFile, "'.");
  
  # do the pre-processing
  text <- preprocess.plain(text);
  text <- preprocess.textblocks(text);
  
  text <- unname(unlist(strsplit(
              text, split="\n", fixed = TRUE)));
  
  logger("Obtained ", length(text),
          " lines of text from preprocessing '",
          sourceFile, "', now writing to '",
          destFile, "'.");
  
  output <- file(destFile, open="wt");
  writeLines(text=text, con=output);
  
  # add proper bibliography section
  if(isTRUE(bibliography)) {
    writeLines(text=c("", "# Bibliography {-}"),  con=output)
  }
  
  close(output);
  destFile <- check.file(destFile);

  logger("Finished pre-processing contents from main source file '",
         sourceFile,
         "' to output file '",
         destFile,
         "'.");
  return(destFile);
}
