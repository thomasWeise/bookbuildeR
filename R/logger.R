#' @importFrom utilizeR makeLogger
.logger <- makeLogger(TRUE);

#' @title Quit the Processing with an Error
#' @description Well, exit the current process, throw an error.
#' @param ... the error message
#' @export exit
exit <- function(...) {
  .logger(...);
  q(status=1L);
}

.check.path <- function(path, type) {
  return(tryCatch(
      normalizePath(path, mustWork=TRUE),
      error=function(e) {
        exit("Failed to normalize ",
             type, " path '",
             path,
             "' with message '",
             e,
             "'.")
      },
      warning=function(e) {
        exit("Warning when trying to normalize ",
              type, " path '",
              path,
              "' with message '",
              e,
              "'.")
      }));
}

#' @title Check that the file identified by the given path exists
#' @description Check that the file identified by the given path exists.
#' @param path the path to the file
#' @return the normalized path
#' @export check.file
check.file <- function(path) {
  ret <- .check.path(path, "file");
  if(!(file.exists(ret))) {
    exit("File '", ret, "' does not exist.");
  }
  return(ret);
}

#' @title Check that the directory identified by the given path exists
#' @description Check that the directory identified by the given path exists.
#' @param path the path to the directory
#' @return the normalized path
#' @export check.dir
check.dir <- function(path) {
  ret <- .check.path(path, "directory");
  if(!(dir.exists(ret))) {
    exit("Directory '", ret, "' does not exist.");
  }
  return(ret);
}
