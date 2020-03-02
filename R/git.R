#' @title A Command for Cloning a Git Repository into a New Temporary Directory
#' @description Use the \code{git} system command to clone/download a git
#'   repository.
#' @param repo the repository url
#' @return a \code{list(path=path, commit=commit)} with the \code{path} to the cloned repository
#' and the current \code{commit}.
#' @include logger.R
#' @export git.clone
git.clone <- function(repo) {
  .logger("Begin cloning repo '", repo, "'.");
  
  destDir <- tempfile();
  dir.create(destDir);
  destDir <- .check.dir(destDir);
  
  ret <- system2("git", args=c("-C", destDir, "clone",
                               "--depth", "1",
                                repo, destDir));
  if(ret == 0L) {
    .logger("git clone of repo '", repo,
           "' successfully completed to path '",
           destDir);
    
    # get the commit id
    commit <- system2("git", args=c("-C", destDir, "log",
                                    "--no-abbrev-commit"),
                      stdout = TRUE, stderr = TRUE);
    ret <- attr(commit, "status"); # check return code
    if(is.null(ret) || (is.numeric(ret) && (ret == 0))) {
      if(length(commit) > 0L) { # check loaded data
        grepped <- grep("^\\s*commit\\s+.+", commit);
        if((!(is.null(grepped))) && (length(grepped) > 0L)) {
          # get the discovered commit
          commit <- trimws(commit[[grepped[[1L]]]]);
          commit.l <- nchar(commit);
          if(commit.l > 0L) { # check its trimmed version
            commit <- trimws(substr(commit, 7, commit.l));
            if(nchar(commit) == 40L) { # commit is right length
              .logger("Repository '",
                     repo, "' commit is '",
                     commit, "'.");
              return(list(path=destDir, commit=commit));
            }
          }
        }
      }
      unlink(destDir, recursive = TRUE);
      .exit("git log for cloned repo '", repo,
           "' in path '",
           destDir,
           "' resulted in invalid commit id.");
    } else {
      unlink(destDir, recursive = TRUE);
      .exit("git log for cloned repo '", repo,
           "' in path '",
           destDir,
           "' failed with error code ",
           ret, ".");
    }
  } else {
    unlink(destDir, recursive = TRUE);
    .exit("git clone of repo '", repo,
             "' to path '",
             destDir,
             "' failed with error code ",
             ret, ".");
  }
}