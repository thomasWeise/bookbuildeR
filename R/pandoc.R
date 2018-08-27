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
#' @param ... the arguments to be passed to pandoc
#' @return the canonical path to the destination file
#' @include logger.R
#' @export pandoc.invoke
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
                          ...) {
  # get the canonical path of the source file
  sourceFile <- check.file(sourceFile);
  # get the source directory
  sourceDir <- dirname(sourceFile);

  # create dest file
  destFile <- normalizePath(file.path(destDir, destFileName), mustWork = FALSE);
  if(file.exists(destFile)) {
    exit("Destination file '", destFile, "' already exists.");
  }

  # get destination directory
  destDir <- dirname(destFile);
  dir.create(destDir, showWarnings = FALSE, recursive=TRUE);
  destDir  <- check.dir(destDir);
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
                       sep="+", collapse="+");
  }
  args <- c(paste("--from=", format.in, sep="", collapse=""),
            paste("--write=", format.out, sep="", collapse=""),
            paste("--output=", destFile, sep="", collapse=""),
            "--fail-if-warnings");

  # add some standard argumens
  if(!is.na(tabstops)) {
    args <- c(args, paste("--tab-stop=", tabstops, sep="", collapse=""));
  }
  if(standalone) {
    args <- c(args, "--standalone");
  }
  if(toc.print) {
    args <- c(args, "--table-of-contents");
    if(!is.na(toc.depth)) {
      args <- c(args, paste("--toc-depth=", toc.depth, sep="", collapse=""));
    }
  }

  if((!(is.null(crossref) || is.na(crossref))) && crossref) {
    args <- c(args, "--filter pandoc-crossref");
  }

  if((!(is.null(bibliography) || is.na(bibliography))) && bibliography) {
    args <- c(args, "--filter pandoc-citeproc");
  }

  args <- c(args, list(...));
  args <- c(args, sourceFile);
  args <- as.vector(unname(unlist(args, recursive = TRUE)));

  result <- system2("pandoc", args=args);

  if(result != 0L) {
    exit("pandoc has failed with error code ", result, " for arguments '",
         paste(args, sep=" ", collapse=" "), "' in directory '", sourceDir, "'.");
  }

  setwd(wd);

  destFile <- check.file(destFile);
  .logger("pandoc has succeeded for arguments '",
         paste(args, sep=" ", collapse=" "),
         "' in directory '",
         sourceDir, "' and produced file '",
         destFile, "'.");

  return(destFile);
}
