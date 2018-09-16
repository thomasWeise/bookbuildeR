#' @title Read Code from a File according to Parameters given as Strings and
#'  Put it into a Listings Environment
#' @description Read snippets of code from a file, put it into a code environment.
#' If a github code repository is specified, create a source code link.
#' @param label the label to use
#' @param caption the caption to put
#' @param language the programming language
#' @param path the path to the file to read
#' @param lines a set of selected lines, given as R integer vector expression
#'   string
#' @param tags the list of marking start and end given as string with
#'   comma-separated values
#' @param basePath the base path against which the \code{path} should be
#'   resolved
#' @param repo a link to the repository, if any is provided
#' @param removeMetaComments should the meta-comments of the programming
#'   language be removed?
#' @export code.listing
#' @include logger.R
#' @include codeLoad.R
#' @include codeRead.R
#' @importFrom ore ore.subst ore ore.escape
#' @importFrom utilizeR is.non.empty.string
code.listing <- function(
                      label="",
                      caption="",
                      language="",
                      path,
                      lines="", tags="",
                      basePath=NULL,
                      repo=NULL,
                      removeMetaComments=TRUE) {
  
  # load the code
  code <- code.load(path, lines, tags, basePath);
  
  # deal with programming language
  if(is.non.empty.string(language)) {
    language <- tolower(trimws(language));
    if(is.non.empty.string(language)) {
      # pre-process code according to language
      if(removeMetaComments) {
        # deal with meta-comments?
        
        regexp = NULL;
        if(language=="java") {
          # deal with java
          regexp <- ore(paste("\\s*",
                              ore.escape("/**"),
                              ".*?",
                              ore.escape("*/"),
                              sep="", collapse=""),
                        options="m");
        } else {
          # deal with R
          if(language == "r") {
            regexp <- ore(paste(ore.escape("#'"),
                                ".*?",
                                "\\n*?",
                                sep="", collapse=""));
          }
        }
        
        if(!is.null(regexp)) {
          # remove meta comments
          n.old <- nchar(code);

          code  <- ore.subst(regexp, "", code, all=TRUE);
          code  <- force(code);
          if(nchar(code) < n.old) {
            # if the meta-comments were removed, there might be longer trailing space sequences
            logger("Removed some meta comments from code in file '", path, "'.");
            code <- unlist(strsplit(code, "\n", fixed=TRUE)[[1L]]);
            code <- force(code);
            code <- .remove.trailing.spaces(code, path);
            code <- force(code);
          }
        }
      }
    } else {
      language <- NULL;
    }
  } else {
    language <- NULL;
  }

  # deal with repo
  if(is.non.empty.string(repo)) {
    repo <- trimws(repo);
  } else {
    repo <- NULL;
  }
  
  # the caption
  if(is.non.empty.string(caption)) {
    caption <- trimws(caption);
    if(is.non.empty.string(caption)) {
      if(is.non.empty.string(repo) && (length(grep("github.com", repo)) > 0L)) {
        if(!(endsWith(repo, "/"))) {
          repo <- paste(repo, "/", sep="", collapse="");
        }
        repo <- paste(repo, "blob/master", sep="", collapse="");
        if(!startsWith(path, "/")) {
          repo <- paste(repo, "/", sep="", collapse="");
        }
        repo <- paste(repo, path, sep="", collapse="");
        # add reference to actual file on github
        caption <- paste(caption, " ([src](", repo, "))",
                         sep="", collapse="");
      }
    } else {
      exit("Caption of code path '", path, "' cannot just contain white space.");
    }
  } else {
    exit("Caption of code path '", path, "' cannot be empty.");
  }
  
  if(is.non.empty.string(label)) {
    label <- trimws(label);
    if(!is.non.empty.string(label)) {
      exit("Label of code path '", path, "' cannot just contain white space.");
    }
  } else {
    exit("Label of code path '", path, "' cannot just contain be empty.");
  }
  
  res <- paste("```{#", label, sep="", collapse="");
  if(!is.null(language)) {
    res <- paste(res, " .", language, sep="", collapse="");
  }
  res <- paste(res, " caption=\"",
               caption, "\"}\n", code, "\n```\n",
               sep="", collapse="");
  res <- force(res);
  return(res);
}

# the internal wrapper
.code.listing.wrap <- function(vec, basePath=NULL, repo=NULL) {
  code.listing(vec[1L], vec[2L], vec[3L], vec[4L], vec[5L], vec[6L], basePath, repo);
}
