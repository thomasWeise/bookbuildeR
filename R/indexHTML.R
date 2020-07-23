.file.size <- function(size) {
  if(size <= 0L) {
    return("0&nbsp;B");
  }
  if(size < 1024L) {
    return(paste(size, "&nbsp;B", sep="", collapse=""));
  }
  if(size < 1048576L) {
    return(paste(signif(size/1024L, 2L), "&nbsp;KiB", sep="", collapse=""));
  }
  return(paste(signif(size/1048576L, 2L), "&nbsp;MiB", sep="", collapse=""));
}

# insert commas and "and"s as appropriate
.name.and <- function(names) {
  l <- length(names);
  if(l <= 1L) {
    return(names);
  }
  if(l <= 2L) {
    return(c(paste(names[1L], "&nbsp;and", sep="", collapse=""), names[2L]));
  }
  for(i in seq_len(l-2L)) {
    names[i] <- paste(names[i], ",", sep="", collapse="");
  }
  names[l-1L] <-  paste(names[l-1L], ", and", sep="", collapse="");
  return(names);
}

#' @title Generate an \code{index.html} File
#' @description Generate an \code{index.html} File
#' @param files a list of \code{(path, desc)} tuples with file paths and
#'   corresponding descriptions
#' @param sourceDir the source directory: used to resolve the include
#' @param destDir the destination directory
#' @param metadata the meta data
#' @return the canonical path to the \code{index.html} file
#' @export index.html
#' @include logger.R
#' @include meta.R
#' @importFrom utilizeR is.non.empty.list is.non.empty.string
#'   is.non.empty.vector path.relativize
#' @importFrom markdown markdownToHTML
index.html <- function(files,
                       sourceDir=NULL,
                       destDir=dirname(files[[1L]]$path),
                       metadata) {
  .logger("Now building index.html file.");

  destDir <- .check.dir(destDir);

  # create dest file
  destFile <- normalizePath(file.path(destDir, "index.html"), mustWork = FALSE);
  if(file.exists(destFile)) {
    .exit("Destination file '", destFile, "' already exists.");
  }

# load title
  title <- metadata$title;
  if(!(is.non.empty.string(title))) {
    title <- NULL;
  }

# build the html skeleton
  lines <- c("<!DOCTYPE html>",
  "<html dir=\"ltr\" lang=\"en\">",
  "<head>",
  "<meta charset=\"utf-8\">");
# insert title?
  if(!is.null(title)) {
    lines <- c(lines, paste("<title>", title, "</title>", sep="", collapse=""));
  }
  lines <- c(lines, "</head>", "<body>");
# if we have a title, there should be a "header" tag

  compiled <- paste("<p>This book has been compiled using the <a href=\"http://github.com/thomasWeise/bookbuildeR\">bookbuildeR</a> package on ",
                    meta.date(),
                    ".</p>",
                    sep="", collapse="");

# load a potential markdown include file
  if(is.non.empty.string(metadata$website.md)) {
    include <- normalizePath(file.path(sourceDir, metadata$website.md),
                             mustWork = FALSE);
    if(!file.exists(include)) {
      .exit("Website markdown include file '", include, "' does not exist.");
    }

    include <- readLines(con=include);
    if(is.character(include) && (!any(is.na(include))) && (sum(nchar(include)) > 0L)) {
      include <- unname(unlist(markdownToHTML(text=include,
                                              fragment.only = TRUE,
                                              options = c('fragment_only'))));
      if(is.character(include) && (!is.na(include)) && (sum(nchar(include)) > 0L)) {
        include <- trimws(unname(unlist(strsplit(include, "\n", fixed=TRUE))));
        include <- include[nchar(include) > 0];
        .logger("Finished rendering website markdown include.");
        if(length(include) < 1L) {
          .exit("Markdown rendering of include file produced empty result.");
        } else {
          lines <- c(lines, include, compiled);
        }
      } else {
        .exit("Error when rendering markdown include.");
      }
    } else {
      .exit("Website markdown include file is empty!");
    }
  } else {
    # load authors
    author <- metadata$author;
    if(is.non.empty.list(author)) {
      author <- unname(unlist(author));
    } else {
      if(is.non.empty.vector(author)) {
        author <- unname(author);
      } else {
        if(!is.non.empty.string(author)) {
          author = NULL;
        }
      }
    }
    if(!(is.null(author))) {
      # for now, we just perform a very crude name concatenation
      author <- paste(.name.and(author), sep=" ", collapse=" ");
    }

    if(!(is.null(title))) {
      lines <- c(lines, "<header>", paste("<h1>", title, "</h1>", sep="", collapse=""));
      if(!(is.null(author))) {
        lines <- c(lines, paste("<h2>by&nbsp;", author, "</h2>", sep="", collapse=""))
      }
      lines <- c(lines, "</header>");
    }

    if(!is.null(title)) {
      start <- paste("<p>The book <em><q>", title, "</q></em>", sep="", collapse="");
      if(!is.null(author)) {
        start <- paste(start, " by ", author, sep="", collapse="");
      }
    } else {
      start <- "<p>This book";
    }
    start <- paste(start, " is available in the following formats:</p>", sep="", collapse="");

    # put the contents together: first create links and add file sizes and descriptions
    files <- vapply(X=files,
                    FUN=function(f) {
                      path <- .check.file(f$path);
                      size <- file.size(path);
                      path <- path.relativize(path, destDir);
                      return(paste("<a href=\"", path, "\">",
                                   path, "</a>&nbsp;[",
                                   .file.size(size),
                                   "] ",
                                   f$desc, sep="", collapse=""))
                    }, "");
    # now put "," and "and"s where they belong
    files <- .name.and(files);
    # put the final "."
    files[length(files)] <- paste(files[length(files)], ".", sep="", collapse="");
    # collapse into a list
    files <- vapply(files, FUN=function(f) paste("<li>", f, "</li>", sep="", collapse=""), "");

    lines <- c(lines, "<main>",
               start,
               "<ul>",
               files,
               "</ul>",
               compiled,
               "</main>");

  }

  lines <- c(lines,
             "</body>",
             "</html>");

  writeLines(text=lines,
             con=destFile);

  destFile <- .check.file(destFile);

  .logger("Finished building index.html '", destFile, "'.");
  return(destFile);
}
