library("bookbuildeR");
library("testthat");
context("preprocess.input");

test_that("Test preprocessor.input plain", {
  root.file <- tempfile();
  root.text <- c("a", "b", "c");
  con       <- file(root.file, "wt");
  writeLines(text=root.text, con=con);
  close(con);
  
  text <- preprocess.input(root.file);
  expect_identical(text, "a\nb\nc");
  
  unlink(root.file);
  expect_false(file.exists(root.file));
})


test_that("Test preprocessor.input recursive same dir", {
  root.dir <- tempfile();
  dir.create(root.dir);
  
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
  expect_identical(text, "a\nb\nx\ny\nz\nc");
  
  unlink(root.dir, recursive=TRUE);
  expect_false(file.exists(root.file));
  expect_false(file.exists(same.file));
  expect_false(dir.exists(root.dir));
})

test_that("Test preprocessor.input recursive same dir with relative path", {
  root.dir <- tempfile();
  dir.create(root.dir);
  
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
                   paste("a\nb\nx\ny\nz\n",
                         basename(same.file),
                   "\nc", sep="", collapse=""));
  
  unlink(root.dir, recursive=TRUE);
  expect_false(file.exists(root.file));
  expect_false(file.exists(same.file));
  expect_false(dir.exists(root.dir));
})


test_that("Test preprocessor.input recursive other dir", {
  root.dir <- tempfile();
  dir.create(root.dir);
  
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
  expect_identical(text, "a\nb\nx\ny\nz\nc");
  
  unlink(root.dir, recursive=TRUE);
  expect_false(file.exists(root.file));
  expect_false(file.exists(same.file));
  expect_false(dir.exists(root.dir));
  expect_false(dir.exists(sub.dir));
})


test_that("Test preprocessor.input recursive same dir with relative path", {
  root.dir <- tempfile();
  dir.create(root.dir);
  
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
                   paste("a\nb\nx\ny\nz\n",
                         basename(same.file),
                         "\nc", sep="", collapse=""));
  
  unlink(root.dir, recursive=TRUE);
  expect_false(file.exists(root.file));
  expect_false(file.exists(same.file));
  expect_false(dir.exists(root.dir));
})


test_that("Test preprocessor.input recursive other dir with relative paths", {
  root.dir <- tempfile();
  dir.create(root.dir);
  
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
  expect_identical(text, paste("a\nb\nx\ny\nv",
                               relpath,  
                               "w\nz\n",
                               relpath,
                                "\nc",
                               sep="", collapse=""));
  
  unlink(root.dir, recursive=TRUE);
  expect_false(file.exists(root.file));
  expect_false(file.exists(same.file));
  expect_false(dir.exists(root.dir));
  expect_false(dir.exists(sub.dir));
})



test_that("Test preprocessor.input recursive other 2 dirs with relative paths", {
  root.dir <- tempfile();
  dir.create(root.dir);
  
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
  expect_identical(text, paste("a\nb\nx\nl\nm\n",
                               relpath2,
                               "\nn\ny\nv",
                               relpath,  
                               "w\nz\n",
                               relpath,
                               "\nc",
                               sep="", collapse=""));
  
  unlink(root.dir, recursive=TRUE);
  expect_false(file.exists(root.file));
  expect_false(file.exists(same.file));
  expect_false(file.exists(same.file.2));
  expect_false(dir.exists(root.dir));
  expect_false(dir.exists(sub.dir));
  expect_false(dir.exists(sub.dir.2));
})