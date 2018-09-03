library("bookbuildeR");
library("testthat");
context("preprocess.regexp");

test_that("Test preprocess.regexp", {
  expect_identical(preprocess.regexp(
    "hallo",
    "asdf hallo dfgfdg",
    toupper
  ), "asdf HALLO dfgfdg");

  expect_identical(preprocess.regexp(
    "ha[l,x]lo",
    "asdf hallohaxlo dfgfdg",
    toupper
  ), "asdf HALLOHAXLO dfgfdg");

  f <- function(i, j) paste(toupper(i), j, sep="", collapse="");

  expect_identical(preprocess.regexp(
    "\\\\ha[l,x]lo",
    "asdf \\hallo \\haxlo dfgfdg",
    f,
    j=2
  ), "asdf \\HALLO2 \\HAXLO2 dfgfdg");
})
