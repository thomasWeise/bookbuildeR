
# the inner text block substitution function
#' @importFrom utilizeR is.non.empty.string
#' @include logger.R
.text.block.subst.inner <- function(found, env) {
  if(is.null(found) || (length(found) != 3L)) {
    .exit("Error in \\text.block{", paste(found, sep=", ", collapse=", "), "}'.");
  }

  type <- found[[1L]];
  type <- force(type);
  if(!(is.non.empty.string(type))) {
    .exit("Empty text block type: '", type, "'.");
  }
  type   <- tolower(trimws(type));
  type   <- force(type);
  type.n <- nchar(type);
  if(type.n <= 0L) {
    .exit("Text block type only composed of white space.");
  }

  label <- found[[2L]];
  label <- force(label);
  if(is.non.empty.string(label)) {
    label <- trimws(label);
    label <- force(label);
  } else {
    label <- NA;
  }

  body <- found[[3L]];
  body <- force(body);
  if(!(is.non.empty.string(body))) {
    .exit("Empty text block body: '", body, "'.");
  }
  body <- trimws(body);
  body <- force(body);
  if(nchar(body) <= 0L) {
    .exit("Text block body only composed of white space.");
  }

  count <- (get0(x=type, envir=env, inherits=FALSE, ifnotfound=0L) + 1L);
  count <- force(count);
  assign(x=type, value=count, pos=env);

  title <- toupper(substr(type, 1L, 1L));
  if(type.n > 1L) {
    title <- paste(title, substr(type, 2L, type.n), sep="", collapse="");
  }
  title <- paste(title, "&nbsp;", count, sep="", collapse="");
  title <- force(title);

  if(is.non.empty.string(label)) {
    found <- get0(x=label, envir=env, inherits=FALSE, ifnotfound=NULL);
    if(is.null(found)) {
      assign(x=label, value=title, pos=env);
    } else {
      .exit("Error: text block label '", label, "' already defined as '", found, "'.");
    }
  }

  result <- paste("\n\n\n**", title, ".**&nbsp;", body, "\n\n\n", sep="", collapse="");
  result <- force(result);
  return(result);
}

# the inner text.ref substitution
#' @importFrom utilizeR is.non.empty.string
#' @include logger.R
.text.ref.subst.inner <- function(found, env) {
  if(is.null(found) || (length(found) != 1L)) {
    .exit("Error in \\text.ref{", paste(found, sep=", ", collapse=", "), "}'.");
  }

  label <- found[[1L]];
  label <- force(label);
  if(is.non.empty.string(label)) {
    label <- trimws(label);
    label <- force(label);
    if(is.non.empty.string(label)) {
      found <- get0(x=label, envir=env, inherits=FALSE, ifnotfound=NULL);
      found <- force(found);
      if(is.non.empty.string(found)) {
        return(found);
      }
      .exit("Error: \\text.ref label '", label, "' not found.");
    }
  }
  .exit("Empty label in \\text.ref or label composed only of white space.")
}

#' @title Process all Text Blocks in a Markdown file
#' @description Emulate environments like "proof" or "definition".
#' @param text the array of text
#' @return the output text
#' @export preprocess.textblocks
#' @include preprocessorCommand.R
preprocess.textblocks <- function(text) {
  env  <- new.env();

  # implement the '\text.block' command
  text <- preprocess.command(
            preprocess.command.regexp("text.block", 3L, stripWhiteSpace=TRUE),
            text, .text.block.subst.inner, env=env);
  text <- force(text);

  # implement the '\text.ref' command
  text <- preprocess.command(
            preprocess.command.regexp("text.ref", 1L, stripWhiteSpace=FALSE),
            text, .text.ref.subst.inner, env=env);
  text <- force(text);

  return(text);
}
