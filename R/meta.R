
#' @title Get the Commit Identifier from the Environment
#' @description This function will only work if we build with travis.ci or have
#'   an environment variable \code{COMMIT} set. It loads the commit identifier
#'   from the environment.
#' @return a string identifying the commit of the repository for which we build
#' @export meta.commit
meta.commit <- function() {
  env.var <- "TRAVIS_COMMIT";
  commit <- Sys.getenv(x=env.var, unset=NA);
  if(is.null(commit) || is.na(commit)|| (length(commit) != 1L) || (nchar(commit) <= 0L)) {
    env.var.2 <- "COMMIT";
    commit <- Sys.getenv(x=env.var.2, unset=NA);
    if(is.null(commit) || is.na(commit)|| (length(commit) != 1L) || (nchar(commit) <= 0L)) {
      exit("Commit unknown because environment variables '",
           env.var,
           "' and '",
           env.var.2,
           "' are both not set. Set one of them by hand or build with travis.ci.");
    }
  }
  return(commit);
}

#' @title Get the Repository Identifier from the Environment
#' @description This function will only work if we build with travis.ci or have
#'   an environment variable \code{REPOSITORY} set. It loads the repository
#'   identifier from the environment.
#' @return a string identifying the repository for which we build
#' @export meta.repository
meta.repository <- function() {
  env.var <- "TRAVIS_REPO_SLUG";
  repo    <- Sys.getenv(x=env.var, unset=NA);
  if(is.null(repo) || is.na(repo) || (length(repo) != 1L) || (nchar(repo) <= 0L)) {
    env.var.2 <- "REPOSITORY";
    repo <- Sys.getenv(x=env.var.2, unset=NA);
    if(is.null(repo) || is.na(repo)|| (length(repo) != 1L) || (nchar(repo) <= 0L)) {
      exit("repository unknown because environment variables '",
           env.var,
           "' and '",
           env.var.2,
           "' are both not set. Set one of them by hand or build with travis.ci.");
    }
  }
  return(repo);
}

# make sure that we always return the same time
.env.dates <- new.env();

.init.time <- function() {
  if(!exists(".now", envir=.env.dates, inherits=FALSE)) {
    assign(".now", strftime(Sys.time(), format="%F %T UTC%z"), envir=.env.dates);
    assign(".date", strsplit(.env.dates$.now, " ", TRUE)[[1L]][1L], envir=.env.dates);
    assign(".year", strsplit(.env.dates$.now, "-", TRUE)[[1L]][1L], envir=.env.dates);
  }
}

#' @title Get the Current Date and Time
#' @description Get the current date and time as string.
#' @return the current date and time as string
#' @export meta.time
meta.time <- function() {
  .init.time();
  return(get(".now", envir=.env.dates, inherits=FALSE));
}

#' @title Get the Current Date
#' @description Get the current date as string.
#' @return the current date as string
#' @export meta.date
meta.date <- function() {
  .init.time();
  return(get(".date", envir=.env.dates, inherits=FALSE));
}

#' @title Get the Current Year
#' @description Get the current year as string.
#' @return the current year as string
#' @export meta.year
meta.year <- function() {
  .init.time();
  return(get(".year", envir=.env.dates, inherits=FALSE));
}
