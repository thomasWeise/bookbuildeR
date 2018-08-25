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

# the internal strict error handler
.failed.to.normalize <- function(e) {
  exit("Failed to normalize path '",
       path,
       "' with message '",
       e,
       "'.");
}

.check.path <- function(path) {
  return(tryCatch(
      normalizePath(path, mustWork=TRUE),
      error=.failed.to.normalize,
      warning=.failed.to.normalize));
}

#' @title Check that the file identified by the given path exists
#' @description Check that the file identified by the given path exists.
#' @param path the path to the file
#' @return the normalized path
#' @export check.file
check.file <- function(path) {
  ret <- .check.path(path);
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
  ret <- .check.path(path);
  if(!(dir.exists(ret))) {
    exit("Directory '", ret, "' does not exist.");
  }
  return(ret);
}
