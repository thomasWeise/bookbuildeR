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
  sourceFile <- normalizePath(sourceFile, mustWork=FALSE);
  if(!file.exists(sourceFile)) {
    exit("Source file '", sourceFile, "' does not exist.");
  }

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
  if(!dir.exists(destDir)) {
    exit("Destination directory '", destDir, "' could not be created.");
  }
  destDir  <- normalizePath(destDir, mustWork = TRUE);
  destFile <- normalizePath(file.path(destDir, basename(destFile)), mustWork = FALSE);

  # find the location of pandoc
  pandoc <- "pandoc";
  home <- Sys.getenv(x="HOME", unset=NA);
  pandoc.via.cabal <- FALSE;
  if((!(is.na(home) || is.null(home))) && (length(home) == 1L) && (nchar(home) > 0L)) {
    # we test whether it has been installed via cabal
    test <- normalizePath(file.path(home, ".cabal", "bin", "pandoc"), mustWork = FALSE);
    if(file.exists(test)) {
      pandoc <- test;
      pandoc.via.cabal <- TRUE;
    }
  }
  if(!(pandoc.via.cabal)) {
    # maybe the cabal folder is under root, which may be the case in a docker
    # image
    test <- "/root/.cabal/bin/pandoc";
    if(file.exists(test)) {
      pandoc <- test;
      pandoc.via.cabal <- TRUE;
    }
  }

  # setup the environment to point to cabal, if it exists
  env <- character();
  if(pandoc.via.cabal) {
    .logger("Using pandoc executable '", pandoc, "' from cabal.");
    env.path <- Sys.getenv(x="PATH", unset=NA);
    cabal.path <- dirname(pandoc);
    if((nchar(cabal.path) > 0L) && (dir.exists(cabal.path))) {
      # if so, we need to add the cabal binaries folder to the path
      env <- c(paste("PATH=", env.path, ":", cabal.path, ";", sep="", collapse=""));
    }
  } else {
    .logger("Using plain pandoc, did not detect cabal-based installation.");
  }

  .logger("Applying pandoc to create '", destFile, "' from '", sourceFile, "'.");

  wd <- getwd();
  setwd(sourceDir);
  args <- c(paste("--read=", format.in, sep="", collapse=""),
            paste("--write=", format.out, sep="", collapse=""),
            paste("--output=", destFile, sep="", collapse=""),
            "--fail-if-warnings");

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

  result <- system2(pandoc, args=args, env=env);

  if(result != 0L) {
    exit(pandoc, " has failed with error code ", result, " for arguments '",
         paste(args, sep=" ", collapse=" "), "' in directory '", sourceDir, "'.");
  }

  .logger(pandoc, " has succeeded for arguments '",
         paste(args, sep=" ", collapse=" "), "' in directory '", sourceDir, "'.");
  setwd(wd);
}
