
# the internal regexpression invoker for regular expressions with groups
#' @importFrom ore groups
.preprocess.regexp.outer.groups <- function(found, func, ...) {
  if(is.null(found)) {
    exit("Error in groupfull regular expression processing: '",
         found, "' occurences.");
  }

  found <- force(found);
  g <- groups(found);
  g <- force(g);
  if(is.null(g)) {
    exit("Error in groupfull regular expression processing: '",
         found, "' has NULL groups.");
  }
  
  n <- nrow(g);
  n <- force(n);
  if(n > 0L) {
    result <- tryCatch(
                as.character(unname(unlist(vapply(X=seq_len(n),
                  FUN=function(i) {
                    t <- unname(unlist(g[i, ]));
                    t <- force(t);
                    t <- func(t, ...);
                    t <- force(t);
                    return(t);
                }, FUN.VALUE = "")))),
    error=function(e) exit("Error '", e, "' occured while invoking regex processor."),
    warnining=function(e) exit("Warning '", e, "' occured while invoking regex processor."));
    result <- force(result);
    return(result);
  }
 exit("Zero group rows in regular expression match '", g, "'.");
}

# the internal regexpression invoker for regular expressions without groups
.preprocess.regexp.outer.no.groups <- function(found, func, ...) {
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

#' @title Pre-process a text with regular expression that contains at least one group
#' @description replace all instances of a regular expression in a text via a
#'   function
#' @param regex the regular expression
#' @param text the text
#' @param func the function which receives the strings matched to the groups as
#'   vector
#' @param ... the parameters to be passed to \code{func}
#' @return the processed string
#' @importFrom ore ore.subst
#' @export preprocess.regexp.groups
preprocess.regexp.groups <- function(regex, text, func, ...) {
  result <- tryCatch(
    ore.subst(regex=regex, replacement=.preprocess.regexp.outer.groups,
                     text=text, func=func, ..., all=TRUE),
    error=function(e) exit("Error '", e,
                           "' occured while invoking grouplfull regex processor on expression '",
                           regex, "'."),
    warnining=function(e) exit("Warning '", e,
                               "' occured while invoking groupfull regex processor on expression '",
                               regex, "'."));
  result <- force(result);
  return(result);
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
#' @export preprocess.regexp.no.groups
preprocess.regexp.no.groups <- function(regex, text, func, ...) {
  result <- tryCatch(
    ore.subst(regex=regex, replacement=.preprocess.regexp.outer.no.groups,
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
