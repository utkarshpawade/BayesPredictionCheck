# ---- Shared input validation helpers (internal) -----------------------------
# These are used across multiple exported functions to avoid code duplication.

#' Validate observed data vector
#' @param y_obs Object to validate.
#' @return `y_obs` invisibly; called for its side effect of stopping on error.
#' @keywords internal
#' @noRd
validate_y_obs <- function(y_obs) {
  if (!is.numeric(y_obs) || !is.vector(y_obs)) {
    stop("`y_obs` must be a numeric vector.", call. = FALSE)
  }

if (any(!is.finite(y_obs))) {
    stop("`y_obs` contains non-finite values.", call. = FALSE)
  }
  invisible(y_obs)
}

#' Validate replicated data matrix against observed data
#' @param y_rep Object to validate.
#' @param y_obs Numeric vector that `y_rep` must be compatible with.
#' @return `y_rep` invisibly; called for its side effect of stopping on error.
#' @keywords internal
#' @noRd
validate_y_rep <- function(y_rep, y_obs) {
  if (!is.matrix(y_rep) || !is.numeric(y_rep)) {
    stop("`y_rep` must be a numeric matrix (S x n).", call. = FALSE)
  }
  if (ncol(y_rep) != length(y_obs)) {
    stop(
      sprintf(
        "`y_rep` has %d columns but `y_obs` has length %d. Columns of `y_rep` must correspond to observations.",
        ncol(y_rep), length(y_obs)
      ),
      call. = FALSE
    )
  }
  invisible(y_rep)
}
