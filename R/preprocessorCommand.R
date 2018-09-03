#' @title Create a Command based on a Regular Expression
#' @description Create a function that can be applied to a string and performs a
#'   regular expression replacement based on invoking a function \code{func}.
#' @param prefix the prefix of the command
#' @param n the number of parameters
#' @param func the function to be invoked
#' @param char.open the opening character
#' @param char.close the closing character
#' @param stripWhiteSpace should the white space aroung the command be stripped
#' @export preprocess.command
#' @importFrom ore groups ore ore.escape ore.subst
preprocess.command <- function(prefix="", n=1L,
                               func,
                               char.open="{",
                               char.close="}",
                               stripWhiteSpace=FALSE) {
# enforce parameters
  prefix          <- force(prefix);
  n               <- force(n);
  char.open       <- force(char.open);
  char.close      <- force(char.close);
  stripWhiteSpace <- force(stripWhiteSpace);

# check parameters
  if(!(is.non.empty.string(prefix) ||
       is.non.empty.string(char.open) ||
       is.non.empty.string(char.close))) {
    exit("Invalid regular expression.");
  }
  if(!(is.function(func))) {
    exit("Invalid regular expression function.");
  }

# First, we build the regular expression, which makes sure that braces numbers
# match.
# Create the command the prefix.
  .regexpr       <- ore.escape(paste("\\", prefix, sep="", collapse=""));
  .regexpr       <- force(.regexpr);
  char.open.esc  <- ore.escape(char.open);
  char.open.esc  <- force(char.open.esc);
  char.close.esc <- ore.escape(char.close);
  char.close.esc <- force(char.close.esc);

# Add parameters.
  if(n > 0L) {
    .regexpr <- paste(.regexpr, paste(vapply(X=seq_len(n),
                  FUN=function(i) {
                       paste("(?<", letters[i], ">",
                              char.open.esc,
                              "(?:(?>[^",
                              char.open.esc, char.close.esc,
                              "]+)|\\g<",
                              letters[i],
                              ">)*",
                              char.close.esc,
                              ")",sep="", collapse="");
                  }, FUN.VALUE = ""), sep="", collapse=""),
                  sep="", collapse="");
    .regexpr <- force(.regexpr);
  }

# Add potential whitespace strippers.
  if(stripWhiteSpace) {
    .regexpr <- paste("\\s*", .regexpr, "\\s*",
                      sep="", collapse="");
    .regexpr <- force(.regexpr);
  }

  .regexpr <- ore(.regexpr);
  .regexpr <- force(.regexpr);

# A function for stripping remaining white space from strings.
  .strip <- function(t) {
    t <- trimws(as.character(t));
    if(startsWith(t, char.open) && endsWith(t, char.close)) {
      t <- trimws(substr(t, 2L, (nchar(t) - 1L)));
    }
    t <- force(t);
    return(t);
  }
  .strip <- force(.strip);

# The internal regexpression invoker for regular expressions with groups
  .wrapper <- function(found, ...) {
    n        <- force(n);
    .strip   <- force(.strip);
    .regexpr <- force(.regexpr);

    if(is.null(found)) {
      exit("Error in groupfull regular expression processing: '",
           found, "' occurences for '",
           .regexpr, "'.");
    }

    found <- force(found);
    g     <- groups(found);
    g     <- force(g);
    if(is.null(g)) {
      exit("Error in groupfull regular expression processing: '",
           found, "' has NULL groups.");
    }

    m <- nrow(g);
    m <- force(m);
    if(m > 0L) {
      result <- tryCatch(
        as.character(unname(unlist(vapply(X=seq_len(m),
                                          FUN=function(i) {
                                            t <- unname(unlist(g[i, ]));
                                            t <- force(t);
                                            if(length(t) != n) {
                                              exit("Wrong number of arguments, found ",
                                                   length(t), " but need ",
                                                   n, ".");
                                            }
                                            t <- vapply(X=t, FUN=.strip, FUN.VALUE ="");
                                            t <- force(t);
                                            t <- func(t, ...);
                                            t <- force(t);
                                            return(t);
                                          }, FUN.VALUE = "")))),
        error=function(e)     exit("Error '", e,
                                   "' occured while invoking regex processor on regex '",
                                   .regexpr, "'."),
        warnining=function(e) exit("Warning '", e,
                                   "' occured while invoking regex processor on regex '",
                                   .regexpr, "'."));
      result <- force(result);
      return(result);
    }
    exit("Zero group rows in regular expression match '", g,
         "' for '", .regexpr, "'.");
  }
  .wrapper <- force(.wrapper);

# create the invoker
  .invoke <- function(text, ...) {
    .strip   <- force(.strip);
    .regexpr <- force(.regexpr);
    .wrapper <- force(.wrapper);

    result <- tryCatch(
      ore.subst(regex=.regexpr, replacement=.wrapper, text=text, ..., all=TRUE),
      error=function(e)     exit("Error '", e,
                                 "' occured while invoking grouplfull regex processor on expression '",
                                 .regexpr, "'."),
      warnining=function(e) exit("Warning '", e,
                                 "' occured while invoking groupfull regex processor on expression '",
                                 .regexpr, "'."));
    result <- force(result);
    return(result);
  }
  .invoke <- force(.invoke);

  return(.invoke);
}
