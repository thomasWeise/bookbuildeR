library("bookbuildeR");
library("testthat");
library("utilizeR");
library("ore");
context("preprocess.command");

test_that("Test preprocess.command.regexp 1", {
  func <- function(x) substr(groups(x)[1], 2, 2)

  command <- preprocess.command.regexp("hallo", 1L);
  expect_identical(ore.subst(command, func,
    "hallo\\hallo{a}{b}you"),
  "halloa{b}you");
  
  command <- preprocess.command.regexp("hallo", 1L, stripWhiteSpace = TRUE);
  expect_identical(ore.subst(command, func,
                             "hallo\\hallo{a}{b}you"),
                   "halloa{b}you");
  expect_identical(ore.subst(command, func,
                             "hallo  \\hallo{a}you"),
                   "halloayou");
  expect_identical(ore.subst(command, func,
                             "hallo\\hallo{a}  you"),
                   "halloayou");
  expect_identical(ore.subst(command, func,
                             "hallo\n\\hallo{a}you"),
                   "halloayou");
})

test_that("Test preprocess.command.regexp 2", {
  func <- function(x) paste(rev(groups(x)), sep="", collapse="")
  command <- preprocess.command.regexp("hallo", 2L);
  
  expect_identical(ore.subst(command, func,
                             "hallo\\hallo{a}{b}you"),
                   "hallo{b}{a}you");
  expect_identical(ore.subst(command, func,
                             "hallo\\hallo{a}byou"),
                   "hallo\\hallo{a}byou");
  expect_identical(ore.subst(command, func,
                             "hallo\\hallo{a}{b}{v}you"),
                   "hallo{b}{a}{v}you");
})



test_that("Test preprocess.command.regexp 3", {
  func <- function(x) paste(rev(groups(x)), sep="", collapse="")
  command <- preprocess.command.regexp("hallo", 3L);
  
  expect_identical(ore.subst(command, func,
                             "hallo\\hallo{a}{b}{v}you"),
                   "hallo{v}{b}{a}you");
})


test_that("Test preprocess.command", {
  func <- function(x, t) paste(x[2], x[3], x[1], t, sep="-", collapse="-");
  command <- preprocess.command.regexp("text.block", 3L);
  
  expect_identical(preprocess.command(command,
    "hallo \\text.block{a}{b}{c} you",
    func,"d"
  ), "hallo b-c-a-d you");
  
  expect_identical(preprocess.command(command,
        "hallo \\text.block{a}{c} you",
        func,"d"
  ), "hallo \\text.block{a}{c} you");
  
  
  expect_identical(preprocess.command(command,
          "hallo \\text.block{a}{b{d}}{c} you",
          func,"d"
  ), "hallo b{d}-c-a-d you");
})