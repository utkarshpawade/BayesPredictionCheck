test_that("simulate_ppc returns matrix with correct dimensions (no design matrix)", {
  set.seed(1)
  S <- 200
  n <- 50
  draws <- matrix(rnorm(S * n, mean = 2), nrow = S, ncol = n)

  y_rep <- simulate_ppc(draws, family = "gaussian")

  expect_true(is.matrix(y_rep))
  expect_equal(nrow(y_rep), S)
  expect_equal(ncol(y_rep), n)
})

test_that("simulate_ppc returns matrix with correct dimensions (with design matrix)", {
  set.seed(2)
  S <- 100
  P <- 3     # intercept + 2 predictors
  n <- 40

  draws <- matrix(rnorm(S * P), nrow = S, ncol = P)
  X     <- matrix(c(rep(1, n), rnorm(n), rnorm(n)), nrow = n, ncol = P)

  y_rep <- simulate_ppc(draws, X = X, family = "gaussian")

  expect_true(is.matrix(y_rep))
  expect_equal(nrow(y_rep), S)
  expect_equal(ncol(y_rep), n)
})

test_that("simulate_ppc gaussian family returns numeric values", {
  set.seed(3)
  S <- 50
  n <- 30
  draws <- matrix(rnorm(S * n), nrow = S, ncol = n)

  y_rep <- simulate_ppc(draws, family = "gaussian")

  expect_true(is.numeric(y_rep))
  expect_true(all(is.finite(y_rep)))
})

test_that("simulate_ppc sigma_posterior of correct length works", {
  set.seed(4)
  S <- 80
  n <- 20
  draws       <- matrix(rnorm(S * n), nrow = S, ncol = n)
  sigma_draws <- abs(rnorm(S, mean = 1, sd = 0.1))

  y_rep <- simulate_ppc(draws, family = "gaussian", sigma_posterior = sigma_draws)

  expect_equal(dim(y_rep), c(S, n))
})

test_that("simulate_ppc binomial family returns integer-valued matrix in [0, n_trials]", {
  set.seed(5)
  S        <- 60
  n        <- 25
  n_trials <- 10L
  draws    <- matrix(rnorm(S * n), nrow = S, ncol = n)

  y_rep <- simulate_ppc(draws, family = "binomial", n_trials = n_trials)

  expect_true(is.matrix(y_rep))
  expect_equal(dim(y_rep), c(S, n))
  expect_true(all(y_rep >= 0))
  expect_true(all(y_rep <= n_trials))
})

test_that("simulate_ppc row and column names are set", {
  set.seed(6)
  S <- 10
  n <- 5
  draws <- matrix(rnorm(S * n), nrow = S, ncol = n)
  y_rep <- simulate_ppc(draws)

  expect_equal(rownames(y_rep), paste0("draw_", 1:S))
  expect_equal(colnames(y_rep), paste0("obs_",  1:n))
})

# ---- error conditions --------------------------------------------------------

test_that("simulate_ppc errors on non-matrix input", {
  expect_error(simulate_ppc(1:10), "`posterior_draws` must be a numeric matrix")
})

test_that("simulate_ppc errors on non-numeric matrix", {
  m <- matrix(letters[1:6], nrow = 2)
  expect_error(simulate_ppc(m), "`posterior_draws` must be numeric")
})

test_that("simulate_ppc errors on matrix with NA values", {
  m        <- matrix(rnorm(20), nrow = 4)
  m[1, 1]  <- NA
  expect_error(simulate_ppc(m), "non-finite values")
})

test_that("simulate_ppc errors when X column count mismatches draws", {
  S <- 30
  P <- 4
  n <- 20
  draws <- matrix(rnorm(S * P), nrow = S, ncol = P)
  X     <- matrix(rnorm(n * 2), nrow = n, ncol = 2)  # wrong P

  expect_error(simulate_ppc(draws, X = X), "columns")
})

test_that("simulate_ppc errors on non-positive sigma_posterior", {
  S <- 20
  n <- 10
  draws  <- matrix(rnorm(S * n), nrow = S, ncol = n)
  sigma  <- c(rep(1, S - 1), -0.5)

  expect_error(simulate_ppc(draws, sigma_posterior = sigma), "strictly positive")
})

test_that("simulate_ppc errors on wrong-length sigma_posterior", {
  S <- 20
  n <- 10
  draws <- matrix(rnorm(S * n), nrow = S, ncol = n)
  sigma <- rep(1, S + 5)

  expect_error(simulate_ppc(draws, sigma_posterior = sigma),
               "length equal to nrow")
})

test_that("simulate_ppc errors on unsupported family", {
  draws <- matrix(rnorm(20), nrow = 4)
  expect_error(simulate_ppc(draws, family = "poisson"))
})
