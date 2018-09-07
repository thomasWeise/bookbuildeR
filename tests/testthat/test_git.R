library("bookbuildeR");
library("testthat");
context("git");

test_that("Test git.clone", {
  path <- git.clone("https://github.com/thomasWeise/bookbuildeR.git");
  expect_true(dir.exists(path));
  expect_true(file.exists(file.path(path, "LICENSE")));
  expect_true(file.exists(file.path(path, "DESCRIPTION")));
  expect_true(dir.exists(file.path(path, "R")));
  expect_true(file.exists(file.path(path, "R", "logger.R")));
  
  unlink(path, recursive = TRUE);
  expect_false(dir.exists(path));
})