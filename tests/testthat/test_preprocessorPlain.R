library("bookbuildeR");
library("testthat");
context("preprocess.plain");

test_that("Test preprocess.plain", {
  text.1 <- preprocess.plain("abc\\meta.datedef\\meta.timeghi\n\\direct.r{5+6}");
  text.2 <- paste("abc",
                  meta.date(),
                  "def",
                  meta.time(),
                  "ghi",
                  "11",
                  sep="", collapse="");
  expect_identical(text.1, text.2);
})