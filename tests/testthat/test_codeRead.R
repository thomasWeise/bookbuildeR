library("bookbuildeR");
library("testthat");
context("code.read");

make.file <- function() {
  file <- tempfile();
  handle <- file(file, "wt");
  writeLines(text=c(
    "  x <- function(y) {",
    "  # start inner",
    "  print(y);",
    "  # start outer",
    "  print(y + 6);",
    "", "",
    "  # end inner",
    "  for(i in 1:10) {",
    "    print(i);",
    "    }",
    "  # end outer",
    "  }"
  ), con=handle);
  close(handle);
  return(file);
}

test_that("Test code.read plain", {
  file <- make.file();
  text <- code.read(file);
  expect_equal(text,
               "x <- function(y) {\n# start inner\nprint(y);\n# start outer\nprint(y + 6);\n\n# end inner\nfor(i in 1:10) {\n  print(i);\n  }\n# end outer\n}");
  unlink(file);
  expect_false(file.exists(file));
})


test_that("Test code.read tags 1", {
  file <- make.file();
  text <- code.read(file, tags=c("inner"));
  expect_equal(text,
               "print(y);\n# start outer\nprint(y + 6);");
  unlink(file);
  expect_false(file.exists(file));
})


test_that("Test code.read tags 2", {
  file <- make.file();
  text <- code.read(file, tags=c("outer"));
  expect_equal(text,
               "print(y + 6);\n\n# end inner\nfor(i in 1:10) {\n  print(i);\n  }");
  unlink(file);
  expect_false(file.exists(file));
})

test_that("Test code.read tags 3", {
  file <- make.file();
  text <- code.read(file, tags=c("inner", "outer"));
  expect_equal(text,
               "print(y);\nprint(y + 6);\n\nfor(i in 1:10) {\n  print(i);\n  }");
  unlink(file);
  expect_false(file.exists(file));
})


test_that("Test code.read tags 4", {
  file <- make.file();
  text <- code.read(file, tags=c("outer", "inner"));
  expect_equal(text,
               "print(y);\nprint(y + 6);\n\nfor(i in 1:10) {\n  print(i);\n  }");
  unlink(file);
  expect_false(file.exists(file));
})

test_that("Test code.read lines", {
  file <- make.file();
  text <- code.read(file, lines=c(5,4,3,6));
  expect_equal(text,
                "print(y);\n# start outer\nprint(y + 6);");
  unlink(file);
  expect_false(file.exists(file));
})
