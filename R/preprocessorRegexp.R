
# the internal regexpression invoker
#' @importFrom ore groups
.preprocess.regexp.outer <- function(found, func, ...) {
  if(is.null(found)) {
    exit("Error in regular expression processing.");
  }

  g <- groups(found);
  if(is.null(g)) {
    exit("Error in regular expression processing.");
  }

  n <- nrow(g);
  if(n > 0L) {
    return(unlist(unname(vapply(X=seq_len(n),
                  FUN=function(i) {
                    return(func(unname(unlist(g[i, ])), ...));
                  }, FUN.VALUE = ""))));
  } else {
    exit("Incorrect number of rows in regular expression match: ", n);
  }
}

#' @title Pre-process a text with regular expression
#' @description replace all instances of a regular expression in a text via a
#'   function
#' @param regex the regular expression
#' @param text the text
#' @param func the function
#' @param ... the parameters to be passed to \code{func}
#' @return the processed string
#' @importFrom ore ore.subst
#' @export preprocess.regexp
preprocess.regexp <- function(regex, text, func, ...) {
  return(ore.subst(regex=regex, replacement=.preprocess.regexp.outer,
                   text=text, func=func, ..., all=TRUE));
}
