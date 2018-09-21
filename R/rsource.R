#' @title Execute the provided R file and return the output
#' @description Execute the R file provided as input and return a string
#'   containing all of its output. If the code prints output, say with
#'   \code{cat}, e.g., as in \code{"cat(5);cat(6)"}, then that output is
#'   returned as single collapsed string. If the code just returns a value,
#'   e.g., \code{"5"}, then this value will be converted to a collapsed string
#'   and returned.
#'   This is similar to what \code{r.exec} is doing, but it obtains its input
#'   from a file.
#' @param path the path
#' @param basePath the base path
#' @export r.source
#' @include rexec.R
#' @include logger.R
r.source <- function(path, basePath=NULL) {
  if(!is.null(basePath)) {
    path2 <- check.file(file.path(basePath, path));
    logger("resolved r script path '", path,
           "' versus path '", basePath,
           "' for r script execution, got '", path2, "'.");
    path <- path2;
  }
  path <- check.file(path);
  path <- force(path);
  
  logger("reading r source from file '", path, "'.");
  handle <- file(path, "rt");
  text <- readLines(handle);
  close(handle);
  logger("finished reading r source from file '", path, "', now executing.");
  
  return(r.exec(text));
}
