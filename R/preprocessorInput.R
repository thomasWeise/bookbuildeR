
# resolve a path
#' @importFrom utilizeR path.relativize
#' @include logger.R
.resolve.path <- function(path, currentDir, rootDir) {
  if((!(is.non.empty.vector(path))) ||
     (length(path) != 1L)) {
    exit("Incorrect arguments for resolving relative path.");
  }
  path <- path[[1L]];

  if(!is.non.empty.string(path)) {
    exit("Error trying to resolve empty path relative to directory '",
         currentDir, "' towards '", rootDir, "'.");
  }
  path <- trimws(path);
  if(!is.non.empty.string(path)) {
    exit("Error trying to resolve path '",
         path,
         "' composed only of white space relative to directory '",
         currentDir, "' towards '", rootDir, "'.");
  }

  path <- check.file(file.path(currentDir, path));
  path <- path.relativize(path, rootDir);
  check.file(file.path(rootDir, path));

  return(path)
}

# load a single file and pipe it to the output
#' @include logger.R
#' @importFrom utilizeR is.non.empty.string
.load.file <- function(relativeFile, currentDir, rootDir) {
  .logger("Beginning to load file '",
          relativeFile, "' as relative path to '",
          currentDir, "'.");

  if((!(is.non.empty.vector(relativeFile))) ||
     (length(relativeFile) != 1L)) {
    exit("Incorrect arguments for recursively loading file.");
  }
  relativeFile <- relativeFile[[1L]];

  if(!is.non.empty.string(relativeFile)) {
    exit("Error trying to load file with empty name relative to directory '",
         currentDir, "'.");
  }
  relativeFile <- trimws(relativeFile);
  if(!is.non.empty.string(relativeFile)) {
    exit("Error trying to load file '",
         relativeFile, "' whose name is only white space relative to directory '",
         currentDir, "'.");
  }

  # check if we can open the source file
  sourceFile <- check.file(file.path(currentDir, relativeFile));

  # get the current directory
  sourceDir <- check.dir(dirname(sourceFile));

  # read the contents
  src <- file(sourceFile, open="rt");
  text <- readLines(src);
  close(src);

  text <- paste(text, sep="\n", collapse="\n");

  # recursively apply .load.file
  text <- preprocess.regexp(
    regex="\\\\.resolve.path\\{.+\\}",
    func=.resolve.path,
    text=text,
    rootDir=rootDir);

  # recursively apply .load.file
  text <- preprocess.regexp(
            regex="\\\\relative.input\\{.+\\}",
            func=.load.file,
            text=text,
            currentDir=sourceDir,
            rootDir=rootDir);

  if(is.non.empty.string(text)) {
    .logger("Finished loading source file '",
            sourceFile,
            "', found ", nchar(text),
            " characters.");
    return(text);
  }
  exit("Error loading file '",
       sourceFile,
       "' -- found no text.");
}


#' @title Recursively Load a Directory Structure
#' @description Load a source file and return it as text string, while
#'   recursively solving commands \code{relative.path} and
#'   \code{relative.input}.
#' @param sourceFile the source file path
#' @return the text string resulting from loading the file
#' @include logger.R
#' @importFrom utilizeR is.non.empty.string
preprocess.input <- function(sourceFile) {
  .logger("Recursively loading file '", sourceFile, "'.");

  # check if we can open the source file
  sourceFile <- check.file(sourceFile);

  # get the current directory
  sourceDir <- check.dir(dirname(sourceFile));

  text <- .loadFile(basename(sourceFile), sourceDir, sourceDir);

  if(is.non.empty.string(text)) {
    .logger("Finished recursively loading file '",
            sourceFile, "', found ",
            nchar(text), " characters.");
    return(trimws(text));
  }

  exit("Error loading file '", sourceFile,
       "' -- found no text.");
}
