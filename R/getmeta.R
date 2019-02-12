#' @title Extract YAML Metadata from a Text
#' @description A method to read the key-value pairs from YAML
#'   metadata in a text.
#' @param text the text to read the metadata from
#' @return a list with key-value pairs from the YAML metadata
#' @export metadata.get
#' @importFrom yaml read_yaml
#' @importFrom ore ore ore.search ore.subst ore.escape
#' @include logger.R
#' @include preprocessorCommand.R
metadata.get <- function(text) {
  s1 <- ore.escape("---");
  s2 <- ore.escape("...");
  found <- ore.search(ore(paste("^",s1,"(.+?)^(",s1,"|",s2,")$", sep="", collapse=""),
                      options="m"),
                     text, all=FALSE);
  if(is.null(found)) {
    logger("No metadata found in text.");
    return(NULL);
  }
  if(found$nMatches != 1L) {
    exit("Error in YAML metadata matching.");
  }
  text <- trimws(groups(found)[,1L]);
  if(nchar(text) <= 0L) {
    exit("Empty metadata?");
  }
  
  # take care of multi-line content
  text <- trimws(ore.subst(ore(paste(ore.escape("|"), "\\s*$(.*?\\n)\\n", sep="", collapse=""),
                    options="m"),
                function(found) {
                  .preprocessor.regexp.invoke(found,
                    function(t) {
                      paste(gsub("\n", " ", t, fixed=TRUE), "\n", sep="", collapse="")
                    })
                },
                text,
                all=TRUE));
  
  if(nchar(text) <= 0L) {
    exit("Empty metadata after multi-line merging?");
  }
  
  # take care of raw attributes
  s <- "REPLACED";
  text <- trimws(ore.subst(ore(
                paste(ore.escape("```"), "\\s*(.*?\\n)*", ore.escape("```"),
                      sep="", collapse=""), options="m"),
                function(found) s,
                text,
                all=TRUE));
  
  if((nchar(text) <= 0L) || (text == s)) {
    exit("Empty metadata after raw attribute removal?");
  }

  tryCatch({
    yaml <- read_yaml(text=text);
  }, error=function(e) {
    exit("Error '", e,
         "' when parsing yaml metadata '",
         text,
         "'.");
  }, warning=function(e) {
    exit("Warning '", e,
         "' when parsing yaml metadata '",
         text,
         "'.");
  });

  if(is.non.empty.list(yaml)) {
    logger("Finished loading ",
           length(yaml), " metadata items from.");
    return(yaml);
  }

  exit("Empty parsed metadata, although text '", text, "' is not empty.");
  return(NULL);
}

#' @title Check if a bibliography is specified in the metadata
#' @description Check if a bibliography is specified in the metadata
#' @param metadata the meta data
#' @return \code{TRUE} if \code{metadata} specifies a bibliography, \code{FALSE}
#'   otherwise
#' @importFrom utilizeR is.non.empty.list is.non.empty.string
#' @export metadata.hasBibliography
metadata.hasBibliography <- function(metadata=NULL) {
  if(is.non.empty.list(metadata)) {
    # do we have a bibliography?
    bibliography <- metadata$bibliography;
    if(is.non.empty.vector(bibliography)) {
      bibliography <- bibliography[[1L]];
    }
    return(is.non.empty.string(bibliography));
  }
  return(FALSE);
}


#' @title Get the source code repository if any is specified in the metadata
#' @description Get the source code repository if any is specified in the metadata
#' @param metadata the meta data
#' @return the url of the source code repository, \code{NULL} if none is specified
#' @importFrom utilizeR is.non.empty.list is.non.empty.string
#' @export metadata.getCodeRepo
metadata.getCodeRepo <- function(metadata=NULL) {
  if(is.non.empty.list(metadata)) {
    codeRepo <- metadata$codeRepo;
    if(is.non.empty.vector(codeRepo)) {
      codeRepo <- codeRepo[[1L]];
    }
    if(is.non.empty.string(codeRepo)) {
      return(codeRepo);
    }
  }
  return(NULL);
}
