library("bookbuildeR");
library("testthat");
context("preprocess.repo");

test_that("Test preprocess.repo", {
  path.short <- "test_templates.R";
  path.full <- paste("tests/testthat/", path.short, sep="", collapse="");
  f <- path.short;
  if(!(file.exists(f))) {
    f <- path.full;
    if(!(file.exists(f))) {
      testthat::fail("Source file of test not found");
    }
  }
  
  handle <- file(f, "rt");
  code <- readLines(handle);
  close(handle);
  code <- trimws(code, which="right");
  
  text <- preprocess.repo(paste("\\repo.name\n\\repo.code{", path.full, "}{}{}\n\\repo.commit",
                                sep="", collapse=""),
                            metadata=list(a=5,codeRepo="https://github.com/thomasWeise/bookbuildeR.git",c=5));
  
  text <- strsplit(text, "\n", fixed=TRUE)[[1L]];
  expect_identical(text[[1L]], "https://github.com/thomasWeise/bookbuildeR");
  expect_identical(text[2L:(length(text)-1L)], code);
  expect_identical(nchar(text[[length(text)]]), 40L);
})