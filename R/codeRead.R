.remove.trailing.spaces <- function(text, path) {
  # remove trailing space
  text  <- trimws(text, which="right");
  ends  <- nchar(text);
  check <- which(ends > 0L);
  ends  <- ends[check];
  cmp.1 <- rep.int(" ", times=length(check));
  cmp.2 <- text[check];

  # find the longest trailing spaces
  for(i in seq_len(min(ends))) {
    if(any(substr(cmp.2, i, i) != cmp.1)) {
      if(i > 1L) {
        text[check] <- substr(cmp.2, i, ends);
      }
      break;
    }
  }
  
  # fix trailing and leading newlines
  len <- length(text);
  if(len <= 0L) {
    exit("Empty text selected from file '", path, "'.");
  }
  for(i in seq_along(text)) {
    if(nchar(trimws(text[[i]])) > 0L) {
      break;
    }
  }
  for(j in (len:1L)) {
    if(nchar(trimws(text[[j]])) > 0L) {
      break;
    }
  }
  if((i > 1L) || (j < len)) {
    if(j <= i) {
      exit("Empty text in after selection and trimming in file '",
           path, "'.");
    }
    text <- text[i:j]
  }
  
  # make a single string, remove triple new lines
  text <- force(text);
  text <- paste(text, sep="\n", collapse="\n");
  l.2 <- nchar(text);
  while(TRUE) {
    l.1  <- l.2;
    text <- gsub("\n\n\n", "\n\n", text, fixed=TRUE);
    l.2  <- nchar(l.1);
    if(l.2 >= l.1) {
      break;
    }
  }
  
  text <- trimws(text, which="right");
  text <- force(text);
  if(nchar(text) <= 0) {
    exit("After trimming, the selected code from file '",
         path, "' is empty.");
  }
  return(text);
}

#' @title Read Code from a File
#' @description Read snippets of code from a file.
#' @param path the path to the file to read
#' @param lines a set of selected lines
#' @param tags the tags marking start and end
#' @export code.read
#' @include logger.R
code.read <- function(path, lines=NULL, tags=NULL) {
  path <- check.file(path);
  logger("reading text from file '", path, "'.");

  handle <- file(path, "rt");
  text <- readLines(handle);
  close(handle);
  logger("finished text from file '", path, "', now processing it.");

  # pick the selected lines
  if((!(is.null(lines))) && (length(lines) > 0L)) {
    text <- text[sort(unique(lines))];
  }

  # iterate through the tags
  if(!is.null(tags)) {
    lines <- NULL;
    not   <- NULL;
    for(tag in trimws(tags)) {
      start <- grep(pattern=paste("start\\s+", tag, sep="", collapse=""),
                    x=text,
                    ignore.case=TRUE,
                    fixed=FALSE);
      end <- grep(pattern=paste("end\\s*", tag, sep="", collapse=""),
                  x=text,
                  ignore.case=TRUE,
                  fixed=FALSE);

      # check the number of occurences
      l <- length(start);
      if(l != length(end)) {
        exit("Number ", l,
             " of starts of tag '", tag,
             "' does not equal number ",
             length(end), " of ends in '",
             path, "'.");
      }
      if(l <= 0L) {
        exit("Did not find tag '", tag,
             "' in '", path, "'.");
      }

      # iterate over findings
      for(i in seq_along(start)) {
        s <- start[i];
        e <- end[i];
        if(s >= e) {
          exit("Start line ", s,
               " of tag '", tag,
               "' larger or equal than end line ",
               e, " in '",
               path, "'.");
        }

        # remember useless tag lines
        not <- unique(unlist(c(not, c(s, e))));

        # add lines
        lines <- unique(unlist(c(lines, ((s+1L):(e-1L)))));
        lines <- force(lines);
      }
    } # / tag in tags

    # remove tag lines
    for(t in not) {
      t <- match(t, lines);
      if(!(is.na(t))) { lines <- lines[-t]; }
    }

    # select the text
    text <- text[sort(unique(lines))];
  } # /is.null(tags)
  text <- gsub("\t", "  ", text, fixed=TRUE);
  text <- force(text);

  text <- .remove.trailing.spaces(text, path);
  text <- force(text);
  
  logger("Finished reading ",
         length(gregexpr("\n", text, fixed=TRUE)[[1]]),
         " lines of text from file '",
         path, "'.");
  return(text);
}
