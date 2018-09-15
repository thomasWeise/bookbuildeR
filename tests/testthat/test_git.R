library("bookbuildeR");
library("testthat");
context("git");

test_that("Test git.clone http", {
  ret <- git.clone("http://github.com/thomasWeise/bookbuildeR.git");
  path <- ret$path;
  expect_identical(nchar(ret$commit), 40L);
  expect_true(dir.exists(path));
  expect_true(file.exists(file.path(path, "LICENSE")));
  expect_true(file.exists(file.path(path, "DESCRIPTION")));
  expect_true(dir.exists(file.path(path, "R")));
  expect_true(file.exists(file.path(path, "R", "logger.R")));
  
  unlink(path, recursive = TRUE);
  expect_false(dir.exists(path));
})


test_that("Test git.clone https", {
  ret <- git.clone("https://github.com/thomasWeise/bookbuildeR.git");
  path <- ret$path;
  expect_identical(nchar(ret$commit), 40L);
  expect_true(dir.exists(path));
  expect_true(file.exists(file.path(path, "LICENSE")));
  expect_true(file.exists(file.path(path, "DESCRIPTION")));
  expect_true(dir.exists(file.path(path, "R")));
  expect_true(file.exists(file.path(path, "R", "logger.R")));
  
  unlink(path, recursive = TRUE);
  expect_false(dir.exists(path));
})


test_that("Test git.clone ssh", {
  if(is.na(Sys.getenv("TRAVIS", unset=NA))) {
    ret <- git.clone("ssh://git@github.com/thomasWeise/bookbuildeR.git");
    path <- ret$path;
    expect_identical(nchar(ret$commit), 40L);
    expect_true(dir.exists(path));
    expect_true(file.exists(file.path(path, "LICENSE")));
    expect_true(file.exists(file.path(path, "DESCRIPTION")));
    expect_true(dir.exists(file.path(path, "R")));
    expect_true(file.exists(file.path(path, "R", "logger.R")));
    
    unlink(path, recursive = TRUE);
    expect_false(dir.exists(path));
  } else {
    expect_true(TRUE);
  }
})