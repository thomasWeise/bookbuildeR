library("bookbuildeR");
library("testthat");
context("preprocess.textblocks");

test_that("Test preprocess.doc 1 definition", {
  result <- preprocess.textblocks(
    "xyz\\text.block{definition}{label}{body.}abc"
  );
  expect_identical(result,
                   "xyz\n\n**Definition&nbsp;1.**&nbsp;body.\n\nabc");
})

test_that("Test preprocess.doc 2 definition", {
  result <- preprocess.textblocks(
    "xyz\\text.block{definition}{label}{body.}abc\\text.block{definition}{label2}{body2.}lmn"
  );
  expect_identical(result,
                   "xyz\n\n**Definition&nbsp;1.**&nbsp;body.\n\nabc\n\n**Definition&nbsp;2.**&nbsp;body2.\n\nlmn");
})


test_that("Test preprocess.doc 2 definition and references", {
  result <- preprocess.textblocks(
    "x\\text.ref{label2}yz\\text.block{definition}{label}{body.}abc\\text.block{definition}{label2}{body2.}l\\text.ref{label}mn"
  );
  expect_identical(result,
                   "xDefinition&nbsp;2yz\n\n**Definition&nbsp;1.**&nbsp;body.\n\nabc\n\n**Definition&nbsp;2.**&nbsp;body2.\n\nlDefinition&nbsp;1mn");
})
