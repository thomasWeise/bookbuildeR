#' @title Find a Template, Load it into the Specified Directory if Necessary
#' @description Following a heuristic, try to load a template into the given
#'   directory
#' @param dir the destination directory
#' @param template the template
#' @return the fully qualified path to the template
#' @include logger.R
#' @importFrom utils download.file
#' @importFrom utilizeR is.non.empty.string
#' @export template.load
template.load <- function(template, dir=getwd()) {
  dir <- force(dir);
  dir <- check.dir(dir);
  template <- force(template);

  # does the template already exist?
  template.path <- file.path(dir, template);
  template.path <- force(template.path);
  if(file.exists(template.path)) {
    template.path <- normalizePath(template.path, mustWork = FALSE);
    logger("Template '", template,
            "' exists as file '", template.path, "'.");
  } else {
    logger("Template '", template,
           "' not provided as local file '", template.path,
           "', now trying sysdata.rda resource with name '", template,
           "'.");

    # does it exist as resource?
    have.not <- TRUE;
    resource <- template.resources[[template]];
    if(!(is.null(resource))) {
      if(!(is.character(resource))) {
        exit("Corrupted sysdata.rda resource '", resource, "' - is not a character list.");
      }
      if(length(resource) <= 0L) {
        exit("Corrupted sysdata.rda resource '", resource, "' - character list is empty.");
      }
      template.path <- tempfile(pattern="tmp", tmpdir=dir, fileext=".template");
      template.path <- force(template.path);
      tryCatch({
        writeLines(text=resource, con=template.path);
      }, error=function(e) {
        exit("Error '", e,
             "' when trying to copy sysdata.rda resource '", template,
             "' to file '", template.path, "'.");
      }, warning=function(e) {
        exit("Warning '", e,
             "' when trying to copy sysdata.rda resource '", template,
             "' to file '", template.path, "'.");
      });
      logger("Discovered template '",
             template,
             "' in sysdata resources '", template,
             "' and copied it to file '",  template.path, "'.");
      have.not <- FALSE;
    }

    if(have.not) {
      logger("Template '",
             template,
             "' does not exist as sysdata resources '", template,
             "', now looking checking whether it is a URL we can download.");

      # is it a shortcut for a known url?
      have <- template.urls[[template]];
      have <- force(have);
      if(is.non.empty.string(have)) {
        logger("Template '",
               template,
               "' has pre-defined URL '", have,
               "'.");
        template <- have;
        template <- force(template);
      }

      template.path <- tempfile(pattern="tmp", tmpdir=dir, fileext=".template");
      template.path <- force(template.path);
      logger("Beginning to download template from '",
             template,
             "' to file '",
             template.path, "'.");

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
