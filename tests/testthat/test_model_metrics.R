make_comparison_data <- function(n = 40, S = 100, seed = 7) {
  set.seed(seed)
  y <- rnorm(n)
  r1 <- simulate_ppc(matrix(rnorm(S * n), S, n))
  r2 <- simulate_ppc(matrix(rnorm(S * n, mean = 1), S, n))
  list(y = y, r1 = r1, r2 = r2)
}

# ---- structure --------------------------------------------------------------

test_that("compare_models_ppc returns a data.frame with 3 rows", {
  d <- make_comparison_data()
  tab <- compare_models_ppc(d$y, d$r1, d$r2)

  expect_s3_class(tab, "data.frame")
  expect_equal(nrow(tab), 3L)
  expect_true("metric" %in% names(tab))
  expect_true("diff_m1_minus_m2" %in% names(tab))
})

test_that("compare_models_ppc respects model_names argument", {
  d <- make_comparison_data()
  tab <- compare_models_ppc(d$y, d$r1, d$r2,
                            model_names = c("Alpha", "Beta"))

  expect_true("Alpha" %in% names(tab))
  expect_true("Beta"  %in% names(tab))
})

test_that("compare_models_ppc diff column equals model1 - model2", {
  d <- make_comparison_data()
  tab <- compare_models_ppc(d$y, d$r1, d$r2,
                            model_names = c("M1", "M2"))

  expect_equal(tab$diff_m1_minus_m2, tab$M1 - tab$M2)
})

# ---- error conditions -------------------------------------------------------

test_that("compare_models_ppc errors on non-numeric y_obs", {
  d <- make_comparison_data()
  expect_error(
    compare_models_ppc(as.character(d$y), d$r1, d$r2),
    "`y_obs` must be a numeric vector"
  )
})

test_that("compare_models_ppc errors on y_rep column mismatch", {
  d <- make_comparison_data()
  expect_error(
    compare_models_ppc(d$y, d$r1[, 1:10], d$r2),
    "columns"
  )
})

test_that("compare_models_ppc errors on invalid model_names", {
  d <- make_comparison_data()
  expect_error(
    compare_models_ppc(d$y, d$r1, d$r2, model_names = "only_one"),
    "length 2"
  )
})

test_that("compare_models_ppc errors on non-matrix y_rep", {
  d <- make_comparison_data()
  expect_error(
    compare_models_ppc(d$y, as.vector(d$r1), d$r2),
    "must be a numeric matrix"
  )
})
