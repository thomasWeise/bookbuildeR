
#' @title Get the Commit Identifier from the Environment
#' @description This function will only work if we build with travis.ci. It
#'   loads the commit identifier from the environment.
#' @return a string identifying the commit of the repository for which we build
#' @export meta.commit
meta.commit <- function() {
  env.var <- "TRAVIS_COMMIT";
  commit <- Sys.getenv(x=env.var, unset=NA);
  if(is.null(commit) || is.na(commit)|| (length(commit) != 1L) || (nchar(commit) <= 0L)) {
    exit("Commit unknown because environment variable '",
         env.var,
         "' not set, maybe you are not building with travis.ci?");
  }
  return(commit);
}

#' @title Get the Repository Identifier from the Environment
#' @description This function will only work if we build with travis.ci. It
#'   loads the repository identifier from the environment.
#' @return a string identifying the repository for which we build
#' @export meta.repository
meta.repository <- function() {
  env.var <- "TRAVIS_REPO_SLUG";
  repo    <- Sys.getenv(x=env.var, unset=NA);
  if(is.null(repo) || is.na(repo) || (length(repo) != 1L) || (nchar(repo) <= 0L)) {
    exit("Repository unknown because environment variable '",
         env.var,
         "' not set, maybe you are not building with travis.ci?");
  }
  return(repo);
}

# make sure that we always return the same time
.now <- strftime(Sys.time(), format="%F %T");

#' @title Get the Current Date and Time
#' @description Get the current date as string.
#' @return the current date as string
#' @export meta.time
meta.time <- function() {
  return(.now);
}
