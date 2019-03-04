#' @title Invoke Pandoc to Produce a \code{HTML-5} File
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
#' @param metadata the metadata
#' @return the canonical path to the destination file
#' @export pandoc.html
#' @include pandoc.R
#' @include logger.R
#' @include templates.R
#' @importFrom utilizeR is.non.empty.list is.non.empty.string
pandoc.html<- function(sourceFile,
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
                       metadata=NULL) {
  logger("Now building HTML-5.");

  sourceFile <- check.file(sourceFile);
  destDir <- check.dir(destDir);

  # the basic parameters
  params <- list(sourceFile=sourceFile,
                 destFileName=paste(destName, ".html", sep="", collapse=""),
                 destDir=destDir,
                 format.in=format.in,
                 format.out="html5",
                 standalone=standalone,
                 tabstops=tabstops,
                 toc.print=toc.print,
                 toc.depth=toc.depth,
                 crossref=crossref,
                 bibliography=bibliography,
                 template=NA_character_,
                 numberSections=numberSections,
                 "--katex",
                 "--ascii",
                 "--html-q-tags");


  # see if a template has been specified
  if(is.non.empty.list(metadata)) {
    # ok, we have metadata
    template <- metadata$template.html;
    template <- force(template);
    if(is.non.empty.string(template)) {
      logger("Found HTML template specification in metadata for template '",
              template, "'.");
      template <- template.load(template, dirname(sourceFile));
      if(is.non.empty.string(template)) {
        template <- force(template);
        params$template <- template;
      }
    } else {
      logger("No HTML template specified in metadata.");
    }
  }

  len <- length(params);

  if(isTRUE(standalone)) {
    len <- len + 1L;
    params[[len]] <- "--self-contained";
  }

  destFile <- do.call(pandoc.invoke, params);

  logger("Finished building a html5 output '", destFile, "'.");
  return(destFile);
}
