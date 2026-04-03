make_y_and_yrep <- function(S = 200, n = 50, seed = 99) {
  set.seed(seed)
  y_obs <- rnorm(n, mean = 2, sd = 1)
  draws <- matrix(rnorm(S * n, mean = 2), nrow = S, ncol = n)
  y_rep <- simulate_ppc(draws)
  list(y_obs = y_obs, y_rep = y_rep)
}

# ---- plot_ppc_overlay -------------------------------------------------------

test_that("plot_ppc_overlay returns a ggplot object", {
  d <- make_y_and_yrep()
  p <- plot_ppc_overlay(d$y_obs, d$y_rep, n_samples = 10)
  expect_s3_class(p, "ggplot")
})

test_that("plot_ppc_overlay uses all rows when n_samples >= S", {
  d <- make_y_and_yrep(S = 20, n = 10)
  p <- plot_ppc_overlay(d$y_obs, d$y_rep, n_samples = 100)
  expect_s3_class(p, "ggplot")
})

test_that("plot_ppc_overlay errors on non-numeric y_obs", {
  d <- make_y_and_yrep()
  expect_error(
    plot_ppc_overlay(as.character(d$y_obs), d$y_rep),
    "`y_obs` must be a numeric vector"
  )
})

test_that("plot_ppc_overlay errors on y_rep not a matrix", {
  d <- make_y_and_yrep()
  expect_error(
    plot_ppc_overlay(d$y_obs, as.vector(d$y_rep)),
    "must be a numeric matrix"
  )
})

test_that("plot_ppc_overlay errors on dimension mismatch", {
  d <- make_y_and_yrep(n = 50)
  expect_error(
    plot_ppc_overlay(d$y_obs, d$y_rep[, 1:30]),
    "columns"
  )
})

test_that("plot_ppc_overlay errors on invalid n_samples", {
  d <- make_y_and_yrep()
  expect_error(plot_ppc_overlay(d$y_obs, d$y_rep, n_samples = 0),
               "`n_samples` must be a single positive integer")
  expect_error(plot_ppc_overlay(d$y_obs, d$y_rep, n_samples = -5),
               "`n_samples` must be a single positive integer")
  expect_error(plot_ppc_overlay(d$y_obs, d$y_rep, n_samples = c(10, 20)),
               "`n_samples` must be a single positive integer")
})

# ---- plot_ppc_stat ----------------------------------------------------------

test_that("plot_ppc_stat returns a ggplot object for stat = 'mean'", {
  d <- make_y_and_yrep()
  p <- plot_ppc_stat(d$y_obs, d$y_rep, stat = "mean")
  expect_s3_class(p, "ggplot")
})

test_that("plot_ppc_stat returns a ggplot object for stat = 'sd'", {
  d <- make_y_and_yrep()
  p <- plot_ppc_stat(d$y_obs, d$y_rep, stat = "sd")
  expect_s3_class(p, "ggplot")
})

test_that("plot_ppc_stat errors on unsupported stat", {
  d <- make_y_and_yrep()
  expect_error(plot_ppc_stat(d$y_obs, d$y_rep, stat = "median"))
})

test_that("plot_ppc_stat errors on non-numeric y_obs", {
  d <- make_y_and_yrep()
  expect_error(
    plot_ppc_stat(as.character(d$y_obs), d$y_rep),
    "`y_obs` must be a numeric vector"
  )
})

# ---- theme_ppc --------------------------------------------------------------

test_that("theme_ppc returns a ggplot2 theme object", {
  th <- theme_ppc()
  expect_s3_class(th, "theme")
})

test_that("theme_ppc respects base_size argument", {
  th12 <- theme_ppc(base_size = 12)
  th16 <- theme_ppc(base_size = 16)
  expect_s3_class(th12, "theme")
  expect_s3_class(th16, "theme")
})
