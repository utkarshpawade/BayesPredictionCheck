#' Posterior Predictive Density Overlay Plot
#'
#' @description
#' Wraps [bayesplot::ppc_dens_overlay()] with consistent styling via
#' [theme_ppc()].  Subsamples `y_rep` rows for readability when \eqn{S} is
#' large.
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
#' @family ppc-workflow
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
#' \donttest{
#'   p <- plot_ppc_overlay(y, y_rep, n_samples = 40)
#' }
#'
#' @export
plot_ppc_overlay <- function(y_obs, y_rep, n_samples = 50, ...) {

  # ---- validation ------------------------------------------------------------
  validate_y_obs(y_obs)
  validate_y_rep(y_rep, y_obs)

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
#' Wraps [bayesplot::ppc_stat()] with consistent styling via [theme_ppc()].
#'
#' @param y_obs Numeric vector of length \eqn{n}.
#' @param y_rep Numeric matrix of dimension \eqn{S \times n}.
#' @param stat Character string naming the test statistic.  Currently
#'   supported values: `"mean"` and `"sd"`.  Defaults to `"mean"`.
#' @param ... Additional arguments passed to [bayesplot::ppc_stat()].
#'
#' @return A `ggplot2` object.
#'
#' @family ppc-workflow
#' @seealso [plot_ppc_overlay()], [bayesplot::ppc_stat()]
#'
#' @importFrom bayesplot ppc_stat
#'
#' @examples
#' set.seed(3)
#' y     <- rnorm(80, mean = 1, sd = 1)
#' draws <- matrix(rnorm(300 * 80, mean = 1), nrow = 300, ncol = 80)
#' y_rep <- simulate_ppc(draws)
#' \donttest{
#'   p <- plot_ppc_stat(y, y_rep, stat = "sd")
#' }
#'
#' @export
plot_ppc_stat <- function(y_obs, y_rep, stat = "mean", ...) {

  # ---- validation ------------------------------------------------------------
  validate_y_obs(y_obs)
  validate_y_rep(y_rep, y_obs)

  stat <- match.arg(stat, choices = c("mean", "sd"))

  p <- bayesplot::ppc_stat(y = y_obs, yrep = y_rep, stat = stat, ...) +
    theme_ppc() +
    ggplot2::theme(
      plot.title = ggplot2::element_text(face = "bold", size = 13)
    )

  p
}
