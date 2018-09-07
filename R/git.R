#' @title A Command for Cloning a Git Repository into a New Temporary Directory
#' @description Use the \code{git} system command to clone/download a git
#'   repository.
#' @param repo the repository url
#' @return the path to the cloned repository
#' @include logger.R
#' @export git.clone
git.clone <- function(repo) {
  logger("Begin cloning repo '", repo, "'.");
  
  destDir <- tempfile();
  dir.create(destDir);
  destDir <- check.dir(destDir);
  
  ret <- system2("git", args=c("-C", destDir, "clone",
                               "--depth", "1",
                                repo, destDir));
  if(ret == 0L) {
    logger("git clone of repo '", repo,
           "' successfully completed to path '",
           destDir);
  } else {
    unlink(destDir, recursive = TRUE);
    logger("git clone of repo '", repo,
           "' to path '",
           destDir,
           "' failed with error code ",
           ret, ".");
  }
  return(destDir);
}