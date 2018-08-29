#' @title Invoke Pandoc to Produce a \code{pdf} via LaTeX
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
#' @param topLevelDivision the top-level division
#' @param numberSections should sections be numbered?
#' @param metadata the metadata
#' @return the canonical path to the destination file
#' @export pandoc.latex
#' @include pandoc.R
#' @include logger.R
#' @include templates.R
pandoc.latex <- function(sourceFile,
                         destName=sub(pattern="\\..*", replacement="", x=basename(sourceFile)),
                         destDir=dirname(sourceFile),
                         format.in="markdown",
                         standalone=TRUE,
                         tabstops=2L,
                         toc.print=TRUE,
                         toc.depth=3L,
                         crossref=TRUE,
                         bibliography=TRUE,
                         topLevelDivision="chapter",
                         numberSections=TRUE,
                         metadata=NULL) {
  .logger("Now building a pdf output via LaTeX.");

  params <- list(sourceFile=sourceFile,
                 destDir=destDir,
                 destFileName=paste(destName, ".pdf", sep="", collapse=""),
                 format.in=format.in,
                 format.out="latex",
                 standalone=standalone,
                 tabstops=tabstops,
                 toc.print=toc.print,
                 toc.depth=toc.depth,
                 crossref=crossref,
                 bibliography=bibliography,
                 paste("--top-level-division=", topLevelDivision, sep="", collapse=""));

  len <- length(params);
  if(numberSections) {
    params[[len]] <- "--number-sections";
    len <- len + 1L;
  }

  # see if a template has been specified
  template <- NA_character_;
  if((!(is.na(metadata) || is.null(metadata))) &&
     (is.list(metadata)) && (length(metadata) > 0L)) {
    # ok, we have metadata
    temp <- metadata$template.latex;
    if(!(is.na(temp) || is.null(temp))) {
      .logger("Found LaTeX template specification in metata for template '",
              temp, "'.");
      template <- template.load(template=temp, dir=dirname(srcfile));
      params$template <- template;
      len <- len + 1L;
    }
  }

  destFile <- do.call(pandoc.invoke, params);

  .logger("Finished building a pdf output '", destFile, "' via LaTeX.");
  return(destFile);
}
