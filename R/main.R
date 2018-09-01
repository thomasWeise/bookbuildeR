#' @title Invoke the bookBuildeR Tool Chain
#' @description Invoke the complete bookBuildeR tool chain
#' @param sourceFile the path to the source file
#' @param destDir the destination directory
#' @param destName the base name of the destination file without extension
#' @param format.in the input format
#' @return a list where the names are the file types and the keys are the paths
#'   to the generated files
#' @include pandoc.R
#' @include logger.R
#' @include latex.R
#' @include epub.R
#' @include readmeta.R
#' @export bookbuildeR.main
bookbuildeR.main <- function(sourceFile,
                             format.in="markdown",
                             destName="book",
                             destDir) {
  logger("Welcome to bookbuildeR."); # begin

  # check source file and destination directory
  sourceFile <- check.file(sourceFile);
  destDir <- check.dir(destDir);

  # create the temporary folder
  tempFile <- tempfile(tmpdir=dirname(sourceFile),
                       fileext=paste(".", format.in,
                                     sep="", collapse=""));

  # do the pre-processing
  tempFile <- preprocess.doc(sourceFile=sourceFile,
                             destName=basename(tempFile));

  logger("Finished building the composed markdown document '",
          tempFile, "'.");

  metadata <- metadata.read(srcfile=tempFile);

  pdf <- pandoc.latex(sourceFile=tempFile,
                      destName=destName,
                      destDir=destDir,
                      format.in=format.in,
                      metadata=metadata);

  logger("Finished generating pdf file '",
          pdf,
          "' via pandoc/LaTeX tool chain, now filtering it.");

  ret <- system2("filterPdf.sh", c(pdf));
  if(ret != 0L) {
    exit("Failed to filter the pdf file '",
         pdf, "' - it must somehow be corrupt!");
  } else {
    logger("Successfully filtered pdf file '",
            pdf,
            "', it now should be very standard conform.");
  }

  epub <- pandoc.epub(sourceFile=tempFile,
                      destName=destName,
                      destDir=destDir,
                      format.in=format.in,
                      metadata=metadata);
  logger("Finished building the book in EPUB format, generated file '",
          epub, "'.");

  unlink(tempFile, force=TRUE);
  logger("Finished deleting temporary source '",
          tempFile, "' - we are done.");
  return(list(pdf=pdf, epub=epub));
}
