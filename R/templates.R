# known templates
.templates <- list(
  arabica.latex = "http://raw.githubusercontent.com/qualiacode/arabica/master/controls/arabica.latex",
  eisvogel.latex = "http://raw.githubusercontent.com/Wandmalfarbe/pandoc-latex-template/master/eisvogel.tex"
);
.templates[["eisvogel-article.latex"]] <- "http://raw.githubusercontent.com/Wandmalfarbe/pandoc-latex-template/master/eisvogel.tex";

# the search path
.path <- unlist(strsplit(x=Sys.getenv(x="PATH"), split=":", fixed=TRUE));

#' @title Find a Template, Load it into the Specified Directory if Necessary
#' @description Following a heuristic, try to load a template into the given
#'   directory
#' @param dir the destination directory
#' @param template the template
#' @return the fully qualified path to the template
#' @include logger.R
#' @export template.load
#' @importFrom utils download.file
#' @importFrom utilizeR is.non.empty.string
template.load <- function(template, dir=getwd()) {
  dir <- force(dir);
  dir <- check.dir(dir);
  template <- force(template);

  # does the template already exist?
  template.path <- file.path(dir, template);
  template.path <- force(template.path);
  if(file.exists(template.path)) {
    template.path <- normalizePath(template.path, mustWork = FALSE);
    logger("Template '",
            template,
            "' exists as file '",
            template.path, "'.");
  } else {
    # does it exist somewhere in PATH?
    have.not <- TRUE;
    for(path in .path) {
      template.path <- file.path(path, template);
      template.path <- force(template.path);
      if(file.exists(template.path)) {
        template.path <- normalizePath(template.path, mustWork = FALSE);
        have.not <- FALSE;
        logger("Discovered local copy of template '",
                template,
                "' in PATH as file '",
                template.path, "'.");
        break;
      }
    }

    if(have.not) {
      # is it a shortcut for a known url?
      have <- .templates[[template]];
      have <- force(have);
      if(is.non.empty.string(have)) {
        template <- have;
        template <- force(template);
      }

      template.path <- tempfile(pattern="tmp", tmpdir=dir, fileext=".template");
      template.path <- force(template.path);

      tryCatch({
        download.file(url=template, destfile=template.path);
        template.path <- normalizePath(template.path, mustWork = FALSE);
        logger("Finished downloading template from '",
                template,
                "' to file '",
                template.path, "'.");
      }, error=function(e) {
        exit("Error '", e,
             "' when trying to access url '",
             template, "'.");
      }, warning=function(e) {
        exit("Warning '", e,
             "' when trying to access url '",
             template, "'.");
      })
    }
  }

  template.path <- force(template.path);
  template.path <- check.file(template.path);
  template.path <- force(template.path);
  return(template.path);
}
