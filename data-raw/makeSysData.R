
library(utilizeR);
source("R/logger.R");

logger("Beginning to build resources R/sysdata.rda.");

# the urls of the templates
template.urls <- list(
  eisvogel.latex = "http://raw.githubusercontent.com/Wandmalfarbe/pandoc-latex-template/master/eisvogel.tex",
  GitHub.html5 = "http://raw.githubusercontent.com/tajmone/pandoc-goodies/master/templates/html5/github/GitHub.html5"
);


# try to get a certain template
.get <- function(name, url) {

# local copy
  local.copy <- file.path("data-raw", name);
  logger("Local copy of template '",
         name, "' should be in file '",
         local.copy, "'.");

# first we try to download the file
  .temp.file = tempfile("template");
  result <- -1L;
  tryCatch({
    result <- download.file(url=url, destfile=.temp.file);
  }, error=function(e) {
    logger("Error '", e,
         "' when trying to download template '", name,
         "' from url '", url, "'.");
  }, warning=function(e) {
    logger("Warning '", e,
           "' when trying to download template '", name,
           "' from url '", url, "'.");
  });

  if(result == 0L) {
    logger("Successfully downloaded copy of template '",
           name, "' to file '", .temp.file, "'.");
    result <- readLines(con=.temp.file);
# we found a new version of the template? let's update the local copy
    if(is.character(result) && (length(result) > 0L)) {
      nonEmptyLines <- 0L;
      for(l in result) {
        if(nchar(l) > 0L) {
          nonEmptyLines <- nonEmptyLines + 1L;
        }
      }
      if(nonEmptyLines > 0L) {
        logger("Successfully loaded template '",
               name, "' from url '", url, "', got ",
               nonEmptyLines, " non-empty lines of text (from a total of ",
               length(result), " lines). Now overwriting local source file ",
               local.copy, ".");
        writeLines(text=result, con=local.copy);
      } else {
        result <- NULL;
      }
    } else {
      logger("Error when processing downloaded copy of template ",
             name, ": it is not a character list or of zero size!");
      result <- NULL;
    }
  } else {
    logger("Failed to download template '", name,
           "' from url '", url, "', got exit code ",
           result, ".");
    result <- NULL;
  }
  file.remove(.temp.file);

# did we get the file?
  if(is.null(result)) {
    logger("Could not download new version of template, now trying to load local version '",
           local.copy, ".");
# no, we did not: look for it right here
    result <- readLines(local.copy);

    if(is.character(result) && (length(result) > 0L)) {
      nonEmptyLines <- 0L;
      for(l in result) {
        if(nchar(l) > 0L) {
          nonEmptyLines <- nonEmptyLines + 1;
        }
      }
      if(nonEmptyLines > 0L) {
        logger("Successfully loaded local copy of template '",
               name, "' from file '", local.copy, "', got ",
               nonEmptyLines, " non-empty lines of text (from a total of ",
               length(result), " lines).");
      } else {
        result <- NULL;
      }
    } else {
      logger("Error when processing local copy of template ",
             name, ": it is not a character list or of zero size!");
      result <- NULL;
    }
  }

  result <- force(result);
  if(is.null(result)) {
    exit("Could not get template '", name, "'.");
  }
  return(result);
}

logger("We now try to download and process the URLs of the known templates one-by-one.");
template.resources <- template.urls;
for(name in names(template.urls)) {
  template.resources[[name]] <- .get(name, template.urls[[name]]);
}
logger("Done with downloading and processing the URLs of the known templates one-by-one.");

template.urls[["eisvogel-article.latex"]] <- template.urls[["eisvogel.latex"]];
template.resources[["eisvogel-article.latex"]] <- template.resources[["eisvogel.latex"]];

logger("Converting 'eisvogel-article.latex' to 'eisvogel-book.latex'.");
.temp <- unname(unlist(template.resources[["eisvogel.latex"]]));
for(i in seq_along(.temp)) {
  .temp[[i]] <- gsub("scrartcl", "scrbook", .temp[[i]], fixed=TRUE);
  .temp[[i]] <- force(.temp[[i]]);
}
template.resources[["eisvogel-book.latex"]] <- .temp;
rm(.temp);
logger("Done converting 'eisvogel-article.latex' to 'eisvogel-book.latex'.");

logger("Now improving template 'GitHub.html5'.");
.temp <- unname(unlist(template.resources[["GitHub.html5"]]));
for(i in seq_along(.temp)) {
  .temp[[i]] <- gsub("div.line-block{white-space:pre-line}",
                     "div.line-block{line-height:0.85;white-space:pre-line}",
                     .temp[[i]], fixed=TRUE);
  .temp[[i]] <- force(.temp[[i]]);
}
template.resources[["GitHub.html5"]] <- .temp;
rm(.temp);
logger("Done fixing 'GitHub.html5'.");

logger("Now storing resources in R/sysdata.rda.");
# store all contents in the sysdata.rda file
usethis::use_data(template.urls,
                   template.resources,
                   internal = TRUE,
                   overwrite = TRUE,
                   compress="xz")
logger("Done: Now please re-build and install the package.");

