
# the other commands
#' @include meta.R
#' @importFrom ore ore.escape
.commands <- list(
  list(regexp=ore.escape("\\meta.time"),       func=function(match) meta.time()),
  list(regexp=ore.escape("\\meta.date"),       func=function(match) meta.date()),
  list(regexp=ore.escape("\\meta.year"),       func=function(match) meta.year()),
  list(regexp=ore.escape("\\meta.repository"), func=function(match) meta.repository()),
  list(regexp=ore.escape("\\meta.commit"),     func=function(match) meta.commit())
);

#' @title Expand the Simple Commands in via Regular Expressions
#' @description Expand simple commands, like \code{meta.time}.
#' @param text the text to process
#' @return the processed text
#' @include preprocessorRegexp.R
#' @export preprocess.plain
preprocess.plain <- function(text) {
  # now do the other replacements
  for(command in .commands) {
    text <- preprocess.regexp(regex=command$regexp,
                              func=command$func,
                              text=text);
    text <- force(text);
  }
  
  # implement the '\direct.r' command
  text <- preprocess.command(
    preprocess.command.regexp("direct.r", 1L, stripWhiteSpace=TRUE),
    text, r.exec);
  text <- force(text);

  return(text);
}
