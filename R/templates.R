# known templates
.templates <- list(
  eisvogel.latex = "http://raw.githubusercontent.com/Wandmalfarbe/pandoc-latex-template/master/eisvogel.tex",
  arabica.latex = "http://github.com/qualiacode/arabica/blob/master/controls/arabica.latex"
);

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
    .logger("Template '",
            template,
            "' exists as file '",
            template.path, "'.");
  } else {
    template.path <- tempfile(pattern="tmp", tmpdir=dir, fileext=".template");
    template.path <- force(template.path);
    
    # does it exist somewhere in PATH?
    have.not <- TRUE;
    for(path in .path) {
      template.path.2 <- file.path(path, template);
      template.path.2 <- force(template.path.2);
      if(file.exists(template.path.2)) {
        have.not <- FALSE;
        .logger("Discovered local copy of template '",
                template,
                "' in PATH as file '",
                template.path.2, "'.");
        
        tryCatch({
          file.copy(from=template.path.2, to=template.path, overwrite=TRUE);
        }, error=function(e) {
          exit("Error '", e,
               "' when trying to copy file '",
               template.path.2, "' to file '",
               template.path, "'.");
        }, warning=function(e) {
          exit("Warning '", e,
               "' when trying to copy file '",
               template.path.2, "' to file '",
               template.path, "'.");
        })
        
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

      tryCatch({
        download.file(url=template, destfile=template.path);
        .logger("Finished downloading template from '",
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
      });
    }
  }

  template.path <- force(template.path);
  template.path <- check.file(template.path);
  template.path <- force(template.path);
  return(template.path);
}
