#' Posterior Predictive Density Overlay Plot
#'
#' @description
#' Wraps [bayesplot::ppc_dens_overlay()] to produce a density overlay plot
#' comparing the observed data distribution against a random subsample of
#' posterior predictive replicates.  The plot is returned as a `ggplot2`
#' object and styled with [theme_ppc()].
#'
#' A density overlay is one of the most diagnostic plots in the posterior
#' predictive checking toolkit: if the observed density (dark line) falls
#' within the envelope formed by the replicated draws (light lines), the model
#' provides an adequate description of the marginal distribution of \eqn{y}.
#'
#' @param y_obs Numeric vector of length \eqn{n} containing the observed
#'   outcomes.
#' @param y_rep Numeric matrix of dimension \eqn{S \times n} where each row is
#'   one posterior predictive replicate (e.g. the output of [simulate_ppc()]).
#' @param n_samples Positive integer.  Number of rows to subsample from
#'   `y_rep` for the overlay.  Subsampling improves readability when \eqn{S}
#'   is large.  Defaults to `50`.  The subsample is drawn without replacement
#'   when `n_samples < S`, otherwise all rows are used.
#' @param ... Additional arguments passed to [bayesplot::ppc_dens_overlay()].
#'
#' @return A `ggplot2` object.
#'
#' @seealso [plot_ppc_stat()], [bayesplot::ppc_dens_overlay()]
#'
#' @importFrom bayesplot ppc_dens_overlay
#' @importFrom ggplot2 theme_bw theme element_text element_line element_rect
#'   element_blank
#'
#' @examples
#' set.seed(7)
#' y     <- rnorm(80, mean = 0, sd = 1)
#' draws <- matrix(rnorm(300 * 80, mean = 0), nrow = 300, ncol = 80)
#' y_rep <- simulate_ppc(draws)
#' p     <- plot_ppc_overlay(y, y_rep, n_samples = 40)
#' \dontrun{
#'   print(p)
#' }
#'
#' @export
plot_ppc_overlay <- function(y_obs, y_rep, n_samples = 50, ...) {

  # ---- validation ------------------------------------------------------------
  .validate_y_obs(y_obs)
  .validate_y_rep(y_rep, y_obs)

  if (!is.numeric(n_samples) || length(n_samples) != 1L || n_samples < 1L) {
    stop("`n_samples` must be a single positive integer.", call. = FALSE)
  }
  n_samples <- as.integer(n_samples)

  S <- nrow(y_rep)

  # ---- subsample draws -------------------------------------------------------
  if (n_samples < S) {
    idx   <- sample.int(S, size = n_samples, replace = FALSE)
    y_sub <- y_rep[idx, , drop = FALSE]
  } else {
    y_sub <- y_rep
  }

  # ---- build plot ------------------------------------------------------------
  p <- bayesplot::ppc_dens_overlay(y = y_obs, yrep = y_sub, ...) +
    theme_ppc() +
    ggplot2::theme(
      plot.title = ggplot2::element_text(face = "bold", size = 13)
    )

  p
}


#' Posterior Predictive Test-Statistic Distribution Plot
#'
#' @description
#' Wraps [bayesplot::ppc_stat()] to plot the distribution of a scalar
#' test statistic \eqn{T(y^{rep})} across posterior predictive replicates,
#' overlaid with the observed value \eqn{T(y)}.  The plot is styled with
#' [theme_ppc()].
#'
#' Large discrepancies between \eqn{T(y)} and the bulk of the \eqn{T(y^{rep})}
#' distribution are evidence of model misfit with respect to the chosen
#' statistic.
#'
#' @param y_obs Numeric vector of length \eqn{n}.
#' @param y_rep Numeric matrix of dimension \eqn{S \times n}.
#' @param stat Character string naming the test statistic.  Currently
#'   supported values: `"mean"` and `"sd"`.  Defaults to `"mean"`.
#' @param ... Additional arguments passed to [bayesplot::ppc_stat()].
#'
#' @return A `ggplot2` object.
#'
#' @seealso [plot_ppc_overlay()], [bayesplot::ppc_stat()]
#'
#' @importFrom bayesplot ppc_stat
#'
#' @examples
#' set.seed(3)
#' y     <- rnorm(80, mean = 1, sd = 1)
#' draws <- matrix(rnorm(300 * 80, mean = 1), nrow = 300, ncol = 80)
#' y_rep <- simulate_ppc(draws)
#' p     <- plot_ppc_stat(y, y_rep, stat = "sd")
#' \dontrun{
#'   print(p)
#' }
#'
#' @export
plot_ppc_stat <- function(y_obs, y_rep, stat = "mean", ...) {

  # ---- validation ------------------------------------------------------------
  .validate_y_obs(y_obs)
  .validate_y_rep(y_rep, y_obs)

  stat <- match.arg(stat, choices = c("mean", "sd"))

  # bayesplot::ppc_stat accepts a function or a character string that it
  # resolves internally ("mean" and "sd" are natively recognised).
  p <- bayesplot::ppc_stat(y = y_obs, yrep = y_rep, stat = stat, ...) +
    theme_ppc() +
    ggplot2::theme(
      plot.title = ggplot2::element_text(face = "bold", size = 13)
    )

  p
}


# ---- internal validation helpers -------------------------------------------

#' @keywords internal
.validate_y_obs <- function(y_obs) {
  if (!is.numeric(y_obs) || !is.vector(y_obs)) {
    stop("`y_obs` must be a numeric vector.", call. = FALSE)
  }
  if (any(!is.finite(y_obs))) {
    stop("`y_obs` contains non-finite values.", call. = FALSE)
  }
  invisible(NULL)
}

#' @keywords internal
.validate_y_rep <- function(y_rep, y_obs) {
  if (!is.matrix(y_rep) || !is.numeric(y_rep)) {
    stop("`y_rep` must be a numeric matrix (S x n).", call. = FALSE)
  }
  if (ncol(y_rep) != length(y_obs)) {
    stop(
      sprintf(
        "`y_rep` has %d columns but `y_obs` has length %d.",
        ncol(y_rep), length(y_obs)
      ),
      call. = FALSE
    )
  }
  invisible(NULL)
}
