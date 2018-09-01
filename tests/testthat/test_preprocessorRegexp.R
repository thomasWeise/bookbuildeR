library("bookbuildeR");
library("testthat");
context("preprocess.regexp");

test_that("Test preprocess.regexp.no.groups", {
  expect_identical(preprocess.regexp.no.groups(
    "hallo",
    "asdf hallo dfgfdg",
    toupper
  ), "asdf HALLO dfgfdg");
  
  expect_identical(preprocess.regexp.no.groups(
    "ha[l,x]lo",
    "asdf hallohaxlo dfgfdg",
    toupper
  ), "asdf HALLOHAXLO dfgfdg");
  
  f <- function(i, j) paste(toupper(i), j, sep="", collapse="");
  
  expect_identical(preprocess.regexp.no.groups(
    "\\\\ha[l,x]lo",
    "asdf \\hallo \\haxlo dfgfdg",
    f,
    j=2
  ), "asdf \\HALLO2 \\HAXLO2 dfgfdg");
})

test_that("Test preprocess.regexp.groups", {
  expect_identical(preprocess.regexp.groups(
    "ha(l)lo",
    "asdf hallo dfgfdg",
    toupper
  ), "asdf L dfgfdg");
  
  f <- function(x, j) paste(x, sep=j, collapse=j);
  
  expect_identical(preprocess.regexp.groups(
    "ha(l)l(o)",
    "asdf hallo dfgfdg",
    f,
    j=" "
  ), "asdf l o dfgfdg");
  
  expect_identical(preprocess.regexp.groups(
    "\\\\a\\{(.*?)\\}\\{(.*?)\\}",
    "asdf \\a{1}{2} dfgfdg \\a{xxx}{zzz} fdfgfdg",
    f,
    j="-"
  ), "asdf 1-2 dfgfdg xxx-zzz fdfgfdg");
})