library("bookbuildeR");
library("testthat");
library("utilizeR");
context("preprocess.command");


test_that("Test preprocess.command 1", {
  func <- function(x) x[1]
  command <- preprocess.command("hallo", 1L, func);

  expect_identical(command(
    "hallo\\hallo{a}{b}you"
  ), "halloa{b}you");
})

test_that("Test preprocess.command 2", {
  func <- function(x) paste(x[2], x[1], sep="", collapse="");
  command <- preprocess.command("hallo", 2L, func);

  expect_identical(command(
    "hallo\\hallo{a}{b}you"
  ), "hallobayou");
})

test_that("Test preprocess.command 3", {
  func <- function(x) paste(x[2], x[3], x[1], sep="", collapse="");

  command <- preprocess.command("hallo", 3L, func);
  expect_identical(command(
    "hallo \\hallo{a}{b}{z{u}v} you"
  ), "hallo bz{u}va you");

  command <- preprocess.command("hallo", 3L, func, stripWhiteSpace=TRUE);
  expect_identical(command(
    "hallo \\hallo{a}{b}{z{u}v} you"
  ), "hallobz{u}vayou");
})



test_that("Test preprocess.command 3", {
  func <- function(x, t) paste(x[2], x[3], x[1], t, sep="-", collapse="-");
  command <- preprocess.command("text.block", 3L, func);

  expect_identical(command(
    "hallo \\text.block{a}{b}{c} you",
    "d"
  ), "hallo b-c-a-d you");
})


test_that("Test preprocess.command again", {
  env <- new.env();
  assign("x", 0L, envir = env);

  func <- function(x, env) {
    y <- get("x", pos=env) + 1L;
    assign("x", y, envir=env);
    paste(x[2], x[3], x[1], y, sep="-", collapse="-");
  }
  command <- preprocess.command("text.block", 3L, func);

  expect_identical(command(
    "hallo \\text.block{a}{b}{c} you \\text.block{d}{e}{f} xyz \\text.block{u}{v}{w} hhh",
    env
  ), "hallo b-c-a-1 you e-f-d-2 xyz v-w-u-3 hhh");
})



.text.block.subst.inner <- function(found, env) {
  if(is.null(found) || (length(found) != 3L)) {
    exit("Error in \\text.block{", paste(found, sep=", ", collapse=", "), "}'.");
  }

  type <- found[[1L]];
  type <- force(type);
  if(!(is.non.empty.string(type))) {
    exit("Empty text block type: '", type, "'.");
  }
  type <- tolower(trimws(type));
  type <- force(type);
  if(nchar(type) <= 0L) {
    exit("Text block type only composed of white space.");
  }

  label <- found[[2L]];
  label <- force(label);
  if(is.non.empty.string(label)) {
    label <- trimws(label);
    label <- force(label);
  } else {
    label <- NA;
  }

  body <- found[[3L]];
  body <- force(body);
  if(!(is.non.empty.string(body))) {
    exit("Empty text block body: '", body, "'.");
  }
  body <- trimws(body);
  body <- force(body);
  if(nchar(body) <= 0L) {
    exit("Text block body only composed of white space.");
  }

  count <- (get0(x=type, envir=env, inherits=FALSE, ifnotfound=0L) + 1L);
  count <- force(count);
  assign(x=type, value=count, pos=env);
  title <- paste(toupper(substr(type, 1L, 1L)),
                 substr(type, 2L, nchar(type)),
                 "&nbsp;",
                 count,
                 sep="", collapse="");
  title <- force(title);

  if(is.non.empty.string(label)) {
    found <- get0(x=label, envir=env, inherits=FALSE, ifnotfound=NULL);
    if(is.null(found)) {
      assign(x=label, value=title, pos=env);
    } else {
      exit("Error: text block label '", label, "' already defined as '", found, "'.");
    }
  }

  result <- paste("\n\n\n**", title, ".**&nbsp;", body, "\n\n\n", sep="", collapse="");
  result <- force(result);
  return(result);
}

.cmd.text.block <- preprocess.command("text.block", 3L, .text.block.subst.inner, stripWhiteSpace=TRUE);

test_that("Test preprocess.command text.block", {
  env  <- new.env();

  text <- "aaa \\text.block{definition}{a}{b} yyy"

  res <- .cmd.text.block(text, env=env);
  expect_identical(res,
                   "aaa\n\n\n**Definition&nbsp;1.**&nbsp;b\n\n\nyyy");
})



# the inner text.ref substitution
.text.ref.subst.inner <- function(found, env) {
  if(is.null(found) || (length(found) != 1L)) {
    exit("Error in \\text.ref{", paste(found, sep=", ", collapse=", "), "}'.");
  }

  label <- found[[1L]];
  label <- force(label);
  if(is.non.empty.string(label)) {
    label <- trimws(label);
    label <- force(label);
    if(is.non.empty.string(label)) {
      found <- get0(x=label, envir=env, inherits=FALSE, ifnotfound=NULL);
      found <- force(found);
      if(is.non.empty.string(found)) {
        return(found);
      }
      exit("Error: \\text.ref label '", label, "' not found.");
    }
  }
  exit("Empty label in \\text.ref or label composed only of white space.")
}

.cmd.text.ref   <- preprocess.command("text.ref",   1L, .text.ref.subst.inner,   stripWhiteSpace=FALSE);



test_that("Test preprocess.command text.block and text.ref", {
  env  <- new.env();

  text <- "aaa \\text.block{definition}{a}{b} yyy \\text.ref{a} zzz"

  res <- .cmd.text.block(text, env=env);
  res <- .cmd.text.ref(res, env=env);
  expect_identical(res,
                   "aaa\n\n\n**Definition&nbsp;1.**&nbsp;b\n\n\nyyy Definition&nbsp;1 zzz");
})


test_that("Test preprocess.command text.block and text.ref", {
  env  <- new.env();

  text <- "aaa \\text.block{definition}{a}{b} yyy zzz"

  res <- .cmd.text.block(text, env=env);
  res <- .cmd.text.ref(res, env=env);
  expect_identical(res,
                   "aaa\n\n\n**Definition&nbsp;1.**&nbsp;b\n\n\nyyy zzz");
})
