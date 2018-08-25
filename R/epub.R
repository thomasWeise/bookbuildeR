#' @title Invoke Pandoc to Produce a \code{EPUB} via LaTeX
#' @description Invoke Pandoc with the provided parameters.
#' @param sourceFile the path to the source file
#' @param destDir the destination directory
#' @param destName the base name of the destination file without extension
#' @param format.in the input format
#' @param standalone should we produce a stand-alone document?
#' @param tabstops the number of spaces with which we replace a tab character,
#'   or \code{NA} to not replace
#' @param toc.print print a table of contents?
#' @param toc.depth the depth of the table of content to print
#' @param crossref use pandoc-crossref?
#' @param bibliography do we have a bibliography?
#' @param numberSections should sections be numbered?
#' @param mathToGraphic should math be converted to graphics?
#' @return the canonical path to the destination file
#' @export pandoc.epub
#' @include pandoc.R
#' @include logger.R
pandoc.epub<- function(sourceFile,
                       destName=sub(pattern="\\..*", replacement="", x=basename(sourceFile)),
                       destDir=dirname(sourceFile),
                       format.in="markdown",
                       standalone=TRUE,
                       tabstops=2L,
                       toc.print=TRUE,
                       toc.depth=3L,
                       crossref=TRUE,
                       bibliography=TRUE,
                       numberSections=TRUE,
                       mathToGraphic=TRUE) {
  .logger("Now building a EPUB.");

  params <- list(sourceFile=sourceFile,
                 destDir=destDir,
                 destFileName=paste(destName, ".epub", sep="", collapse=""),
                 format.in=format.in,
                 format.out="epub3",
                 standalone=standalone,
                 tabstops=tabstops,
                 toc.print=toc.print,
                 toc.depth=toc.depth,
                 crossref=crossref,
                 bibliography=bibliography,
                 "--ascii",
                 "--self-contained");

  len <- length(params);
  if(numberSections) {
    params[[len]] <- "--number-sections";
    len <- len + 1L;
  }

  if(mathToGraphic) {
    params[[len]] <-"--filter=latex-formulae-filter";
    len <- len + 1L;
  }

  destFile <- do.call(pandoc.invoke, params);

  .logger("Finished building a EPUB output '", destFile, "'.");
  return(destFile);
}
