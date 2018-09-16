library("bookbuildeR");
library("testthat");
context("code.listing");

make.file <- function() {
  file <- tempfile();
  handle <- file(file, "wt");
  writeLines(text=c(
    "  package a;",
    "/** aa",
    " * x",
    " */",
    "  class x {",
    "  }"
  ), con=handle);
  close(handle);
  return(file);
}

test_that("Test code.listing plain, with meta-comment removal", {
  file <- make.file();
  text <- code.listing("lst.ref", 
                         "blabla blabla.",
                         "java",
                         file, NULL,
                         NULL, NULL, NULL, TRUE);
  expect_equal(text,
               "```{#lst.ref .java caption=\"blabla blabla.\"}\npackage a;\nclass x {\n}\n```\n");
  unlink(file);
  expect_false(file.exists(file));
})

test_that("Test code.listing plain, no meta comment removal", {
  file <- make.file();
  text <- code.listing("lst.ref", 
                         "blabla blabla.",
                         "java",
                         file, NULL,
                         NULL, NULL, NULL, FALSE);
  expect_equal(text,
               "```{#lst.ref .java caption=\"blabla blabla.\"}\n  package a;\n/** aa\n * x\n */\n  class x {\n  }\n```\n");
  unlink(file);
  expect_false(file.exists(file));
})

test_that("Test code.listing with repo, with meta-comment removal", {
  file <- make.file();
  text <- code.listing("lst.ref", 
                         "blabla blabla.",
                         "java",
                         file, NULL,
                         NULL, NULL, "http://www.github.com/thomasWeise/bla", TRUE);
  expect_equal(text,
               paste(
               "```{#lst.ref .java caption=\"blabla blabla. ([src](http://www.github.com/thomasWeise/bla/blob/master",
               file,
               "))\"}\npackage a;\nclass x {\n}\n```\n",
               sep="", collapse=""));
  unlink(file);
  expect_false(file.exists(file));
})