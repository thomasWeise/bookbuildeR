# the internal regexpression invoker for regular expressions without groups
.preprocess.regexp <- function(found, func, ...) {
  if(is.null(found)) {
    exit("Error in groupless regular expression processing: '",
         found, "' occurences.");
  }

  found <- as.vector(found);
  found <- force(found);
  if(is.non.empty.vector(found)) {
    result <- tryCatch(
        as.character(unname(unlist(vapply(
               X=found, FUN=func, FUN.VALUE = "", ...)))),
    error = function(e) exit("Error '", e, "' occured while invoking groupless regex processor."),
    warnining = function(e) exit("Warning '", e, "' occured while invoking groupless regex processor."));

    result <- force(result);
    return(result);
  }

  exit("Matches '", found, "' improperly coerced into vector?");
}


#' @title Pre-process a text with regular expression that contains no group
#' @description replace all instances of a regular expression in a text via a
#'   function
#' @param regex the regular expression
#' @param text the text
#' @param func the function which receives the matches
#' @param ... the parameters to be passed to \code{func}
#' @return the processed string
#' @importFrom ore ore.subst
#' @export preprocess.regexp
preprocess.regexp <- function(regex, text, func, ...) {
  result <- tryCatch(
    ore.subst(regex=regex, replacement=.preprocess.regexp,
              text=text, func=func, ..., all=TRUE),
    error=function(e) exit("Error '", e,
                           "' occured while invoking groupless regex processor on expression '",
                           regex, "'."),
    warnining=function(e) exit("Warning '", e,
                               "' occured while invoking groupless regex processor on expression '",
                               regex, "'."));
  result <- force(result);
  return(result);
}