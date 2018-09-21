library("bookbuildeR");
library("testthat");
context("r.source");

make.file <- function(code) {
  path <- tempfile();
  handle <- file(path, "wt");
  writeLines(text=code, con=handle);
  close(handle);
  return(path);
}

test_that("Test r.source with return value", {
  code <- make.file("5");
  text <- r.source(code);
  expect_identical(text, "5");
  
  code <- make.file("5;6");
  text <- r.source(code);
  expect_identical(text, "6");
})

test_that("Test r.source with cat", {
  code <- make.file("cat(5)");
  text <- r.source(code);
  expect_identical(text, "5");
  
  code <- make.file("cat(5);6");
  text <- r.source(code);
  expect_identical(text, "5");
})

test_that("Test r.source with complex return value", {
  code <- make.file("1:5");
  text <- r.source(code);
  expect_identical(text, "1\n2\n3\n4\n5");
  
  code <- make.file("paste(1:5, collapse=\",\")");
  text <- r.source(code);
  expect_identical(text, "1,2,3,4,5");
})

test_that("Test r.source with complex code", {
  code <- make.file("for(i in 1:5) {\ncat(2*i);\n}");
  text <- r.source(code);
  expect_identical(text, "246810");
})

test_that("Test r.source with function code", {
  code <- make.file("f <- function(i, j) 3*i-j\nfor(i in 1:5) {\ncat(f(i,2*i));\n}");
  text <- r.source(code);
  expect_identical(text, "12345");
  
  code <- make.file("f <- function(i, j) 3*i-j\nf(5,6)");
  text <- r.source(code);
  expect_identical(text, "9");
})