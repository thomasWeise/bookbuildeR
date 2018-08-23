#' @importFrom utilizeR makeLogger
.logger <- makeLogger(TRUE);

#' @title Quit the Processing with an Error
#' @describeIn Well, exit the current process, throw an error.
#' @param ... the error message
#' @export exit
exit <- function(...) {
  .logger(...);
  q(status=1L);
}
