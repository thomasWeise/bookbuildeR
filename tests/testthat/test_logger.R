library("bookbuildeR");
library("testthat");
context("logger");

test_that("Test logger", {
  expect_false(is.null(logger));
  expect_true(is.function(logger));
  logger("aa", "bb");
})


test_that("Test check.file", {
  f <- tempfile();
  file.create(f);
  expect_identical(check.file(f, nonZeroSize=FALSE), f);
  
  con <- file(f, "wt");
  writeLines(text=c("a", "b"), con=con);
  close(con);
  expect_identical(check.file(f, nonZeroSize=TRUE), f);
  
  file.remove(f);
  unlink(f);
  expect_false(file.exists(f));
})


test_that("Test check.dir", {
  dir <- tempfile();
  dir.create(dir);
  expect_identical(check.dir(dir), dir);
  unlink(dir, recursive = TRUE);
  expect_false(dir.exists(dir));
})