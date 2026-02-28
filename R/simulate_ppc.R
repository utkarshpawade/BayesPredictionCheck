#' Generate Posterior Predictive Samples
#'
#' @description
#' Generates replicated outcome samples \eqn{y^{rep}} from a matrix of
#' posterior draws under a specified likelihood family.  Each row of
#' `posterior_draws` is treated as one posterior sample of the parameter
#' vector \eqn{(\mu_1, \ldots, \mu_n)} (Gaussian) or \eqn{(p_1, \ldots, p_n)}
#' (Binomial), where \eqn{n} is the number of observations.  When a design
#' matrix `X` is supplied the linear predictor
#' \eqn{\eta = X \beta} is computed first and the appropriate inverse-link is
#' applied.
#'
#' The posterior predictive distribution is
#' \deqn{p(y^{rep} \mid y) = \int p(y^{rep} \mid \theta)\, p(\theta \mid y)\, d\theta.}
#' This function approximates the integral by averaging over the discrete
#' posterior samples.
#'
#' @param posterior_draws A numeric matrix of dimension
#'   \eqn{S \times P}, where \eqn{S} is the number of posterior iterations and
#'   \eqn{P} the number of parameters.  When `X` is `NULL`, \eqn{P} is
#'   interpreted as the number of observations \eqn{n} and each column is the
#'   marginal posterior mean for one observation.  When `X` is supplied,
#'   \eqn{P} must equal \code{ncol(X)}.
#' @param X Optional numeric design matrix of dimension \eqn{n \times P}.
#'   If provided, the linear predictor \eqn{X \beta} is computed for each
#'   posterior draw.  Defaults to `NULL`.
#' @param family Character string specifying the likelihood family.
#'   Currently supported: `"gaussian"` and `"binomial"`.
#'   Defaults to `"gaussian"`.
#' @param sigma_posterior Optional numeric vector of length \eqn{S} containing
#'   posterior draws of the residual standard deviation \eqn{\sigma}.  Only
#'   used when `family = "gaussian"`.  If `NULL`, the empirical standard
#'   deviation of the linear predictor across observations is used as a
#'   fallback.
#' @param n_trials Integer. Number of binomial trials per observation.  Only
#'   used when `family = "binomial"`.  Defaults to `1` (Bernoulli).
#'
#' @return A numeric matrix of dimension \eqn{S \times n} containing one
#'   replicated data set per posterior draw.
#'
#' @details
#' For `family = "gaussian"`, each replicated observation is drawn as
#' \deqn{y^{rep}_{si} \sim \mathcal{N}(\mu_{si},\, \sigma_s^2),}
#' where \eqn{\mu_{si}} is the fitted mean for draw \eqn{s} and observation
#' \eqn{i}.
#'
#' For `family = "binomial"`, the linear predictor is passed through the
#' logistic function \eqn{p = 1 / (1 + e^{-\eta})} and
#' \deqn{y^{rep}_{si} \sim \mathrm{Binomial}(n\_trials,\, p_{si}).}
#'
#' @seealso [ppc_diagnostics()], [plot_ppc_overlay()]
#'
#' @importFrom stats rnorm rbinom sd
#'
#' @examples
#' set.seed(42)
#' S <- 200   # posterior draws
#' n <- 50    # observations
#' draws <- matrix(rnorm(S * n, mean = 2), nrow = S, ncol = n)
#' y_rep  <- simulate_ppc(draws, family = "gaussian")
#' dim(y_rep)  # 200 x 50
#'
#' @export
simulate_ppc <- function(posterior_draws,
                         X                = NULL,
                         family           = "gaussian",
                         sigma_posterior  = NULL,
                         n_trials         = 1L) {

  # ---- input validation -------------------------------------------------------
  if (!is.matrix(posterior_draws)) {
    stop("`posterior_draws` must be a numeric matrix (S x P).", call. = FALSE)
  }
  if (!is.numeric(posterior_draws)) {
    stop("`posterior_draws` must be numeric.", call. = FALSE)
  }
  if (any(!is.finite(posterior_draws))) {
    stop("`posterior_draws` contains non-finite values (NA, NaN, Inf).",
         call. = FALSE)
  }

  family <- match.arg(family, choices = c("gaussian", "binomial"))

  S <- nrow(posterior_draws)
  P <- ncol(posterior_draws)

  # ---- compute linear predictor -----------------------------------------------
  if (!is.null(X)) {
    if (!is.matrix(X) || !is.numeric(X)) {
      stop("`X` must be a numeric matrix (n x P).", call. = FALSE)
    }
    if (ncol(X) != P) {
      stop(
        sprintf(
          "`X` has %d columns but `posterior_draws` has %d columns (parameters). ",
          ncol(X), P
        ),
        "They must match.", call. = FALSE
      )
    }
    # mu_mat: S x n  (each row is one draw's linear predictor)
    mu_mat <- posterior_draws %*% t(X)
  } else {
    # Without X, columns of posterior_draws ARE the per-observation means
    mu_mat <- posterior_draws
  }

  n <- ncol(mu_mat)

  # ---- sample from the likelihood --------------------------------------------
  y_rep <- switch(
    family,

    gaussian = {
      # Determine sigma for each draw
      if (!is.null(sigma_posterior)) {
        if (length(sigma_posterior) != S) {
          stop(
            "`sigma_posterior` must have length equal to nrow(posterior_draws) (S).",
            call. = FALSE
          )
        }
        if (any(sigma_posterior <= 0)) {
          stop("`sigma_posterior` must be strictly positive.", call. = FALSE)
        }
        sigma_vec <- sigma_posterior
      } else {
        # Fallback: use row-wise SD of mu_mat as a rough scale; minimum 1e-6
        sigma_vec <- pmax(apply(mu_mat, 1L, stats::sd), 1e-6)
      }

      # Draw y_rep: vectorised over draws
      noise <- matrix(
        stats::rnorm(S * n, mean = 0, sd = rep(sigma_vec, times = n)),
        nrow = S, ncol = n, byrow = FALSE
      )
      mu_mat + noise
    },

    binomial = {
      n_trials <- as.integer(n_trials)
      if (n_trials < 1L) {
        stop("`n_trials` must be a positive integer.", call. = FALSE)
      }
      # Apply logistic inverse-link
      prob_mat <- 1 / (1 + exp(-mu_mat))

      # Draw counts
      matrix(
        stats::rbinom(S * n, size = n_trials, prob = as.vector(prob_mat)),
        nrow = S, ncol = n
      )
    }
  )

  rownames(y_rep) <- paste0("draw_", seq_len(S))
  colnames(y_rep) <- paste0("obs_",  seq_len(n))

  y_rep
}
