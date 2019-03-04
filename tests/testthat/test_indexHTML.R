library("bookbuildeR");
library("testthat");
context("index.html");

make.dummy.file <- function(tmpdir) {
  file <- tempfile(tmpdir=tmpdir);
  writeLines(text=strrep("blablabla", times=as.integer(ceiling(runif(n=1L, min=1L, max=1000000L)))), con=file);
  return(file);
}

test_that("test creating index.html", {
  tmpdir <- tempfile();
  dir.create(tmpdir, showWarnings = FALSE, recursive = TRUE);

  pdfFile <- make.dummy.file(tmpdir);
  epubFile <- make.dummy.file(tmpdir);
  azw3File <- make.dummy.file(tmpdir);
  htmlFile <- make.dummy.file(tmpdir);
  files <- list( list(path=pdfFile,
                      desc="in <a href=\"http://en.wikipedia.org/wiki/Pdf\">PDF</a>&nbsp;format for reading on the computer and/or printing (but please don't print this, save paper)"),
                 list(path=epubFile,
                      desc="in <a href=\"http://en.wikipedia.org/wiki/EPUB\">EPUB3</a>&nbsp;format for reading on most mobile phones or other hand-held devices"),
                 list(path=azw3File,
                      desc="for reading on <a href=\"http://en.wikipedia.org/wiki/Amazon_Kindle\">Kindle</a> and similar devices"),
                 list(path=htmlFile,
                      desc="in <a href=\"http://en.wikipedia.org/wiki/HTML5\">HTML5</a>&nbsp;format for reading in a  web browser or on other devices"));

  metadata <- list(title="title tile", author="the dude");

  indexHTML <- index.html(files, destDir=tmpdir, metadata=metadata);
  expect_true(file.exists(indexHTML));

  unlink(indexHTML);
  expect_false(file.exists(indexHTML));
  unlink(pdfFile);
  expect_false(file.exists(pdfFile));
  unlink(epubFile);
  expect_false(file.exists(epubFile));
  unlink(azw3File);
  expect_false(file.exists(azw3File));
  unlink(htmlFile);
  expect_false(file.exists(htmlFile));

  unlink(tmpdir, recursive=TRUE);
  expect_false(dir.exists(tmpdir));
})
