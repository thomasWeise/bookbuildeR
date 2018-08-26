
# the other commands
#' @include meta.R
.commands <- list();
.commands[["\\\\meta.time"]]       <- function(match) meta.time();
.commands[["\\\\meta.repository"]] <- function(match) meta.repository();
.commands[["\\\\meta.commit"]]     <- function(match) meta.commit();
.commands.names <- names(.commands);

# load a single file and pipe it to the output
#' @importFrom ore ore.subst
#' @importFrom utilizeR path.relativize
#' @include logger.R
.preprocess.input <- function(sourceFile, rootDir, output) {

  # check if we can open the source file
  sourceFile <- check.file(sourceFile);

  # get the current directory
  sourceDir <- dirname(sourceFile);

  .logger("Pre-processing contents from source file '",
          sourceFile,
          "' to output.");

  # read the contents
  src <- file(sourceFile, open="rt");
  lines <- readLines(src);
  close(src);

  # resolve all relative paths
  input.start <- "\\relative.input{";
  for(line in lines) {
    line.trimmed <- trimws(line);
    if(startsWith(line.trimmed, input.start)) {
      source.next <- trimws(substr(x=line.trimmed,
                                   start=(nchar(input.start)+1L),
                                   stop=(nchar(line)-1L)));
      source.next <- check.file(file.path(sourceDir, source.next));

      # write an empty line and then begin processing the next contents recursively
      writeLines(text="", con=output);
      .preprocess.input(sourceFile=source.next, rootDir=rootDir, output=output);
      next;
    }

    # ok, we are in a normal line

    # implement the '\relative.path' command which will
    line <- ore.subst(regex="\\\\relative.path\\{(.+)\\}",
                      replacement=function(relPath) {
                        groups <- attr(relPath, "groups");
                        if(is.null(groups) || (length(groups) != 1L)) {
                          exit("Error in \\relpath{", groups, "} in file '",
                               sourceFile, "'.");
                        }
                        path.relativize(
                          check.file(file.path(sourceDir, groups[1L])),
                          rootDir)
                      },
                      text=line,
                      all=TRUE);

    # now do the other replacements
    for(i in seq_along(.commands)) {
      line <- ore.subst(regex=.commands.names[[i]],
                        replacement=.commands[[i]],
                        text=line,
                        all=TRUE);
    }

    # write the contents
    writeLines(text=line, con=output);
  }

  .logger("Finished pre-processing contents from source file '",
          sourceFile,
          "' to output.");
}

#' @title Pre-Process a Document File
#' @description Pre-process the root file of a hierarchically structured
#'   document to a single monolithic output.
#' @param sourceFile the source file
#' @param destName the name of the destination file (to be created in the same
#'   folder as the source file)
#' @param bibliography do we have a bibliography?
#' @return the canonical path to the destination file
#' @include logger.R
#' @export preprocess.doc
preprocess.doc <- function(sourceFile, destName,
                           bibliography=TRUE) {
  # get the canonical path of the source file
  sourceFile <- check.file(sourceFile);

  # get the source directory
  sourceDir <- dirname(sourceFile);

  # create dest file
  destFile <- normalizePath(file.path(sourceDir, destName), mustWork = FALSE);
  if(file.exists(destFile)) {
    exit("Destination file '", destFile, "' already exists.");
  }

  output <- file(destFile, open="wt");
  destFile <- check.file(destFile);

  .logger("Pre-processing contents from main source file '",
         sourceFile,
         "' in source directory '",
         sourceDir,
         "' to output file '",
         destFile,
         "'.");

  # copy contents from source to destination and traverse directory where necessary
  .preprocess.input(sourceFile, sourceDir, output);

  # add proper bibliography section
  if((!(is.na(bibliography) || is.null(bibliography))) && bibliography) {
    writeLines(text=c("", "# Bibliography {-}"),
               con=output)
  }

  close(output);

  .logger("Finished pre-processing contents from main source file '",
         sourceFile,
         "' in source directory '",
         sourceDir,
         "' to output file '",
         destFile,
         "'.");
  return(destFile);
}