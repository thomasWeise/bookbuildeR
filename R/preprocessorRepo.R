#' @title Pre-Process the Code Repository
#' @description Pre-process the code repository part of the documents. If a code
#'   repository is specified, download the repository, load the code, delete the
#'   repository.
#' @param text the basic text
#' @param metadata the parsed YAML meta data
#' @return the preprocessed text
#' @include logger.R
#' @include codeLoad.R
#' @include codeListing.R
#' @include getmeta.R
#' @export preprocess.repo
preprocess.repo <- function(text, metadata) {
  repository <- metadata.getCodeRepo(metadata);
  if(is.null(repository)) {
    .logger("No source code repository specified.");
    return(text);
  }
  .logger("Source code repository '", repository,
         "' repository specified.");
  
  repo <- git.clone(repository);
  
  # print the repo code
  text <- gsub("\\repo.commit", repo$commit, text, fixed=TRUE);
  if(endsWith(repository, ".git")) {
    repository <- substr(repository, 1L, (nchar(repository)-4L));
  }
  text <- gsub("\\repo.name", repository, text, fixed=TRUE);
  
  path <- repo$path;
  text <- preprocess.command(
    preprocess.command.regexp("repo.code", 3L),
    text,
    .code.load.wrap,
    basePath=path
  );
  
  codeBlockCaptions <- (isTRUE(metadata$codeBlockCaptions) ||
                        identical(metadata$codeBlockCaptions, "true"));
  .logger("Code block captions value '",
         metadata$codeBlockCaptions,
        "' lets to ", codeBlockCaptions, ".");
  text <- preprocess.command(
    preprocess.command.regexp("repo.listing", 6L),
    text,
    .code.listing.wrap,
    basePath=path,
    repo=repository,
    codeBlockCaptions=codeBlockCaptions
    );
  unlink(path, recursive = TRUE);

  return(text);
}
