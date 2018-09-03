library("bookbuildeR");
library("testthat");
context("preprocess.textblocks");

test_that("Test preprocess.doc 1 definition", {
  result <- preprocess.textblocks(
    "xyz\\text.block{definition}{label}{body.}abc"
  );
  expect_identical(result,
                   "xyz\n\n\n**Definition&nbsp;1.**&nbsp;body.\n\n\nabc");
})
