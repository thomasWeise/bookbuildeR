library("bookbuildeR")
context("meta")

test_that("Test meta.time", {
  t <- meta.time();
  Sys.sleep(16L);
  expect_identical(t, meta.time());
})


test_that("Test meta.repo", {
  if(Sys.getenv("TRAVIS") == "true") {
    c <- Sys.getenv("TRAVIS_REPO_SLUG");
    cat("Found repository slug: '", c, "'.\n", sep="", collapse="");
    expect_identical(c, meta.repository());
  } else {
    expect_true(TRUE);
  }
})


test_that("Test meta.commit", {
  if(Sys.getenv("TRAVIS") == "true") {
    c <- Sys.getenv("TRAVIS_COMMIT");
    cat("Found commit: '", c, "'.\n", sep="", collapse="");
    expect_identical(c, meta.commit());
  } else {
    expect_true(TRUE);
  }
})
