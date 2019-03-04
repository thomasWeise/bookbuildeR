#' @title Use Calibre to Generate awz3 from epub
#' @description Use Calibre to Generate awz3 from epub
#' @param epubFile the path to the EPUB file (see \link{pandoc.epub})
#' @param destDir the destination directory
#' @param destName the base name of the destination file without extension
#' @return the canonical path to the destination file
#' @export calibre.azw3
#' @include logger.R
calibre.azw3<- function(epubFile,
                        destName=sub(pattern="\\..*", replacement="", x=basename(epubFile)),
                        destDir=dirname(epubFile)) {
  logger("Now building AWZ3 from EPUB file '", epubFile, "'.");

  epubFile <- check.file(epubFile);
  destDir <- check.dir(destDir);

  # create dest file
  destFile <- normalizePath(file.path(destDir, .paste(destFileName, ".azw3"), mustWork = FALSE));
  if(file.exists(destFile)) {
    exit("Destination file '", destFile, "' already exists.");
  }

  args <- c(epubFile,
            destFile,
            "--embed-all-fonts");

  # invoke calibre
  result <- system2("ebook-convert", args=args);

  # check result
  if(result != 0L) {
    exit("ebook-convert has failed with error code ", result, " for arguments '",
         paste(args, sep=" ", collapse=" "), "' in directory '", sourceDir, "'.");
  }
  destFile <- check.file(destFile);

  logger("Finished building a AWZ3 output '", destFile, "'.");
  return(destFile);
}
