
# the other commands
#' @include meta.R
.commands <- list(
  list(regexp="\\\\meta.time",       func=function(match) meta.time()),
  list(regexp="\\\\meta.date",       func=function(match) meta.date()),
  list(regexp="\\\\meta.repository", func=function(match) meta.repository()),
  list(regexp="\\\\meta.commit",     func=function(match) meta.commit())
);

#' @title Expand the Simple Commands in via Regular Expressions
#' @description Expand simple commands, like \code{meta.time}.
#' @param text the text to process
#' @return the processed text
#' @include preprocessorRegexp.R
preprocess.plain <- function(text) {
  # now do the other replacements
  for(command in .commands) {
    text <- preprocess.regexp(regex=command$regexp,
                              func=command$func,
                              text=text);
  }

  return(text);
}
