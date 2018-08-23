#' @title Invoke Pandoc
#' @description Invoke Pandoc with the provided parameters.
#' @param sourceFile the path to the source file
#' @param destFile the path to the destination file
#' @param ... the arguments to be passed to pandoc
#' @return the canonical path to the destination file
#' @include logger.R
invoke.pandoc <- function(sourceFile, destFile, ...) {
  # get the canonical path of the source file
  sourceFile <- normalizePath(sourceFile, mustWork=TRUE);
  if(!file.exists(sourceFile)) {
    exit("Source file '", sourceFile, "' does not exist.");
  }

  # get the source directory
  sourceDir <- dirname(sourceFile);

  # create dest file
  destFile <- normalizePath(destFile, mustWork = FALSE);
  if(file.exists(destFile)) {
    exit("Destination file '", destFile, "' already exists.");
  }

  destDir <- dirname(destFile);
  dir.create(destDir, showWarnings = FALSE, recursive=TRUE);
  if(!dir.exists(destDir)) {
    exit("Destination directory '", destDir, "' could not be created.");
  }
  destDir  <- normalizePath(destDir, mustWork = TRUE);
  destFile <- normalizePath(file.path(destDir, basename(destFile)), mustWork = FALSE);

  .logger("Applying pandoc to create '", destFile, "' from '", sourceFile, "'.");

  wd <- getwd();
  setwd(sourceDir);
  args <- as.vector(unname(unlist(list(..., sourceFile, "-o", destFile), recursive = TRUE)));

  result <- system2("pandoc", args=args);

  if(result != 0L) {
    exit("pandoc has failed with error code ", result, " for arguments '",
         paste(args, sep=" ", collapse=" "), "' in directory '", sourceDir, "'.");
  }

  .logger("pandoc has succeeded for arguments '",
         paste(args, sep=" ", collapse=" "), "' in directory '", sourceDir, "'.");
  setwd(wd);
}
