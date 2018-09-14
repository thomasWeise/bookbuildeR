.open      <- "{";
.open.esc  <- ore.escape(.open);
.close     <- "}";
.close.esc <- ore.escape(.close);

#' @title Create a Regular Expression for a LaTeX-Style Command
#' @description Create a regular expression that can parse LaTeX commands.
#' @param prefix the prefix of the command
#' @param n the number of parameters
#' @param stripWhiteSpace should the white space aroung the command be stripped
#' @export preprocess.command.regexp
#' @importFrom ore ore ore.escape
#' @importFrom utilizeR is.non.empty.string
preprocess.command.regexp <- function(prefix="", n=1L, stripWhiteSpace=FALSE) {
  # enforce parameters
  prefix          <- force(prefix);
  n               <- force(n);
  stripWhiteSpace <- force(stripWhiteSpace);
  
  # check parameters
  if(!(is.non.empty.string(prefix))) {
    exit("Invalid regular expression.");
  }
  
  # First, we build the regular expression, which makes sure that braces numbers
  # match.
  # Create the command the prefix.
  .regexpr <- ore.escape(paste("\\", prefix, sep="", collapse=""));
  .regexpr <- force(.regexpr);

  # Add parameters.
  if(n > 0L) {
    .regexpr <- paste(.regexpr, paste(vapply(X=seq_len(n),
                   FUN=function(i) {
                     paste("(?<exp", letters[i], ">",
                           .open.esc,
                           "(?:(?>[^",
                           .open.esc, .close.esc,
                           "]+)|\\g<exp",
                           letters[i],
                           ">)*",
                           .close.esc,
                           ")",sep="", collapse="");
                   }, FUN.VALUE = ""), sep="", collapse=""),
                sep="", collapse="");
    .regexpr <- force(.regexpr);
  }
  
  # Add potential whitespace strippers.
  if(stripWhiteSpace) {
    .regexpr <- paste("\\s*", .regexpr, "\\s*", sep="", collapse="");
    .regexpr <- force(.regexpr);
  }
  
  .regexpr <- ore(.regexpr);
  .regexpr <- force(.regexpr);
  return(.regexpr);
}

# strip white space and delimiters
.preprocess.command.strip <- function(t) {
  t <- trimws(as.character(t));
  if(startsWith(t, .open) && endsWith(t, .close)) {
    len <- nchar(t);
    if(len <= 2L) {
      return("");
    }
    t <- trimws(substr(t, 2L, (len - 1L)));
  }
  t <- force(t);
  return(t);
}



#' @title Pre-process a text with regular expression that contains at least one group
#' @description replace all instances of a regular expression in a text via a
#' function
#' @param regex the regular expression
#' @param text the text
#' @param func the function which receives the strings matched to the groups as
#' vector
#' @param ... the parameters to be passed to \code{func}
#' @return the processed string
#' @importFrom ore ore.subst
#' @export preprocess.command
preprocess.command <- function(regex, text, func, ...) {
  result <- tryCatch(
    ore.subst(regex=regex, replacement=.preprocessor.regexp.invoke,
              preprocessor=.preprocess.command.strip,
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


# A Function that can Santize and Preprocess the Groups
#' @importFrom ore groups
.preprocessor.regexp.invoke <- function(found, func, preprocessor=trimws, ...) {
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
                                          t <- vapply(X=unname(unlist(g[i, ])),
                                                      FUN=preprocessor,
                                                      FUN.VALUE = "");
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