#' @title Invoke Pandoc
#' @description Invoke Pandoc with the provided parameters.
#' @param sourceFile the path to the source file
#' @param destFileName the path to the destination file
#' @param destDir the destination directory
#' @param format.in the input format
#' @param format.out the output format
#' @param standalone should we produce a stand-alone document?
#' @param tabstops the number of spaces with which we replace a tab character,
#'   or \code{NA} to not replace
#' @param toc.print print a table of contents?
#' @param toc.depth the depth of the table of content to print
#' @param crossref use pandoc-crossref?
#' @param bibliography do we have a bibliography?
#' @param template the template to be used, or \code{NA} if none
#' @param numberSections should sections be numbered?
#' @param ... the arguments to be passed to pandoc
#' @return the canonical path to the destination file
#' @include logger.R
#' @export pandoc.invoke
#' @importFrom utilizeR is.non.empty.string is.not.na.or.null
pandoc.invoke <- function(sourceFile,
                          destFileName,
                          destDir=dirname(sourceFile),
                          format.in="markdown",
                          format.out="latex",
                          standalone=TRUE,
                          tabstops=2L,
                          toc.print=TRUE,
                          toc.depth=3L,
                          crossref=TRUE,
                          bibliography=TRUE,
                          template=NA_character_,
                          numberSections=TRUE,
                          ...) {
  # get the canonical path of the source file
  sourceFile <- .check.file(sourceFile);
  # get the source directory
  sourceDir <- dirname(sourceFile);

  # create dest file
  destFile <- normalizePath(file.path(destDir, destFileName), mustWork = FALSE);
  if(file.exists(destFile)) {
    .exit("Destination file '", destFile, "' already exists.");
  }

  # get destination directory
  destDir <- dirname(destFile);
  dir.create(destDir, showWarnings = FALSE, recursive=TRUE);
  destDir  <- .check.dir(destDir);
  destFile <- normalizePath(file.path(destDir, basename(destFile)), mustWork = FALSE);

  .logger("Applying pandoc to create '", destFile, "' from '", sourceFile, "'.");

  wd <- getwd();
  setwd(sourceDir);
  if(startsWith(format.in, "markdown")) {
    format.in <- paste(format.in,
                       "definition_lists",
                       "smart",
                       "fenced_code_blocks",
                       "fenced_code_attributes",
                       "line_blocks",
                       "inline_code_attributes",
                       "latex_macros",
                       "implicit_figures",
                       "pipe_tables",
                       "raw_attribute",
                       sep="+", collapse="+");
  }
  args <- c(paste("--from=", format.in, sep="", collapse=""),
            paste("--write=", format.out, sep="", collapse=""),
            paste("--output=", destFile, sep="", collapse=""),
            "--fail-if-warnings");

  if(is.not.na.or.null(tabstops)) { # add some standard argumens
    args <- c(args, paste("--tab-stop=", tabstops, sep="", collapse=""));
  }

  # should the document be stand-alone
  if(isTRUE(standalone)) {
    args <- c(args, "--standalone");
  }

  # number sections
  if(isTRUE(numberSections)) {
    args <- c(args, "--number-sections");
  }

  # should we print the table of contents?
  if(isTRUE(toc.print)) {
    args <- c(args, "--table-of-contents");
    if(is.not.na.or.null(toc.depth)) {
      args <- c(args, paste("--toc-depth=", toc.depth, sep="", collapse=""));
    }
  }

  # has a template been defined?
  if(is.non.empty.string(template)) {
    args <- c(args, paste("--template=", template, sep="", collapse=""));
  }

  # should we use the crossref filter?
  if(isTRUE(crossref)) {
    args <- c(args, "--filter pandoc-crossref");
  }

  # should we have a bibliography?
  if(isTRUE(bibliography)) {
    args <- c(args, "--filter pandoc-citeproc");
  }

  # add the additional parameters
  args <- c(args, list(...));
  args <- c(args, sourceFile);
  args <- as.vector(unname(unlist(args, recursive = TRUE)));

  # invoke the pandoc program
  result <- system2("pandoc", args=args);

  if(result != 0L) {
    .exit("pandoc has failed with error code ", result, " for arguments '",
         paste(args, sep=" ", collapse=" "), "' in directory '", sourceDir, "'.");
  }

  setwd(wd);

  destFile <- .check.file(destFile);
  .logger("pandoc has succeeded for arguments '",
         paste(args, sep=" ", collapse=" "),
         "' in directory '",
         sourceDir, "' and produced file '",
         destFile, "'.");

  return(destFile);
}
