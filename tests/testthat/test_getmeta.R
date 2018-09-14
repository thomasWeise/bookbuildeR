library("bookbuildeR");
library("testthat");
context("readmeta");

test_that("Test metadata.read with bibliography", {

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

  
  yaml <- metadata.get(paste(data, sep="\n", collapse="\n"));

  expect_false(is.null(yaml));
  expect_length(yaml, 12L);
  expect_identical(yaml$papersize, "a4");
  expect_identical(yaml$documentclass, "memoir");
  expect_identical(yaml$lang, "en-US");
  expect_identical(yaml$keywords, c("Optimization", "Metaheuristics", "Local Search", "Global Search"));
  expect_identical(yaml$author, "Thomas Weise");
  expect_identical(yaml$title, "An Introduction to Optimization Algorithms");
  expect_true(metadata.hasBibliography(yaml));
})


test_that("Test metadata.read without bibliography", {
  
  data <- c("---",
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
  
  
  yaml <- metadata.get(paste(data, sep="\n", collapse="\n"));
  
  expect_false(is.null(yaml));
  expect_length(yaml, 11L);
  expect_identical(yaml$papersize, "a4");
  expect_identical(yaml$documentclass, "memoir");
  expect_identical(yaml$lang, "en-US");
  expect_identical(yaml$keywords, c("Optimization", "Metaheuristics", "Local Search", "Global Search"));
  expect_identical(yaml$author, "Thomas Weise");
  expect_identical(yaml$title, "An Introduction to Optimization Algorithms");
  expect_false(metadata.hasBibliography(yaml));
})