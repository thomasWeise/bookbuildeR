
# the inner text block substitution function
#' @importFrom utilizeR is.non.empty.string
#' @include logger.R
.text.block.subst.inner <- function(found, env) {
  if(is.null(found) || (length(found) != 3L)) {
    exit("Error in \\text.block{", paste(found, sep=", ", collapse=", "), "}'.");
  }

  type <- found[[1L]];
  if(!(is.non.empty.string(type))) {
    exit("Empty text block type: '", type, "'.");
  }
  type <- tolower(trimws(type));
  if(nchar(type) <= 0L) {
    exit("Text block type only composed of white space.");
  }

  label <- found[[2L]];
  if(is.non.empty.string(label)) {
    label <- trimws(label);
  } else {
    label <- NA;
  }

  body <- found[[3L]];
  if(!(is.non.empty.string(body))) {
    exit("Empty text block body: '", body, "'.");
  }
  body <- trimws(body);
  if(nchar(body) <= 0L) {
    exit("Text block body only composed of white space.");
  }

  count <- (get0(x=type, envir=env, inherits=FALSE, ifnotfound=0L) + 1L);
  assign(x=type, value=count, pos=env);
  title <- paste(toupper(substr(type, 1L, 1L)),
                 substr(type, 2L, nchar(type)),
                 "&nbsp;",
                 count,
                 sep="", collapse="");

  if(is.non.empty.string(label)) {
    found <- get0(x=label, envir=env, inherits=FALSE, ifnotfound=NULL);
    if(is.null(found)) {
      assign(x=label, value=title, pos=env);
    } else {
      exit("Error: text block label '", label, "' already defined as '", found, "'.");
    }
  }
  return(paste("\n\n**", title, ":**&nbsp;", body, "\n\n", sep="", collapse=""));
}

# the inner text.ref substitution
#' @importFrom utilizeR is.non.empty.string
#' @include logger.R
.text.ref.subst.inner <- function(found, env) {

  if(is.null(found) || (length(found) != 1L)) {
    exit("Error in \\text.ref{", paste(found, sep=", ", collapse=", "), "}'.");
  }

  label <- found[[1L]];
  if(is.non.empty.string(label)) {
    label <- trimws(label);
    if(is.non.empty.string(label)) {
      found <- get0(x=label, envir=env, inherits=FALSE, ifnotfound=NULL);
      if(is.null(found)) {
        exit("Error: \\text.ref label '", label, "' not found.");
      }
      return(found);
    }
  }
  exit("Empty label in \\text.ref or label composed only of white space.")
}


#' @title Process all Text Blocks in a Markdown file
#' @description Emulate environments like "proof" or "definition".
#' @param text the array of text
#' @return the output text
#' @export preprocess.textblocks
#' @include logger.R
#' @include preprocessorRegexp.R
preprocess.textblocks <- function(text) {
  env  <- new.env();

  # implement the '\text.block' command
  text <- preprocess.regexp(regex="\\\\text.block\\{(.+)\\}\\{(.*)\\}\\{(.+)\\}",
                            func=.text.block.subst.inner,
                            text=text, env=env);

  # implement the '\text.ref' command
  return(preprocess.regexp(regex="\\\\text.ref\\{(.+)\\}",
                           func=.text.ref.subst.inner,
                           text=text, env=env));
}