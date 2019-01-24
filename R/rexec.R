#' @title Execute the provided R code and return the output
#' @description Execute the R code provided as input and return a string
#'   containing all of its output. If the code prints output, say with
#'   \code{cat}, e.g., as in \code{"cat(5);cat(6)"}, then that output is
#'   returned as single collapsed string. If the code just returns a value,
#'   e.g., \code{"5"}, then this value will be converted to a collapsed string
#'   and returned.
#' @param code the R code
#' @export r.exec
#' @importFrom utilizeR is.non.empty.string
#' @include logger.R
#' @importFrom utils capture.output
r.exec <- function(code) {
  code <- paste(code, sep="\n", collapse="\n");
  code <- force(code);
  if(is.non.empty.string(code)) {
    code <- trimws(code);
    code <- force(code);
    if(is.non.empty.string(code)) {
      parsed <- parse(text=code);
      parsed <- force(parsed);
      res.1 <- capture.output(invisible(res.2 <- eval(parsed)));
      res.1 <- paste(res.1, sep="\n", collapse="\n");
      if(is.non.empty.string(res.1)) {
        res.1 <- res.1;
        res.1 <- force(res.1);
        return(res.1);
      } else {
        if(!(is.null(res.2))) {
          res.2 <- force(res.2);
          res.2 <- paste(as.character(res.2), sep="\n", collapse="\n");
          if(is.non.empty.string(res.2)) {
            res.2 <- force(res.2);
            return(res.2);
          } else {
            exit("R code '", code, "' has neither output nor a non-empty string result.");
          }
        } else {
          exit("R code '", code, "' has neither output nor a non-null result.");
        }
      }
    } else {
      exit("R code cannot just consist of white space.");
    }
  } else {
    exit("R code cannot empty.");
  }
}
