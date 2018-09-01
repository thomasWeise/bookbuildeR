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
#' @importFrom utilizeR is.non.empty.list is.non.empty.list
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
  logger("Now building a pdf output via LaTeX.");

  sourceFile <- check.file(sourceFile);
  destDir <- check.dir(destDir);
  
  # the basic parameters
  params <- list(sourceFile=sourceFile,
                 destFileName=paste(destName, ".pdf", sep="", collapse=""),
                 destDir=destDir,
                 format.in=format.in,
                 format.out="latex",
                 standalone=standalone,
                 tabstops=tabstops,
                 toc.print=toc.print,
                 toc.depth=toc.depth,
                 crossref=crossref,
                 bibliography=bibliography,
                 template=NA_character_);

  # see if a template has been specified
  if(is.non.empty.list(metadata)) {
    # ok, we have metadata
    template <- metadata$template.latex;
    template <- force(template);
    if(is.non.empty.string(template)) {
      logger("Found LaTeX template specification in metadata for template '",
              template, "'.");
      template <- template.load(template, dirname(sourceFile));
      if(is.non.empty.string(template)) {
        template <- force(template);
        params$template <- template;
      }
    } else {
      logger("No LaTeX template specified in metadata.");
    }
  }

  len <- length(params);

  len <- len + 1L;
  params[[len]] <- paste("--top-level-division=", topLevelDivision, sep="", collapse="");

  if(numberSections) {
    len <- len + 1L;
    params[[len]] <- "--number-sections";
  }

#  logger("Invoking pandoc.invoke with parameters '",
#          paste(params, sep=", ", collapse=", "),
#          "'.");
  destFile <- do.call(pandoc.invoke, params);

  logger("Finished building a pdf output '", destFile, "' via LaTeX.");
  return(destFile);
}
