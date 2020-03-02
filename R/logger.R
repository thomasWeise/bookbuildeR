# @title A logger function writing a log message to the output
# @description writs a log message with a date and time in front to the outpuut
# @param ... the arguments to be \code{cat}'ed to the ouput
#' @importFrom utilizeR makeLogger
.logger <- makeLogger(TRUE);

# @title Quit the Processing with an Error
# @description Well, .exit the current process, throw an error.
# @param ... the error message
.exit <- function(...) {
  .logger(...);
  q(save="no", status=1L);
}

.check.path <- function(path, type) {
  return(tryCatch(
      normalizePath(path, mustWork=TRUE),
      error=function(e) {
        .exit("Failed to normalize ",
             type, " path '",
             path,
             "' with message '",
             e,
             "'.")
      },
      warning=function(e) {
        .exit("Warning when trying to normalize ",
              type, " path '",
              path,
              "' with message '",
              e,
              "'.")
      }));
}

# @title Check that the file identified by the given path exists
# @description Check that the file identified by the given path exists.
# @param path the path to the file
# @param nonZeroSize enforce that the file size is not zero
# @return the normalized path
.check.file <- function(path, nonZeroSize=TRUE) {
  path <- .check.path(path, "file");
  if(!(file.exists(path))) {
    .exit("File '", path, "' does not exist.");
  }
  if(nonZeroSize && (file.size(path) <= 0L)) {
    .exit("Size of file '", path, "' is not bigger than zero.");
  }
  return(path);
}

# @title Check that the directory identified by the given path exists
# @description Check that the directory identified by the given path exists.
# @param path the path to the directory
# @return the normalized path
.check.dir <- function(path) {
  path <- .check.path(path, "directory");
  if(!(dir.exists(path))) {
    .exit("Directory '", path, "' does not exist.");
  }
  return(path);
}
