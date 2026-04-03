# Posterior Predictive Density Overlay Plot

Wraps
[`bayesplot::ppc_dens_overlay()`](https://mc-stan.org/bayesplot/reference/PPC-distributions.html)
with consistent styling via
[`theme_ppc()`](https://utkarshpawade.github.io/predictCheckR/reference/theme_ppc.md).
Subsamples `y_rep` rows for readability when \\S\\ is large.

## Usage

``` r
plot_ppc_overlay(y_obs, y_rep, n_samples = 50, ...)
```

## Arguments

- y_obs:

  Numeric vector of length \\n\\ containing the observed outcomes.

- y_rep:

  Numeric matrix of dimension \\S \times n\\ where each row is one
  posterior predictive replicate (e.g. the output of
  [`simulate_ppc()`](https://utkarshpawade.github.io/predictCheckR/reference/simulate_ppc.md)).

- n_samples:

  Positive integer. Number of rows to subsample from `y_rep` for the
  overlay. Subsampling improves readability when \\S\\ is large.
  Defaults to `50`. The subsample is drawn without replacement when
  `n_samples < S`, otherwise all rows are used.

- ...:

  Additional arguments passed to
  [`bayesplot::ppc_dens_overlay()`](https://mc-stan.org/bayesplot/reference/PPC-distributions.html).

## Value

A `ggplot2` object.

## See also

[`plot_ppc_stat()`](https://utkarshpawade.github.io/predictCheckR/reference/plot_ppc_stat.md),
[`bayesplot::ppc_dens_overlay()`](https://mc-stan.org/bayesplot/reference/PPC-distributions.html)

Other ppc-workflow:
[`compare_models_ppc()`](https://utkarshpawade.github.io/predictCheckR/reference/compare_models_ppc.md),
[`plot_ppc_stat()`](https://utkarshpawade.github.io/predictCheckR/reference/plot_ppc_stat.md),
[`ppc_diagnostics()`](https://utkarshpawade.github.io/predictCheckR/reference/ppc_diagnostics.md),
[`print.ppc_diagnostics()`](https://utkarshpawade.github.io/predictCheckR/reference/print.ppc_diagnostics.md),
[`simulate_ppc()`](https://utkarshpawade.github.io/predictCheckR/reference/simulate_ppc.md),
[`theme_ppc()`](https://utkarshpawade.github.io/predictCheckR/reference/theme_ppc.md)

## Examples

``` r
set.seed(7)
y     <- rnorm(80, mean = 0, sd = 1)
draws <- matrix(rnorm(300 * 80, mean = 0), nrow = 300, ncol = 80)
y_rep <- simulate_ppc(draws)
# \donttest{
  p <- plot_ppc_overlay(y, y_rep, n_samples = 40)
# }
```
