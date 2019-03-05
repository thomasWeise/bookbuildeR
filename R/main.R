#' @title Invoke the bookBuildeR Tool Chain
#' @description Invoke the complete bookBuildeR tool chain
#' @param sourceFile the path to the source file
#' @param destDir the destination directory
#' @param destName the base name of the destination file without extension
#' @param format.in the input format
#' @return a list where the names are the file types and the keys are the paths
#'   to the generated files: currently, we generate pdf, epub, and html output.
#' @include pandoc.R
#' @include logger.R
#' @include latex.R
#' @include epub.R
#' @include html.R
#' @include azw3.R
#' @include indexHTML.R
#' @export bookbuildeR.main
bookbuildeR.main <- function(sourceFile,
                             format.in="markdown",
                             destName="book",
                             destDir) {
  logger("Welcome to bookbuildeR."); # begin

  # check source file and destination directory
  sourceFile <- check.file(sourceFile);
  sourceDir <- check.dir(dirname(sourceFile));
  destDir <- check.dir(destDir);

  # create the temporary folder
  tempFile <- tempfile(tmpdir=sourceDir,
                       fileext=paste(".", format.in,
                                     sep="", collapse=""));

  # do the pre-processing
  result <- preprocess.doc(sourceFile=sourceFile,
                             destName=basename(tempFile));
  tempFile <- result$path;
  metadata <- result$meta;

  logger("Finished building the composed markdown document '",
          tempFile, "'.");

  bibliography <- metadata.hasBibliography(metadata);
  if(bibliography) {
    logger("According to the metadata, a bibliography is used, adding header to '",
           tempFile, "'.");
    con <- file(tempFile, "at");
    writeLines(text=c("", "# Bibliography {-}"),  con=con)
    close(con);
  } else {
    logger("According to the metadata, NO bibliography is used.");
  }

  pdf <- pandoc.latex(sourceFile=tempFile,
                      destName=destName,
                      destDir=destDir,
                      format.in=format.in,
                      bibliography=bibliography,
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
            "', it now should be very standard conform. Now creating EPUB output.");
  }

  epub <- pandoc.epub(sourceFile=tempFile,
                      destName=destName,
                      destDir=destDir,
                      format.in=format.in,
                      bibliography=bibliography,
                      metadata=metadata);
  logger("Finished building the book in EPUB format, generated file '",
          epub, "'. Now creating HTML-5 output.");

  html <- pandoc.html(sourceFile=tempFile,
                      destName=destName,
                      destDir=destDir,
                      format.in=format.in,
                      bibliography=bibliography,
                      metadata=metadata);
  logger("Finished building the book in HTML format, generated file '",
         html, "'. Now creating azw3 output.");

  azw3 <- calibre.azw3(epubFile=epub,
                       destName=destName,
                       destDir=destDir);
  logger("Finished building the book in AZW3 format, generated file '",
         azw3, "'. Now creating index.html");

  files <- list( list(path=pdf,
                      desc="in the <a href=\"http://en.wikipedia.org/wiki/Pdf\">PDF</a>&nbsp;format for reading on the computer and/or printing (but please don't print this, save paper)"),
                 list(path=epub,
                      desc="in the <a href=\"http://en.wikipedia.org/wiki/EPUB\">EPUB3</a>&nbsp;format for reading on most mobile phones or other hand-held devices"),
                 list(path=azw3,
                      desc="in the <a href=\"http://en.wikipedia.org/wiki/Kindle_File_Format\">AZW3</a>&nbsp;format for reading on <a href=\"http://en.wikipedia.org/wiki/Amazon_Kindle\">Kindle</a> and similar devices"),
                 list(path=html,
                      desc="in a stand-alone <a href=\"http://en.wikipedia.org/wiki/HTML5\">HTML5</a>&nbsp;format for reading in a web browser on any device"));

  index <- index.html(files=files,
                      destDir=destDir,
                      metadata=metadata);
  logger("Finished index.html, generated file '",
         index, "'. Now cleaning up");

  unlink(tempFile, force=TRUE);
  logger("Finished deleting temporary source '",
          tempFile, "' - we are done.");
  return(list(pdf=pdf, epub=epub, html=html, azw3=azw3,
              index=index));
}
