#' Posterior Predictive Diagnostic Statistics
#'
#' @description
#' Computes a suite of predictive discrepancy statistics that quantify how well
#' the posterior predictive distribution \eqn{p(y^{rep} \mid y)} matches the
#' observed data \eqn{y}.  All statistics are scalar summaries derived from
#' the \eqn{S \times n} replicated data matrix.
#'
#' @param y_obs Numeric vector of length \eqn{n} containing the observed
#'   outcomes.
#' @param y_rep Numeric matrix of dimension \eqn{S \times n} where each row is
#'   one posterior predictive replicate (e.g. the output of [simulate_ppc()]).
#' @param credible_mass Numeric scalar in \eqn{(0, 1)} specifying the
#'   credible interval mass used for the coverage calculation.
#'   Defaults to `0.95`.
#'
#' @return An object of class `"ppc_diagnostics"` (a named list) with the
#'   following elements:
#' \describe{
#'   \item{`mean_diff`}{Difference between the mean of the replicated means
#'     and the observed mean: \eqn{\bar{\mu}_{rep} - \bar{y}}.}
#'   \item{`var_diff`}{Difference between the mean of the replicated variances
#'     and the observed variance: \eqn{\bar{v}_{rep} - \mathrm{Var}(y)}.}
#'   \item{`bayesian_p_value`}{Proportion of draws for which the replicated
#'     mean exceeds the observed mean.  Values near 0.5 indicate good
#'     calibration.}
#'   \item{`rmse`}{Root mean squared error between the column-wise predictive
#'     means and the observed values:
#'     \eqn{\sqrt{n^{-1}\sum_i (\bar{y}^{rep}_i - y_i)^2}}.}
#'   \item{`coverage`}{Proportion of observations whose value falls inside the
#'     \code{credible_mass} posterior predictive interval.}
#'   \item{`n_draws`}{Number of posterior draws \eqn{S}.}
#'   \item{`n_obs`}{Number of observations \eqn{n}.}
#'   \item{`credible_mass`}{The credible mass used for the coverage
#'     calculation.}
#' }
#'
#' @seealso [simulate_ppc()], [print.ppc_diagnostics()]
#'
#' @importFrom stats var quantile
#'
#' @examples
#' set.seed(1)
#' y     <- rnorm(50, mean = 2, sd = 1)
#' draws <- matrix(rnorm(200 * 50, mean = 2), nrow = 200, ncol = 50)
#' y_rep <- simulate_ppc(draws)
#' diag  <- ppc_diagnostics(y, y_rep)
#' print(diag)
#'
#' @export
ppc_diagnostics <- function(y_obs, y_rep, credible_mass = 0.95) {

  # ---- input validation -------------------------------------------------------
  if (!is.numeric(y_obs) || !is.vector(y_obs)) {
    stop("`y_obs` must be a numeric vector.", call. = FALSE)
  }
  if (any(!is.finite(y_obs))) {
    stop("`y_obs` contains non-finite values.", call. = FALSE)
  }
  if (!is.matrix(y_rep) || !is.numeric(y_rep)) {
    stop("`y_rep` must be a numeric matrix (S x n).", call. = FALSE)
  }
  if (ncol(y_rep) != length(y_obs)) {
    stop(
      sprintf(
        "`y_rep` has %d columns but `y_obs` has length %d. ",
        ncol(y_rep), length(y_obs)
      ),
      "Columns of `y_rep` must correspond to observations.",
      call. = FALSE
    )
  }
  if (!is.numeric(credible_mass) ||
      length(credible_mass) != 1L ||
      credible_mass <= 0 || credible_mass >= 1) {
    stop("`credible_mass` must be a single numeric value in (0, 1).",
         call. = FALSE)
  }

  n <- length(y_obs)
  S <- nrow(y_rep)

  # ---- test statistic: mean --------------------------------------------------
  # Posterior predictive mean for each draw
  rep_means <- rowMeans(y_rep)
  obs_mean  <- mean(y_obs)

  mean_diff        <- mean(rep_means) - obs_mean
  bayesian_p_value <- mean(rep_means > obs_mean)

  # ---- test statistic: variance ----------------------------------------------
  # Variance of replicated data per draw
  rep_vars <- apply(y_rep, 1L, stats::var)
  obs_var  <- stats::var(y_obs)

  var_diff <- mean(rep_vars) - obs_var

  # ---- RMSE (predictive means vs. observed) ----------------------------------
  pred_means <- colMeans(y_rep)
  rmse <- sqrt(mean((pred_means - y_obs)^2))

  # ---- credible interval coverage --------------------------------------------
  alpha_lo <- (1 - credible_mass) / 2
  alpha_hi <- 1 - alpha_lo

  # Lower and upper credible bounds for each observation (column)
  lower_bounds <- apply(y_rep, 2L, stats::quantile, probs = alpha_lo)
  upper_bounds <- apply(y_rep, 2L, stats::quantile, probs = alpha_hi)

  coverage <- mean(y_obs >= lower_bounds & y_obs <= upper_bounds)

  # ---- assemble result -------------------------------------------------------
  result <- list(
    mean_diff        = mean_diff,
    var_diff         = var_diff,
    bayesian_p_value = bayesian_p_value,
    rmse             = rmse,
    coverage         = coverage,
    n_draws          = S,
    n_obs            = n,
    credible_mass    = credible_mass
  )

  class(result) <- "ppc_diagnostics"
  result
}


#' Print Method for ppc_diagnostics Objects
#'
#' @description
#' Displays a formatted summary of the predictive diagnostic statistics
#' returned by [ppc_diagnostics()].
#'
#' @param x An object of class `"ppc_diagnostics"`.
#' @param digits Integer. Number of significant digits to display.
#'   Defaults to `4`.
#' @param ... Currently unused; included for S3 method compatibility.
#'
#' @return Invisibly returns `x`.
#'
#' @seealso [ppc_diagnostics()]
#'
#' @examples
#' set.seed(1)
#' y     <- rnorm(50, mean = 2, sd = 1)
#' draws <- matrix(rnorm(200 * 50, mean = 2), nrow = 200, ncol = 50)
#' y_rep <- simulate_ppc(draws)
#' diag  <- ppc_diagnostics(y, y_rep)
#' print(diag)
#'
#' @export
print.ppc_diagnostics <- function(x, digits = 4, ...) {
  stopifnot(inherits(x, "ppc_diagnostics"))

  cat("\n-- Posterior Predictive Diagnostics (predictCheckR) --\n\n")
  cat(sprintf("  Draws  : %d\n", x$n_draws))
  cat(sprintf("  Obs    : %d\n\n", x$n_obs))

  cat("  Discrepancy Statistics:\n")
  cat(sprintf("    Mean difference        : %s\n",
              format(x$mean_diff, digits = digits)))
  cat(sprintf("    Variance difference    : %s\n",
              format(x$var_diff, digits = digits)))
  cat(sprintf("    Bayesian p-value       : %s\n",
              format(x$bayesian_p_value, digits = digits)))
  cat(sprintf("    RMSE (pred vs. obs)    : %s\n",
              format(x$rmse, digits = digits)))
  cat(sprintf("    Coverage (%d%% CI)      : %s\n",
              as.integer(x$credible_mass * 100),
              format(x$coverage, digits = digits)))
  cat("\n")

  invisible(x)
}
