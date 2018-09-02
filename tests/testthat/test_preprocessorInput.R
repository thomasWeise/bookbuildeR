library("bookbuildeR");
library("testthat");
context("preprocess.input");

test_that("Test preprocessor.input plain", {
  maindir <- tempfile();
  dir.create(maindir, showWarnings = FALSE, recursive=TRUE);
  
  root.file <- tempfile(tmpdir=maindir);
  root.text <- c("a", "b", "c");
  con       <- file(root.file, "wt");
  writeLines(text=root.text, con=con);
  close(con);
  
  text <- preprocess.input(root.file);
  expect_identical(text, "a\nb\nc");
  
  unlink(maindir, recursive=TRUE);
  expect_false(file.exists(root.file));
  expect_false(dir.exists(maindir));
})


test_that("Test preprocessor.input recursive same dir", {
  maindir <- tempfile();
  dir.create(maindir, showWarnings = FALSE, recursive=TRUE);
  
  root.dir <- tempfile(tmpdir = maindir);
  dir.create(root.dir, showWarnings = FALSE, recursive=TRUE);
  
  same.file <- tempfile(tmpdir=root.dir);
  same.text <- c("x", "y", "z");
  con       <- file(same.file, "wt");
  writeLines(text=same.text, con=con);
  close(con);
  
  root.file <- tempfile(tmpdir=root.dir);
  root.text <- c("a", "b",
                 paste("\\relative.input{", basename(same.file), "}", sep="", collapse=""),
                 "c");
  con       <- file(root.file, "wt");
  writeLines(text=root.text, con=con);
  close(con);

  text <- preprocess.input(root.file);
  expect_identical(text, "a\nb\n\nx\ny\nz\n\nc");
  
  unlink(maindir, recursive=TRUE);
  expect_false(dir.exists(maindir));
  expect_false(file.exists(root.file));
  expect_false(file.exists(same.file));
  expect_false(dir.exists(root.dir));
})

test_that("Test preprocessor.input recursive same dir with relative path", {
  maindir <- tempfile();
  dir.create(maindir, showWarnings = FALSE, recursive=TRUE);
  
  root.dir <- tempfile(tmpdir=maindir);
  dir.create(root.dir, recursive=TRUE);
  
  same.file <- tempfile(tmpdir=root.dir);
  same.text <- c("x", "y", "z");
  con       <- file(same.file, "wt");
  writeLines(text=same.text, con=con);
  close(con);
  
  root.file <- tempfile(tmpdir=root.dir);
  root.text <- c("a", "b",
                 paste("\\relative.input{", basename(same.file), "}", sep="", collapse=""),
                 paste("\\relative.path{", basename(same.file), "}", sep="", collapse=""),
                 "c");
  con       <- file(root.file, "wt");
  writeLines(text=root.text, con=con);
  close(con);
  
  text <- preprocess.input(root.file);
  expect_identical(text,
                   paste("a\nb\n\nx\ny\nz\n\n",
                         basename(same.file),
                   "\nc", sep="", collapse=""));
  
  unlink(maindir, recursive=TRUE);
  expect_false(dir.exists(maindir));
  expect_false(file.exists(root.file));
  expect_false(file.exists(same.file));
  expect_false(dir.exists(root.dir));
})


test_that("Test preprocessor.input recursive other dir", {
  maindir <- tempfile();
  dir.create(maindir, showWarnings = FALSE, recursive=TRUE);
  
  root.dir <- tempfile(tmpdir=maindir);
  dir.create(root.dir, recursive=TRUE);
  
  sub.dir <- tempfile(tmpdir=root.dir);
  dir.create(sub.dir);
  
  same.file <- tempfile(tmpdir=sub.dir);
  same.text <- c("x", "y", "z");
  con       <- file(same.file, "wt");
  writeLines(text=same.text, con=con);
  close(con);
  
  root.file <- tempfile(tmpdir=root.dir);
  root.text <- c("a", "b",
                 paste("\\relative.input{",
                      basename(sub.dir), "/", basename(same.file), "}",
                      sep="", collapse=""),
                 "c");
  con       <- file(root.file, "wt");
  writeLines(text=root.text, con=con);
  close(con);
  
  text <- preprocess.input(root.file);
  expect_identical(text, "a\nb\n\nx\ny\nz\n\nc");
  
  unlink(maindir, recursive=TRUE);
  expect_false(dir.exists(maindir));
  expect_false(file.exists(root.file));
  expect_false(file.exists(same.file));
  expect_false(dir.exists(root.dir));
  expect_false(dir.exists(sub.dir));
})


test_that("Test preprocessor.input recursive same dir with relative path", {
  maindir <- tempfile();
  dir.create(maindir, showWarnings = FALSE, recursive=TRUE);
  
  root.dir <- tempfile(tmpdir=maindir);
  dir.create(root.dir, recursive = TRUE);
  
  same.file <- tempfile(tmpdir=root.dir);
  same.text <- c("x", "y", "z");
  con       <- file(same.file, "wt");
  writeLines(text=same.text, con=con);
  close(con);
  
  root.file <- tempfile(tmpdir=root.dir);
  root.text <- c("a", "b",
                 paste("\\relative.input{", basename(same.file), "}", sep="", collapse=""),
                 paste("\\relative.path{", basename(same.file), "}", sep="", collapse=""),
                 "c");
  con       <- file(root.file, "wt");
  writeLines(text=root.text, con=con);
  close(con);
  
  text <- preprocess.input(root.file);
  expect_identical(text,
                   paste("a\nb\n\nx\ny\nz\n\n",
                         basename(same.file),
                         "\nc", sep="", collapse=""));
  
  unlink(maindir, recursive=TRUE);
  expect_false(dir.exists(maindir));
  expect_false(file.exists(root.file));
  expect_false(file.exists(same.file));
  expect_false(dir.exists(root.dir));
})


test_that("Test preprocessor.input recursive other dir with relative paths", {
  maindir <- tempfile();
  dir.create(maindir, showWarnings = FALSE, recursive=TRUE);
  
  root.dir <- tempfile(tmpdir=maindir);
  dir.create(root.dir, recursive=TRUE);
  
  sub.dir <- tempfile(tmpdir=root.dir);
  dir.create(sub.dir);
  
  same.file <- tempfile(tmpdir=sub.dir);
  same.text <- c("x", "y",
                 paste("v\\relative.path{",
                       basename(same.file), "}w",
                       sep="", collapse=""),
                 "z");
  con       <- file(same.file, "wt");
  writeLines(text=same.text, con=con);
  close(con);
  
  relpath <- paste(basename(sub.dir), "/", basename(same.file),
                   sep="", collapse="");
  
  root.file <- tempfile(tmpdir=root.dir);
  root.text <- c("a", "b",
                 paste("\\relative.input{",
                       basename(sub.dir), "/", basename(same.file), "}",
                       sep="", collapse=""),
                 paste("\\relative.path{",
                       relpath, "}",
                       sep="", collapse=""),
                 "c");
  con       <- file(root.file, "wt");
  writeLines(text=root.text, con=con);
  close(con);
  
  text <- preprocess.input(root.file);
  expect_identical(text, paste("a\nb\n\nx\ny\nv",
                               relpath,  
                               "w\nz\n\n",
                               relpath,
                                "\nc",
                               sep="", collapse=""));
  
  unlink(maindir, recursive=TRUE);
  expect_false(dir.exists(maindir));
  expect_false(file.exists(root.file));
  expect_false(file.exists(same.file));
  expect_false(dir.exists(root.dir));
  expect_false(dir.exists(sub.dir));
})



test_that("Test preprocessor.input recursive other 2 dirs with relative paths", {
  maindir <- tempfile();
  dir.create(maindir, showWarnings = FALSE, recursive=TRUE);
  
  root.dir <- tempfile(tmpdir=maindir);
  dir.create(root.dir, recursive=FALSE);
  
  sub.dir <- tempfile(tmpdir=root.dir);
  dir.create(sub.dir);
  
  sub.dir.2 <- tempfile(tmpdir=sub.dir);
  dir.create(sub.dir.2);
  
  same.file.2 <- tempfile(tmpdir=sub.dir.2);
  same.text.2 <- c("l", "m",
                   paste("\\relative.path{",
                         basename(same.file.2), "}",
                         sep="", collapse=""),
                   "n");
  
  con       <- file(same.file.2, "wt");
  writeLines(text=same.text.2, con=con);
  close(con);
  
  same.file <- tempfile(tmpdir=sub.dir);
  same.text <- c("x",
                 paste("\\relative.input{",
                       basename(sub.dir.2), "/",
                       basename(same.file.2), "}",
                       sep="", collapse=""),
                 "y",
                 paste("v\\relative.path{",
                       basename(same.file), "}w",
                       sep="", collapse=""),
                 "z");
  con       <- file(same.file, "wt");
  writeLines(text=same.text, con=con);
  close(con);
  
  relpath2 <- paste(basename(sub.dir), "/",
                    basename(sub.dir.2), "/",
                    basename(same.file.2),
                    sep="", collapse="");
  
  relpath <- paste(basename(sub.dir), "/",
                   basename(same.file),
                   sep="", collapse="");
  
  root.file <- tempfile(tmpdir=root.dir);
  root.text <- c("a", "b",
                 paste("\\relative.input{",
                       basename(sub.dir), "/",
                       basename(same.file), "}",
                       sep="", collapse=""),
                 paste("\\relative.path{",
                       relpath, "}",
                       sep="", collapse=""),
                 "c");
  con       <- file(root.file, "wt");
  writeLines(text=root.text, con=con);
  close(con);
  
  text <- preprocess.input(root.file);
  expect_identical(text, paste("a\nb\n\nx\n\nl\nm\n",
                               relpath2,
                               "\nn\n\ny\nv",
                               relpath,  
                               "w\nz\n\n",
                               relpath,
                               "\nc",
                               sep="", collapse=""));
  
  unlink(maindir, recursive=TRUE);
  expect_false(dir.exists(maindir));
  expect_false(file.exists(root.file));
  expect_false(file.exists(same.file));
  expect_false(file.exists(same.file.2));
  expect_false(dir.exists(root.dir));
  expect_false(dir.exists(sub.dir));
  expect_false(dir.exists(sub.dir.2));
})