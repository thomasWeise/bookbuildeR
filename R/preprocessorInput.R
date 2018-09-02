
# resolve a path
#' @importFrom utilizeR path.relativize is.non.empty.vector is.non.empty.string
#' @include logger.R
.resolve.path <- function(path, currentDir, rootDir) {
  if((!(is.non.empty.vector(path))) ||
     (length(path) != 1L)) {
    exit("Incorrect arguments for resolving relative path.");
  }
  
  path <- path[[1L]];
  path <- force(path);
  if(!is.non.empty.string(path)) {
    exit("Error trying to resolve empty path relative to directory '",
         currentDir, "' towards '", rootDir, "'.");
  }
  
  path <- trimws(path);
  path <- force(path);
  if(!is.non.empty.string(path)) {
    exit("Error trying to resolve path '",
         path,
         "' composed only of white space relative to directory '",
         currentDir, "' towards '", rootDir, "'.");
  }

  path <- file.path(currentDir, path);
  path <- force(path);
  path <- check.file(path);
  path <- force(path);
  
  path <- path.relativize(path, rootDir);
  path <- force(path);
  check.file(file.path(rootDir, path));

  return(path);
}

# load a single file and pipe it to the output
#' @include logger.R
#' @importFrom utilizeR is.non.empty.string is.non.empty.vector
.load.file <- function(relativeFile, currentDir, rootDir, surroundByNewlines) {
  logger("Beginning to load file '",
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
  sourceFile <- file.path(currentDir, relativeFile);
  sourceFile <- force(sourceFile);
  sourceFile <- check.file(sourceFile);
  sourceFile <- force(sourceFile); 

  # get the current directory
  sourceDir <- dirname(sourceFile);
  sourceDir <- force(sourceDir);
  sourceDir <- check.dir(sourceDir);
  sourceDir <- force(sourceDir);

  # read the contents
  src  <- file(sourceFile, open="rt");
  text <- readLines(src);
  close(src);

  # ensure that there is text
  text <- force(text);
  if(is.non.empty.vector(text)) {
    text <- trimws(paste(text, sep="\n", collapse="\n"));
    text <- force(text);
    if(surroundByNewlines) {
      text <- paste("\n\n", text, "\n\n", sep="", collapse="");
      text <- force(text);
    }
  } else {
    exit("File '", sourceFile, "' has no text.");
  }
  
  # apply the relative path resolver
  text <- preprocess.regexp.groups(
    regex="\\\\relative\\.path\\{(.*?)\\}",
    func=.resolve.path,
    text=text,
    currentDir=sourceDir,
    rootDir=rootDir);
  text <- force(text);

  # recursively apply .load.file
  text <- preprocess.regexp.groups(
            regex="\\s*\\\\relative\\.input\\{(.*?)\\}\\s*",
            func=.load.file,
            text=text,
            currentDir=sourceDir,
            rootDir=rootDir,
            surroundByNewlines=TRUE);
  text <- force(text);

  if(is.non.empty.string(text)) {
    logger("Finished loading source file '",
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
#' @export preprocess.input
preprocess.input <- function(sourceFile) {
  logger("Recursively loading file '", sourceFile, "'.");

  # check if we can open the source file
  sourceFile <- check.file(sourceFile);
  sourceFile <- force(sourceFile);

  # get the current directory
  sourceDir <- dirname(sourceFile);
  sourceDir <- force(sourceDir);
  sourceDir <- check.dir(sourceDir);
  sourceDir <- force(sourceDir);

  # load the file
  text <- .load.file(basename(sourceFile), sourceDir, sourceDir, FALSE);
  text <- force(text);

  if(is.non.empty.string(text)) {
    text <- trimws(text);
    logger("Finished recursively loading file '",
            sourceFile, "', found ",
            nchar(text), " characters.");
    text <- force(text);
    return(text);
  }

  exit("Error loading file '", sourceFile,
       "' -- found no text.");
}
