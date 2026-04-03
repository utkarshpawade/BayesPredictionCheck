#' Compare Two Models via Posterior Predictive Performance Metrics
#'
#' @description
#' Side-by-side comparison of two posterior predictive distributions on RMSE,
#' MAE, and predictive variance gap.  Lower is better for all three; the signed
#' difference (Model 1 − Model 2) is also returned.
#'
#' @param y_obs Numeric vector of length \eqn{n}.
#' @param y_rep1 Numeric matrix \eqn{S_1 \times n}.  Posterior predictive
#'   draws for Model 1 (e.g. from [simulate_ppc()]).
#' @param y_rep2 Numeric matrix \eqn{S_2 \times n}.  Posterior predictive
#'   draws for Model 2.  \eqn{S_1} and \eqn{S_2} need not be equal.
#' @param model_names Character vector of length 2 giving display names for
#'   the two models.  Defaults to `c("Model 1", "Model 2")`.
#'
#' @return A `data.frame` with four columns:
#' \describe{
#'   \item{`metric`}{Name of the performance metric.}
#'   \item{`model1`}{Value for Model 1.}
#'   \item{`model2`}{Value for Model 2.}
#'   \item{`diff_m1_minus_m2`}{Signed difference (Model 1 − Model 2).
#'     Negative values indicate Model 1 is better for that metric.}
#' }
#'
#' @family ppc-workflow
#' @seealso [ppc_diagnostics()], [simulate_ppc()]
#'
#' @importFrom stats var
#'
#' @examples
#' set.seed(42)
#' n  <- 60
#' S  <- 150
#' y  <- rnorm(n, mean = 3)
#'
#' # Model 1: well-specified
#' draws1 <- matrix(rnorm(S * n, mean = 3), nrow = S, ncol = n)
#' y_rep1 <- simulate_ppc(draws1)
#'
#' # Model 2: slightly mis-specified mean
#' draws2 <- matrix(rnorm(S * n, mean = 5), nrow = S, ncol = n)
#' y_rep2 <- simulate_ppc(draws2)
#'
#' compare_models_ppc(y, y_rep1, y_rep2, model_names = c("Correct", "Shifted"))
#'
#' @export
compare_models_ppc <- function(y_obs,
                               y_rep1,
                               y_rep2,
                               model_names = c("Model 1", "Model 2")) {

  # ---- input validation -------------------------------------------------------
  validate_y_obs(y_obs)
  validate_y_rep(y_rep1, y_obs)
  validate_y_rep(y_rep2, y_obs)

  if (!is.character(model_names) || length(model_names) != 2L) {
    stop("`model_names` must be a character vector of length 2.", call. = FALSE)
  }

  # ---- metric helpers --------------------------------------------------------

  .rmse <- function(y_rep, y_obs) {
    pred <- colMeans(y_rep)
    sqrt(mean((pred - y_obs)^2))
  }

  .mae <- function(y_rep, y_obs) {
    pred <- colMeans(y_rep)
    mean(abs(pred - y_obs))
  }

  .pred_var_gap <- function(y_rep, y_obs) {
    col_vars    <- apply(y_rep, 2L, stats::var)
    obs_var     <- stats::var(y_obs)
    abs(mean(col_vars) - obs_var)
  }

  # ---- compute metrics -------------------------------------------------------
  metrics <- c("RMSE", "MAE", "Pred. Variance Gap")

  m1 <- c(
    .rmse(y_rep1, y_obs),
    .mae(y_rep1, y_obs),
    .pred_var_gap(y_rep1, y_obs)
  )

  m2 <- c(
    .rmse(y_rep2, y_obs),
    .mae(y_rep2, y_obs),
    .pred_var_gap(y_rep2, y_obs)
  )

  # ---- assemble output -------------------------------------------------------
  result <- stats::setNames(
    data.frame(
      metrics,
      round(m1, 6),
      round(m2, 6),
      round(m1 - m2, 6),
      stringsAsFactors = FALSE
    ),
    c("metric", model_names[1L], model_names[2L], "diff_m1_minus_m2")
  )

  result
}
