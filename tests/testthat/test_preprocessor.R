library("bookbuildeR")
context("preprocess.doc")

test_that("Test preprocess.doc", {
  dir <- tempdir();
  dir.create(dir, showWarnings = FALSE, recursive = TRUE);
  dir <- normalizePath(dir);

  root <- file.path(dir, "root.md");
  writeLines(c("blabla \\relative.path{a/2.md}",
               "\\relative.input{a/2.md}",
               "\\relative.input{b/3.md}"),
             root);

  a <- file.path(dir, "a");
  dir.create(a, showWarnings = FALSE, recursive = TRUE);
  f <- file.path(a, "2.md");
  writeLines("12345", f);

  b <- file.path(dir, "b");
  dir.create(b, showWarnings = FALSE, recursive = TRUE);
  f <- file.path(b, "3.md");
  writeLines(c("\\relative.path{../root.md}",
               "x \\meta.time y"), f);

  dest <- preprocess.doc(root, "vv.md");
  expect_identical(dest, file.path(dir, "vv.md"));
  expect_identical(readLines(dest), c("blabla a/2.md",
                                      "",
                                      "12345",
                                      "",
                                      "root.md",
                                      paste("x ", meta.time(), " y", sep="", collapse="")));

  unlink(dir, recursive=TRUE);
})
