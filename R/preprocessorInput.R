# Fix the svg/svgz problem of pandoc up to at least pandoc 2.5 (27 November 2018)
# The issue is reported and confirmed at http://github.com/jgm/pandoc/issues/5163
# The basic problem is that when converting markdown+svgz to EPUB, the svgz
# images are simply renamed to svg, but not decompressed (svgz is gzipped svg).
# Here we try to patch this in our path relativization by unpacking the images
# right where they are.
# This is only a temporary solution and will be removed once the issue is fixed.
# Because of this, we require R.utils, which otherwise would not be necessary.
#' @importFrom R.utils gunzip
.resolve.svgz <- function(path) {
  if(endsWith(path, ".svgz")) {
    dest <- substr(path, 1L, (nchar(path)-1L));
    gunzip(filename=path, destname=dest, skip=TRUE, remove=FALSE);
    return(check.file(dest));
  }
  return(path);
}

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
  path <- .resolve.svgz(path); # http://github.com/jgm/pandoc/issues/5163
  path <- force(path);

  path <- path.relativize(path, rootDir);
  path <- force(path);
  check.file(file.path(rootDir, path));

  return(path);
}

# load a single file and pipe it to the output
#' @include logger.R
#' @include codeLoad.R
#' @importFrom utilizeR is.non.empty.string is.non.empty.vector
.load.file <- function(relativeFile, currentDir, rootDir, .surroundByNewlines,
                       .regexp.lf, .regexp.rp, .regexp.lc,
                       .regexp.rs) {
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
  text <- tryCatch(readLines(src),
           error=function(e) exit("Error '", e,
                                  "' occured when reading input file '", src,
                                  "'."));
  close(src);

  # ensure that there is text
  text <- force(text);
  if(is.non.empty.vector(text)) {
    text <- trimws(paste(text, sep="\n", collapse="\n"));
    text <- force(text);
    if(.surroundByNewlines) {
      text <- paste("\n\n\n", text, "\n\n\n", sep="", collapse="");
      text <- force(text);
    }
  } else {
    exit("File '", sourceFile, "' has no text.");
  }

  # apply the relative path resolver
  text <- preprocess.command(.regexp.rp,
                    text, .resolve.path, currentDir=sourceDir, rootDir=rootDir);
  text <- force(text);

  # recursively apply .load.file
  text <- preprocess.command(.regexp.lf, text,
                    .load.file, currentDir=sourceDir, rootDir=rootDir,
                    .surroundByNewlines=TRUE, .regexp.lf=.regexp.lf,
                    .regexp.rp=.regexp.rp, .regexp.lc=.regexp.lc,
                    .regexp.rs=.regexp.rs);
  text <- force(text);

  # recursively apply code.load
  text <- preprocess.command(.regexp.lc, text,
                             .code.load.wrap,
                             basePath=sourceDir);
  text <- force(text);

  # recursively apply r.source
  text <- preprocess.command(.regexp.rs, text,
                             r.source,
                             basePath=sourceDir);
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
#' @include preprocessorCommand.R
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
  text <- .load.file(basename(sourceFile), sourceDir, sourceDir,
                     .surroundByNewlines=FALSE,
                     .regexp.lf=preprocess.command.regexp("relative.input", 1L,
                                                          stripWhiteSpace = TRUE),
                     .regexp.rp=preprocess.command.regexp("relative.path", 1L),
                     .regexp.lc=preprocess.command.regexp("relative.code", 3L),
                     .regexp.rs=preprocess.command.regexp("relative.r", 1L));
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
