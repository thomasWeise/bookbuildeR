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

test_that("Test code.listing plain, with meta-comment removal and normal captions", {
  file <- make.file();
  text <- code.listing("lst.ref", 
                         "blabla blabla.",
                         "java",
                         file, NULL,
                         NULL, NULL, NULL,
                         codeBlockCaptions=FALSE,
                         removeMetaComments=TRUE);
  expect_equal(text,
               "\n\n```{#lst.ref .java .numberLines caption=\"blabla blabla.\"}\nclass x {\n}\n```\n");
  unlink(file);
  expect_false(file.exists(file));
})

test_that("Test code.listing plain, no meta comment removal and normal captions", {
  file <- make.file();
  text <- code.listing("lst.ref", 
                         "blabla blabla.",
                         "java",
                         file, NULL,
                         NULL, NULL, NULL,
                         codeBlockCaptions=FALSE,
                         removeMetaComments=FALSE,
                         removeUnnecessary=FALSE);
  expect_equal(text,
               "\n\n```{#lst.ref .java .numberLines caption=\"blabla blabla.\"}\n  package a;\n/** aa\n * x\n */\n  class x {\n  }\n```\n");
  unlink(file);
  expect_false(file.exists(file));
})

test_that("Test code.listing with repo, with meta-comment removal and normal captions", {
  file <- make.file();
  text <- code.listing("lst.ref", 
                         "blabla blabla.",
                         "java",
                         file, NULL,
                         NULL, NULL, "http://www.github.com/thomasWeise/bla",
                         codeBlockCaptions=FALSE,
                         removeMetaComments=TRUE);
  expect_equal(text,
               paste(
               "\n\n```{#lst.ref .java .numberLines caption=\"blabla blabla. ([src](http://www.github.com/thomasWeise/bla/blob/master",
               file,
               "))\"}\nclass x {\n}\n```\n",
               sep="", collapse=""));
  unlink(file);
  expect_false(file.exists(file));
})




test_that("Test code.listing plain, with meta-comment removal and codeblock captions", {
  file <- make.file();
  text <- code.listing("lst.ref", 
                       "blabla blabla.",
                       "java",
                       file, NULL,
                       NULL, NULL, NULL,
                       codeBlockCaptions=TRUE,
                       removeMetaComments=TRUE);
  expect_equal(text,
               "\n\nListing: blabla blabla.\n\n```{#lst.ref .java .numberLines}\nclass x {\n}\n```\n");
  unlink(file);
  expect_false(file.exists(file));
})

test_that("Test code.listing plain, no meta comment removal and codeblock captions", {
  file <- make.file();
  text <- code.listing("lst.ref", 
                       "blabla blabla.",
                       "java",
                       file, NULL,
                       NULL, NULL, NULL,
                       codeBlockCaptions=TRUE,
                       removeMetaComments=FALSE,
                       removeUnnecessary=FALSE);
  expect_equal(text,
               "\n\nListing: blabla blabla.\n\n```{#lst.ref .java .numberLines}\n  package a;\n/** aa\n * x\n */\n  class x {\n  }\n```\n");
  unlink(file);
  expect_false(file.exists(file));
})

test_that("Test code.listing with repo, with meta-comment removal and codeblock captions", {
  file <- make.file();
  text <- code.listing("lst.ref", 
                       "blabla blabla.",
                       "java",
                       file, NULL,
                       NULL, NULL, "http://www.github.com/thomasWeise/bla",
                       codeBlockCaptions=TRUE,
                       removeMetaComments=TRUE);
  expect_equal(text,
               paste(
                 "\n\nListing: ",
                 "blabla blabla. ([src](http://www.github.com/thomasWeise/bla/blob/master",
                 file,
                 "))\n\n",
                 "```{#lst.ref .java .numberLines}\nclass x {\n}\n```\n",
                 sep="", collapse=""));
  unlink(file);
  expect_false(file.exists(file));
})