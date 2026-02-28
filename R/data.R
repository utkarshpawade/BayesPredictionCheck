#' Example Simulated Regression Dataset
#'
#' @description
#' A small simulated dataset suitable for demonstrating the predictCheckR
#' workflow.  Data were generated from a simple univariate linear regression
#' model:
#'
#' \deqn{x_i \sim \mathcal{N}(0, 1)}
#' \deqn{y_i = 2 + 3 x_i + \varepsilon_i, \quad
#'       \varepsilon_i \sim \mathcal{N}(0, 1)}
#'
#' The true parameter values are therefore intercept = 2 and slope = 3.
#'
#' @format A data frame with 100 rows and 2 variables:
#' \describe{
#'   \item{`x`}{Numeric predictor drawn from \eqn{\mathcal{N}(0, 1)}.}
#'   \item{`y`}{Numeric response: \eqn{y = 2 + 3x + \varepsilon},
#'              where \eqn{\varepsilon \sim \mathcal{N}(0, 1)}.}
#' }
#'
#' @source Simulated internally with `set.seed(2024)`.
#'   See `data-raw/create_example_data.R` for the generation script.
#'
#' @examples
#' data(example_data)
#' head(example_data)
#' cor(example_data$x, example_data$y)
#' plot(example_data$x, example_data$y,
#'      xlab = "x", ylab = "y",
#'      main = "Example regression data")
#' abline(lm(y ~ x, data = example_data), col = "steelblue", lwd = 2)
#'
"example_data"
