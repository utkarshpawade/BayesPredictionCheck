#' Compare Two Models via Posterior Predictive Performance Metrics
#'
#' @description
#' Computes a side-by-side comparison of two competing posterior predictive
#' distributions with respect to three scalar metrics:
#'
#' \describe{
#'   \item{RMSE}{Root mean squared error of the column-wise predictive means
#'     against the observed data.}
#'   \item{MAE}{Mean absolute error of the column-wise predictive means against
#'     the observed data.}
#'   \item{Pred. Variance Gap}{Absolute difference between the average
#'     predictive variance across observations and the empirical variance of
#'     the observed data.  Smaller values indicate that the model captures the
#'     spread of the data more faithfully.}
#' }
#'
#' Lower values are better for all three metrics.  The function also
#' computes the difference (Model 1 − Model 2) for each metric so the
#' direction and magnitude of improvement are immediately visible.
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
  if (!is.numeric(y_obs) || !is.vector(y_obs)) {
    stop("`y_obs` must be a numeric vector.", call. = FALSE)
  }
  if (any(!is.finite(y_obs))) {
    stop("`y_obs` contains non-finite values.", call. = FALSE)
  }
  for (tag in c("y_rep1", "y_rep2")) {
    obj <- get(tag)
    if (!is.matrix(obj) || !is.numeric(obj)) {
      stop(sprintf("`%s` must be a numeric matrix (S x n).", tag), call. = FALSE)
    }
    if (ncol(obj) != length(y_obs)) {
      stop(
        sprintf(
          "`%s` has %d columns but `y_obs` has length %d.",
          tag, ncol(obj), length(y_obs)
        ),
        call. = FALSE
      )
    }
  }
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

  # Average predictive variance per observation (mean of column variances)
  .pred_var_gap <- function(y_rep, y_obs) {
    col_vars    <- apply(y_rep, 2L, stats::var)
    obs_var     <- stats::var(y_obs)
    abs(mean(col_vars) - obs_var)
  }

  # ---- compute metrics -------------------------------------------------------
  metrics <- c("RMSE", "MAE", "Pred. Variance Gap")

  m1 <- c(
    .rmse(.validate_rep(y_rep1, y_obs), y_obs),
    .mae(y_rep1, y_obs),
    .pred_var_gap(y_rep1, y_obs)
  )

  m2 <- c(
    .rmse(.validate_rep(y_rep2, y_obs), y_obs),
    .mae(y_rep2, y_obs),
    .pred_var_gap(y_rep2, y_obs)
  )

  # ---- assemble output -------------------------------------------------------
  result <- data.frame(
    metric           = metrics,
    model1           = round(m1, 6),
    model2           = round(m2, 6),
    diff_m1_minus_m2 = round(m1 - m2, 6),
    stringsAsFactors = FALSE,
    check.names      = FALSE
  )

  colnames(result)[2L] <- model_names[1L]
  colnames(result)[3L] <- model_names[2L]

  result
}


# ---- internal ---------------------------------------------------------------

#' @keywords internal
.validate_rep <- function(y_rep, y_obs) {
  if (!is.matrix(y_rep) || !is.numeric(y_rep)) {
    stop("`y_rep` must be a numeric matrix.", call. = FALSE)
  }
  if (ncol(y_rep) != length(y_obs)) {
    stop("`y_rep` column count must equal length of `y_obs`.", call. = FALSE)
  }
  y_rep
}
