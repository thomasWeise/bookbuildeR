library("bookbuildeR");
library("testthat");
context("r.exec");

test_that("Test r.exec with return value", {
  code <- "5";
  text <- r.exec(code);
  expect_identical(text, "5");
  
  code <- "5;6";
  text <- r.exec(code);
  expect_identical(text, "6");
})

test_that("Test r.exec with cat", {
  code <- "cat(5)";
  text <- r.exec(code);
  expect_identical(text, "5");
  
  code <- "cat(5);6";
  text <- r.exec(code);
  expect_identical(text, "5");
})

test_that("Test r.exec with complex return value", {
  code <- "1:5";
  text <- r.exec(code);
  expect_identical(text, "1\n2\n3\n4\n5");
  
  code <- "paste(1:5, collapse=\",\")";
  text <- r.exec(code);
  expect_identical(text, "1,2,3,4,5");
})

test_that("Test r.exec with complex code", {
  code <- "for(i in 1:5) {\ncat(2*i);\n}";
  text <- r.exec(code);
  expect_identical(text, "246810");
})

test_that("Test r.exec with function code", {
  code <- "f <- function(i, j) 3*i-j\nfor(i in 1:5) {\ncat(f(i,2*i));\n}";
  text <- r.exec(code);
  expect_identical(text, "12345");
  
  code <- "f <- function(i, j) 3*i-j\nf(5,6)";
  text <- r.exec(code);
  expect_identical(text, "9");
})