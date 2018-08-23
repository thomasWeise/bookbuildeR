library("bookbuildeR")
context("meta")

test_that("Test meta.time", {
  t <- meta.time();
  Sys.sleep(16L);
  expect_identical(t, meta.time());
})


test_that("Test meta.repo", {
  if(Sys.getenv("TRAVIS", unset=NUL) == "true") {
    c <- Sys.getenv("TRAVIS_REPO_SLUG", unset=NUL);
    if(!(is.null(c))) {
      cat("Found repository slug: '", c, "'.\n", sep="", collapse="");
      expect_identical(c, meta.repository());
    }
    cat("Found no repository slug?\n");
  }
  expect_true(TRUE);
})


test_that("Test meta.commit", {
  if(Sys.getenv("TRAVIS", unset=NULL) == "true") {
    c <- Sys.getenv("TRAVIS_COMMIT", unset=NULL);
    if(!(is.null(c))) {
      cat("Found commit: '", c, "'.\n", sep="", collapse="");
      expect_identical(c, meta.commit());
      return(NULL);
    }
    cat("Found no commit?\n");
  }
  expect_true(TRUE);
})
