library("bookbuildeR");
library("testthat");
context("templates");

test_that("Test template.load", {
  dir <- tempdir();
  dir.create(dir, showWarnings = FALSE, recursive=TRUE);

  f <- template.load("eisvogel.latex", dir);
  expect_true(file.exists(f));
  f <- template.load("eisvogel-article.latex", dir);
  expect_true(file.exists(f));
  f <- template.load("eisvogel-book.latex", dir);
  expect_true(file.exists(f));

  f <- template.load("GitHub.html5", dir);
  expect_true(file.exists(f));

  f <- template.load("http://raw.githubusercontent.com/Wandmalfarbe/pandoc-latex-template/master/eisvogel.tex", dir);
  expect_true(file.exists(f));

  f <- template.load("http://github.com/qualiacode/arabica/blob/master/controls/arabica.latex", dir);
  expect_true(file.exists(f));

  f <- template.load("http://raw.githubusercontent.com/tajmone/pandoc-goodies/master/templates/html5/github/GitHub.html5", dir);
  expect_true(file.exists(f));

  unlink(dir, recursive = TRUE);
})
