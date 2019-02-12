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
  expect_null(metadata.getCodeRepo(yaml));
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
  expect_null(metadata.getCodeRepo(yaml));
})


test_that("Test metadata.read with code repo", {
  
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
            "codeRepo: https://github.com/thomasWeise/bookbuildeR.git",
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
  expect_identical(metadata.getCodeRepo(yaml), "https://github.com/thomasWeise/bookbuildeR.git");
  expect_false(metadata.hasBibliography(yaml));
})




test_that("Test metadata.read with code repo and bibliography", {
  
  data <- c("blablabla",
            "dgdfgdg",
            "",
            "---",
            "title:  An Introduction to Optimization Algorithms",
            "",
            "author: Thomas Weise",
            "keywords: [Optimization, Metaheuristics, Local Search, Global Search]",
            "",
            "codeRepo: https://github.com/thomasWeise/bookbuildeR.git",
            "bibliography: bibliography.bib",
            "abstract: |",
            "In this book, I try to give an introduction to optimization algorithms.",
            "",
            "lang: en-US",
            "",
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
  expect_length(yaml, 13L);
  expect_identical(yaml$papersize, "a4");
  expect_identical(yaml$documentclass, "memoir");
  expect_identical(yaml$lang, "en-US");
  expect_identical(yaml$keywords, c("Optimization", "Metaheuristics", "Local Search", "Global Search"));
  expect_identical(yaml$author, "Thomas Weise");
  expect_identical(yaml$title, "An Introduction to Optimization Algorithms");
  
  expect_identical(metadata.getCodeRepo(yaml), "https://github.com/thomasWeise/bookbuildeR.git");
  expect_true(metadata.hasBibliography(yaml));
})


test_that("Test metadata.read with raw attribute", {
  
  data <- c(
    "sdfgsdfg",
    "---",
    "# book metadata",
    "title:  An Introduction to Optimization Algorithms",
    "author: [Thomas Weise]",
    "date: \"2018-01-12\"",
    "keywords: [Optimization, Metaheuristics, Local Search, Global Search]",
    "rights: © 2018 Thomas Weise, CC BY-NC-SA 4.0",
    "lang: en-US",
    "",
    "# reference to associated code repository",
    "codeRepo: http://github.com/thomasWeise/aitoa-code.git",
    "",
    "# bibliography metadata",
    "bibliography: bibliography.bib",
    "csl: http://www.zotero.org/styles/association-for-computing-machinery",
    "link-citations: true",
    "",
    "# LaTeX template metadata",
    "template.latex: eisvogel-book.latex",
    "titlepage: true",
    "titlepage-color: \"9F2925\"",
    "titlepage-text-color: \"FFFFFF\"",
    "titlepage-rule-color: \"E67015\"",
    "toc-own-page: true",
    "linkcolor: blue!50!black",
    "citecolor: blue!50!black",
    "urlcolor: blue!50!black",
    "toccolor: black",
    "",
    "# hold floating objects in the same section and sub-section",
    "header-includes:",
    "- |",
    "  ```{=latex}",
    "  \\usepackage[section,above,below]{placeins}",
    "  \\let\\Oldsubsection\\subsection",
    "  \\renewcommand{\\subsection}{\\FloatBarrier\\Oldsubsection}",
    "  ```",
    "",
    "# pandoc-crossref setup",
    "cref: true",
    "chapters: true",
    "figPrefix:",
    "  - \"Figure\"",
    "  - \"Figures\"",
    "eqnPrefix:",
    "  - \"Equation\"",
    "  - \"Equations\"",
    "tblPrefix:",
    "  - \"Table\"",
    "  - \"Tables\"",
    "lstPrefix:",
    "  - \"Listing\"",
    "  - \"Listings\"",
    "secPrefix:",
    "  - \"Section\"",
    "  - \"Sections\"",
    "linkReferences: true",
    "listings: false",
    "codeBlockCaptions: true",
    "...",
    "xvxvc",
    "",
    "sfsdf");
  
  
  yaml <- metadata.get(paste(data, sep="\n", collapse="\n"));
  
  expect_false(is.null(yaml));
  expect_identical(length(yaml), 31L);
  expect_identical(yaml$title, "An Introduction to Optimization Algorithms");
  expect_identical(yaml$codeBlockCaptions, TRUE);
  expect_identical(yaml$toccolor, "black");
  expect_identical(yaml$cref, TRUE);
  expect_identical(yaml$chapters, TRUE);
  expect_identical(yaml$keywords, c("Optimization", "Metaheuristics", "Local Search", "Global Search"));
  expect_identical(yaml$eqnPrefix, c("Equation", "Equations"));
})
