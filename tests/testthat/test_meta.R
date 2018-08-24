library("bookbuildeR")
context("meta")

test_that("Test meta.time", {
  t <- meta.time();
  Sys.sleep(16L);
  expect_identical(t, meta.time());
})


test_that("Test meta.repo", {
  if(Sys.getenv("TRAVIS", unset=NA) == "true") {
    c <- Sys.getenv("TRAVIS_REPO_SLUG", unset=NA);
    if(!(is.null(c) || is.na(c))) {
      cat("Found repository slug: '", c, "'.\n", sep="", collapse="");
      expect_identical(c, meta.repository());
    }
    cat("Found no repository slug?\n");
  }
  expect_true(TRUE);
})


test_that("Test meta.commit", {
  if(Sys.getenv("TRAVIS", unset=NA) == "true") {
    c <- Sys.getenv("TRAVIS_COMMIT", unset=NA);
    if(!(is.null(c) || is.na(c))) {
      cat("Found commit: '", c, "'.\n", sep="", collapse="");
      expect_identical(c, meta.commit());
      return(NULL);
    }
    cat("Found no commit?\n");
  }
  expect_true(TRUE);
})
