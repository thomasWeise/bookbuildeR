#' @title Pre-Process the Code Repository
#' @description Pre-process the code repository part of the documents. If a code
#'   repository is specified, download the repository, load the code, delete the
#'   repository.
#' @param text the basic text
#' @param metadata the parsed YAML meta data
#' @return the preprocessed text
#' @include logger.R
#' @include codeLoad.R
#' @include getmeta.R
#' @export preprocess.repo
preprocess.repo <- function(text, metadata) {
  repo <- metadata.getCodeRepo(metadata);
  if(is.null(repo)) {
    logger("No source code repository specified.");
    return(text);
  }
  logger("Source code repository '", repo,
         "' repository specified.");
  
  repo <- git.clone(repo);
  path <- repo$path;
  text <- preprocess.command(
    preprocess.command.regexp("repo.code", 3L),
    text,
    function(params) code.load(params[[1L]], params[[2L]], params[[3L]], path)
  );
  unlink(path, recursive = TRUE);

  return(text);
}
