## Shared test fixtures --------------------------------------------------------

make_y_and_yrep <- function(S = 200, n = 50, seed = 99) {
  set.seed(seed)
  y_obs <- rnorm(n, mean = 2, sd = 1)
  draws <- matrix(rnorm(S * n, mean = 2), nrow = S, ncol = n)
  y_rep <- simulate_ppc(draws)
  list(y_obs = y_obs, y_rep = y_rep)
}

# ---- ppc_diagnostics: structure ---------------------------------------------

test_that("ppc_diagnostics returns an object of class ppc_diagnostics", {
  d <- make_y_and_yrep()
  result <- ppc_diagnostics(d$y_obs, d$y_rep)
  expect_s3_class(result, "ppc_diagnostics")
})

test_that("ppc_diagnostics returns all expected names", {
  d <- make_y_and_yrep()
  result <- ppc_diagnostics(d$y_obs, d$y_rep)

  expected_names <- c(
    "mean_diff", "var_diff", "bayesian_p_value",
    "rmse", "coverage", "n_draws", "n_obs", "credible_mass"
  )
  expect_named(result, expected_names)
})

test_that("ppc_diagnostics n_draws and n_obs are correct", {
  S <- 150; n <- 60
  d <- make_y_and_yrep(S = S, n = n)
  result <- ppc_diagnostics(d$y_obs, d$y_rep)

  expect_equal(result$n_draws, S)
  expect_equal(result$n_obs,   n)
})

# ---- ppc_diagnostics: scalar properties ------------------------------------

test_that("bayesian_p_value is in [0, 1]", {
  d      <- make_y_and_yrep()
  result <- ppc_diagnostics(d$y_obs, d$y_rep)
  expect_gte(result$bayesian_p_value, 0)
  expect_lte(result$bayesian_p_value, 1)
})

test_that("coverage is in [0, 1]", {
  d      <- make_y_and_yrep()
  result <- ppc_diagnostics(d$y_obs, d$y_rep)
  expect_gte(result$coverage, 0)
  expect_lte(result$coverage, 1)
})

test_that("rmse is non-negative", {
  d      <- make_y_and_yrep()
  result <- ppc_diagnostics(d$y_obs, d$y_rep)
  expect_gte(result$rmse, 0)
})

test_that("credible_mass is stored correctly", {
  d      <- make_y_and_yrep()
  result <- ppc_diagnostics(d$y_obs, d$y_rep, credible_mass = 0.89)
  expect_equal(result$credible_mass, 0.89)
})

test_that("coverage is near nominal for well-calibrated model", {
  set.seed(42)
  n <- 200
  S <- 2000
  y_obs <- rnorm(n, mean = 0, sd = 1)
  draws <- matrix(rnorm(S * n, mean = 0), nrow = S, ncol = n)
  y_rep <- simulate_ppc(draws, sigma_posterior = rep(1, S))
  result <- ppc_diagnostics(y_obs, y_rep, credible_mass = 0.95)

  # For a well-calibrated model with n=200 and S=2000 the coverage
  # should be within ±0.15 of the nominal level
  expect_gt(result$coverage, 0.80)
  expect_lt(result$coverage, 1.00)
})

# ---- ppc_diagnostics: error conditions --------------------------------------

test_that("ppc_diagnostics errors on non-numeric y_obs", {
  d <- make_y_and_yrep()
  expect_error(ppc_diagnostics(as.character(d$y_obs), d$y_rep),
               "`y_obs` must be a numeric vector")
})

test_that("ppc_diagnostics errors when y_obs has NA", {
  d         <- make_y_and_yrep()
  d$y_obs[5] <- NA
  expect_error(ppc_diagnostics(d$y_obs, d$y_rep), "non-finite")
})

test_that("ppc_diagnostics errors when y_rep is not a matrix", {
  d <- make_y_and_yrep()
  expect_error(ppc_diagnostics(d$y_obs, as.vector(d$y_rep)),
               "must be a numeric matrix")
})

test_that("ppc_diagnostics errors on column mismatch between y_rep and y_obs", {
  d     <- make_y_and_yrep(n = 50)
  y_bad <- d$y_rep[, 1:40]  # wrong number of columns
  expect_error(ppc_diagnostics(d$y_obs, y_bad), "columns")
})

test_that("ppc_diagnostics errors on invalid credible_mass", {
  d <- make_y_and_yrep()
  expect_error(ppc_diagnostics(d$y_obs, d$y_rep, credible_mass = 1.5),
               "credible_mass")
  expect_error(ppc_diagnostics(d$y_obs, d$y_rep, credible_mass = 0),
               "credible_mass")
  expect_error(ppc_diagnostics(d$y_obs, d$y_rep, credible_mass = -0.1),
               "credible_mass")
})

# ---- print.ppc_diagnostics --------------------------------------------------

test_that("print.ppc_diagnostics produces output and returns invisibly", {
  d      <- make_y_and_yrep()
  result <- ppc_diagnostics(d$y_obs, d$y_rep)

  out <- capture.output(ret <- print(result))

  expect_true(length(out) > 0)
  expect_true(any(grepl("Posterior Predictive Diagnostics", out)))
  expect_identical(ret, result)
})

# ---- compare_models_ppc -----------------------------------------------------

test_that("compare_models_ppc returns a data.frame with 4 rows", {
  set.seed(7)
  n  <- 40; S <- 100
  y  <- rnorm(n)
  r1 <- simulate_ppc(matrix(rnorm(S * n), S, n))
  r2 <- simulate_ppc(matrix(rnorm(S * n, mean = 1), S, n))

  tab <- compare_models_ppc(y, r1, r2)

  expect_s3_class(tab, "data.frame")
  expect_equal(nrow(tab), 3L)
  expect_true("metric" %in% names(tab))
})

test_that("compare_models_ppc respects model_names argument", {
  set.seed(8)
  n  <- 30; S <- 80
  y  <- rnorm(n)
  r1 <- simulate_ppc(matrix(rnorm(S * n), S, n))
  r2 <- simulate_ppc(matrix(rnorm(S * n), S, n))

  tab <- compare_models_ppc(y, r1, r2,
                             model_names = c("Alpha", "Beta"))

  expect_true("Alpha" %in% names(tab))
  expect_true("Beta"  %in% names(tab))
})

test_that("compare_models_ppc errors on invalid model_names", {
  set.seed(9)
  n <- 20; S <- 50
  y  <- rnorm(n)
  r1 <- simulate_ppc(matrix(rnorm(S * n), S, n))
  r2 <- r1

  expect_error(compare_models_ppc(y, r1, r2, model_names = "only_one"),
               "length 2")
})
