library("bookbuildeR");
library("testthat");
context("preprocess.doc");

test_that("Test preprocess.doc", {
  dir <- tempfile();
  dir.create(dir, showWarnings = FALSE, recursive = TRUE);
  dir <- normalizePath(dir);

  root <- file.path(dir, "root.md");
  con <- file(root, "wt");
  writeLines(c("blabla \\relative.path{a/2.md}",
               "\\relative.input{a/2.md}",
               "\\relative.input{b/3.md}"),
             con=con);
  close(con);

  a <- file.path(dir, "a");
  dir.create(a, showWarnings = FALSE, recursive = TRUE);
  
  f <- file.path(a, "2.md");
  con <- file(f, "wt");
  writeLines("12345",
             con=con);
  close(con);

  b <- file.path(dir, "b");
  dir.create(b, showWarnings = FALSE, recursive = TRUE);
  f <- file.path(b, "3.md");
  con <- file(f, "wt");
  writeLines(c("\\relative.path{../root.md}",
               "x \\meta.time y"),
             con=con);
  close(con);

  text <- preprocess.plain(preprocess.input(root));
  
  dest <- preprocess.doc(root, "vv.md");
  expect_identical(dest, file.path(dir, "vv.md"));
  con <- file(dest, "rt");
  lines <- readLines(con);
  close(con);
  
  expect_identical(lines, c("blabla a/2.md",
                             "", "",
                             "12345",
                             "", "", "", "", "",
                             "root.md",
                             paste("x ", meta.time(), " y", sep="", collapse="")));
  lines <- paste(lines, sep="\n", collapse="\n");
  expect_identical(lines, text);
  
  unlink(dir, recursive=TRUE);
  expect_false(dir.exists(dir));
})
