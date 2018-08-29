library("bookbuildeR")
context("readmeta")

test_that("Test metadata.read", {

  data <- c("blablabla",
            "dgdfgdg",
            "",
            "---",
            "title:  An Introduction to Optimization Algorithms",
            "",
            "author: Thomas Weise",
            "keywords: [Optimization, Metaheuristics, Local Search, Global Search]",
            "",
            "abstract: |",
            "In this book, I try to give an introduction to optimization algorithms.",
            "",
            "lang: en-US",
            "",
            "bibliography: bibliography.bib",
            "",
            "csl: http://www.zotero.org/styles/association-for-computing-machinery",
            "link-citations: true",
            "",
            "documentclass: memoir",
            "fontfamily: mathpazo",
            "pagestyle: headings",
            "papersize: a4",
            "...",
            "xvxvc",
            "",
            "sfsdf");

  tmpfile <- tempfile();
  dir.create(path=dirname(tmpfile), showWarnings = FALSE, recursive = TRUE);
  handle <- file(tmpfile, open="wt");
  writeLines(text=data, con=handle);
  close(handle);

  yaml <- metadata.read(tmpfile);
  file.remove(tmpfile);

  expect_false(is.null(yaml));
  expect_length(yaml, 12L);
  expect_identical(yaml$papersize, "a4");
  expect_identical(yaml$documentclass, "memoir");
  expect_identical(yaml$lang, "en-US");
  expect_identical(yaml$keywords, c("Optimization", "Metaheuristics", "Local Search", "Global Search"));
  expect_identical(yaml$author, "Thomas Weise");
  expect_identical(yaml$title, "An Introduction to Optimization Algorithms");
})
