# Posterior Predictive Test-Statistic Distribution Plot

Wraps
[`bayesplot::ppc_stat()`](https://mc-stan.org/bayesplot/reference/PPC-test-statistics.html)
to plot the distribution of a scalar test statistic \\T(y^{rep})\\
across posterior predictive replicates, overlaid with the observed value
\\T(y)\\. The plot is styled with
[`theme_ppc()`](https://utkarshpawade.github.io/predictCheckR/reference/theme_ppc.md).

Large discrepancies between \\T(y)\\ and the bulk of the \\T(y^{rep})\\
distribution are evidence of model misfit with respect to the chosen
statistic.

## Usage

``` r
plot_ppc_stat(y_obs, y_rep, stat = "mean", ...)
```

## Arguments

- y_obs:

  Numeric vector of length \\n\\.

- y_rep:

  Numeric matrix of dimension \\S \times n\\.

- stat:

  Character string naming the test statistic. Currently supported
  values: `"mean"` and `"sd"`. Defaults to `"mean"`.

- ...:

  Additional arguments passed to
  [`bayesplot::ppc_stat()`](https://mc-stan.org/bayesplot/reference/PPC-test-statistics.html).

## Value

A `ggplot2` object.

## See also

[`plot_ppc_overlay()`](https://utkarshpawade.github.io/predictCheckR/reference/plot_ppc_overlay.md),
[`bayesplot::ppc_stat()`](https://mc-stan.org/bayesplot/reference/PPC-test-statistics.html)

## Examples

``` r
set.seed(3)
y     <- rnorm(80, mean = 1, sd = 1)
draws <- matrix(rnorm(300 * 80, mean = 1), nrow = 300, ncol = 80)
y_rep <- simulate_ppc(draws)
p     <- plot_ppc_stat(y, y_rep, stat = "sd")
if (FALSE) { # \dontrun{
  print(p)
} # }
```
