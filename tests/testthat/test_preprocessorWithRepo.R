library("bookbuildeR");
library("testthat");
context("preprocess.doc");

test_that("Test preprocess.doc with repo", {
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
  code <- trimws(paste(code, sep="\n", collapse="\n"));
  
  dir <- tempfile();
  dir.create(dir, showWarnings = FALSE, recursive = TRUE);
  dir <- normalizePath(dir);

  root <- file.path(dir, "root.md");
  con <- file(root, "wt");
  writeLines(c("---",
               "codeRepo: http://github.com/thomasWeise/bookbuildeR.git",
               "...",
               "blabla \\relative.path{a/2.md}",
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
               "x \\meta.time y",
               paste("\\repo.code{",
                     path.full, "}{}{}",
                     sep="", collapse = "")),
             con=con);
  close(con);

  dest <- preprocess.doc(root, "vv.md")$path;
  expect_identical(dest, file.path(dir, "vv.md"));
  con <- file(dest, "rt");
  lines <- readLines(con);
  close(con);

  expect_identical(lines, c("---",
                            "codeRepo: http://github.com/thomasWeise/bookbuildeR.git",
                            "...",
                            "blabla a/2.md",
                             "", "",
                             "12345",
                             "", "", "", "", "",
                             "root.md",
                             paste("x ", meta.time(), " y",
                                   sep="", collapse=""),
                             strsplit(code, "\n", fixed=TRUE)[[1L]]
                            ));

  unlink(dir, recursive=TRUE);
  expect_false(dir.exists(dir));
})