#' @title A very Primitive Method to Read YAML Metadata Key-Value Pairs
#' @description A very primitive method to read the key-value pairs from YAML
#'   metadata in a file.
#' @param srcfile the file to read from
#' @return a list with key-value pairs from the YAML metadata
#' @export metadata.read
#' @importFrom yaml read_yaml
metadata.read <- function(srcfile) {
  srcfile <- check.file(srcfile);

  level <- 0L;
  text <- character(1024);
  text.length <- 0L;
  inMultiLine <- FALSE;

  tryCatch({
    handle <- file(srcfile, "rt");
    while(level < 2L) {
      # read the line
      line <- readLines(con=handle, n=1L);
      if(length(line) <= 0L) {
        level <- 2L;
        break;
      }
      # pick the first line
      line <- line[1L];
      if(nchar(line) <= 0L) {
        inMultiLine <- FALSE;
      }
      # remove the right end white space
      line <- trimws(line, which="right");
      # trim complete line
      line.trim <- trimws(line);

      # level==0 means we are not in the metadata
      if(level <= 0L) {
        if(startsWith(line.trim, "---")) {
          level <- 1L; # now we are in the meta data
          inMultiLine <- FALSE;
        }
        next;
      }

      # ok, we are in the metadata
      if(startsWith(line.trim, "---") || startsWith(line.trim, "...")) {
        level <- 2L; # we have reached the end of metadata
        break;
      }

      if(inMultiLine) { # we are in a multi-line content, add to last line
        text[text.length] <- paste(text[text.length], line, sep=" ", collapse=" ");
        next;
      }

      # does the line end with "|", which indicates multi-line content
      if(endsWith(line, "|")) {
        inMultiLine <- TRUE; # ok, we are in multi-line content
        line <- trimws(substr(x=line, start=1L, stop=(nchar(line)-1L)),
                       which="right");
      }
      # else text to line list
      text.length <- text.length + 1L;
      text[text.length] <- line;
    }
    close(handle);
  }, error=function(e) {
    exit("Error '", e,
         "' when trying to read yaml metadata from '",
         srcfile, "'.");
  }, warning=function(e) {
    exit("Warning '", e,
         "' when trying to read yaml metadata from '",
         srcfile, "'.");
  })

  if(text.length <= 0L) {
    exit("No yaml metadata found in file '",
         file, "'.");
  }

  # only keep the actual discovered text
  text <- text[1L:text.length];

  tryCatch({
    yaml <- read_yaml(text=text);
  }, error=function(e) {
    exit("Error '", e,
         "' when parsing yaml metadata '",
         paste(text, sep="\\n", collapse="\\n"),
         "', from '",
         srcfile, "'.");
  }, warning=function(e) {
    exit("Warning '", e,
         "' when parsing yaml metadata '",
         paste(text, sep="\\n", collapse="\\n"),
         "', from '",
         srcfile, "'.");
  });

  .logger("Finished loading metadata from '",
          srcfile, "'.");

  return(yaml);
}
