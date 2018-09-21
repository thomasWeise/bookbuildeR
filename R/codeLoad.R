#' @title Read Code from a File according to Parameters given as Strings
#' @description Read snippets of code from a file. Similar to \code{code.read},
#'   but interpret the parameters from strings.
#' @param path the path to the file to read
#' @param lines a set of selected lines, given as R integer vector expression
#'   string
#' @param tags the list of marking start and end given as string with
#'   comma-separated values
#' @param basePath the base path against which the \code{path} should be
#'   resolved
#' @export code.load
#' @include logger.R
#' @include codeRead.R
#' @importFrom utilizeR is.non.empty.string is.non.empty.vector
code.load <- function(path, lines="", tags="", basePath=NULL) {
  if(!is.null(basePath)) {
    path2 <- check.file(file.path(basePath, path));
    logger("resolved code path '", path,
           "' versus path '", basePath,
           "' for code loading, got '", path2, "'.");
    path <- path2;
  }
  path <- force(path);

  # get the line selection, if any
  res <- lines;
  old <- lines;
  lines <- NULL;
  if(is.non.empty.string(res)) {
    res <- trimws(res);
    if(nchar(res) > 0L) {
      res <- paste("c(", res, ")", sep="", collapse="");
      res <- force(res);
      res <- parse(text=res);
      res <- force(res);
      res <- eval(res);
      res <- force(res);
      if(is.non.empty.vector(res)) {
        res <- as.integer(res);
        if(is.integer(res)) {
          lines <- res;
        } else {
          exit("lines expression '", old,
               "' cannot be translated to an integer vector for file '",
               path, "'.");
        }
      } else {
        exit("lines expression '", old,
             "' cannot be translated to an vector for file '",
             path, "'.");
      }
    }
  }
  lines <- force(lines);

  # get the tag selection, if any
  res <- tags;
  old <- tags;
  tags <- NULL;
  if(is.non.empty.string(res)) {
    res <- trimws(res);
    if(nchar(res) > 0L) {
      res <- strsplit(res, ",", fixed=TRUE)[[1L]];
      if(is.non.empty.vector(res)) {
        tags <- res;
      } else {
        exit("tags expression '", old,
             "' cannot be translated to an vector for file '",
             path, "'.");
      }
    }
  }
  tags <- force(tags);

  return(code.read(path=path, lines=lines, tags=tags));
}

# the internal wrapper
.code.load.wrap <- function(vec, basePath=NULL) {
  code.load(vec[1L], vec[2L], vec[3L], basePath);
}
