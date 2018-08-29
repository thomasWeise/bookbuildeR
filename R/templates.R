# known templates
.templates <- list(
  eisvogel.latex = "http://raw.githubusercontent.com/Wandmalfarbe/pandoc-latex-template/master/eisvogel.tex",
  arabica.latex = "http://github.com/qualiacode/arabica/blob/master/controls/arabica.latex"
);

# the search path
.path <- strsplit(x=Sys.getenv(x="PATH"), split=":", fixed=TRUE);

#' @title Find a Template, Load it into the Specified Directory if Necessary
#' @description Following a heuristic, try to load a template into the given
#'   directory
#' @param dir the destination directory
#' @param template the template
#' @return the fully qualified path to the template
#' @include logger.R
#' @export template.load
#' @importFrom utils download.file
template.load <- function(template, dir=getwd()) {
  dir <- check.dir(dir);

  # does the template already exist?
  template.path <- file.path(dir, template);
  if(file.exists(template.path)) {
    template.path <- check.file(template.path);
    .logger("Template '",
            template,
            "' exists as file '",
            template.path, "'.");
    return(template.path);
  }

  # does it exist somewhere in PATH?
  for(path in .path) {
    template.path <- file.path(path, template);
    if(file.exists(template.path)) {
      template.path <- check.file(template.path);
      .logger("Discovered local copy of template '",
              template,
              "' in PATH as file '",
              template.path, "'.");
      return(template.path);
    }
  }

  # is it a shortcut for a known url?
  have <- .templates[[template]];
  if(!is.null(have)) {
    template <- have;
  }

  template.path <- tempfile(pattern="tmp", tmpdir=dir, fileext=".template");

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
  })

  return(check.file(template.path));
}
