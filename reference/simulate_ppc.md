# Generate Posterior Predictive Samples

Generates replicated outcome samples \\y^{rep}\\ from a matrix of
posterior draws under a specified likelihood family. When a design
matrix `X` is supplied the linear predictor \\\eta = X \beta\\ is
computed first and the appropriate inverse-link is applied.

## Usage

``` r
simulate_ppc(
  posterior_draws,
  X = NULL,
  family = "gaussian",
  sigma_posterior = NULL,
  n_trials = 1L
)
```

## Arguments

- posterior_draws:

  A numeric matrix of dimension \\S \times P\\, where \\S\\ is the
  number of posterior iterations and \\P\\ the number of parameters.
  When `X` is `NULL`, \\P\\ is interpreted as the number of observations
  \\n\\ and each column is the marginal posterior mean for one
  observation. When `X` is supplied, \\P\\ must equal `ncol(X)`.

- X:

  Optional numeric design matrix of dimension \\n \times P\\. If
  provided, the linear predictor \\X \beta\\ is computed for each
  posterior draw. Defaults to `NULL`.

- family:

  Character string specifying the likelihood family. Currently
  supported: `"gaussian"` and `"binomial"`. Defaults to `"gaussian"`.

- sigma_posterior:

  Optional numeric vector of length \\S\\ containing posterior draws of
  the residual standard deviation \\\sigma\\. Only used when
  `family = "gaussian"`. If `NULL`, the empirical standard deviation of
  the linear predictor across observations is used as a fallback.

- n_trials:

  Integer. Number of binomial trials per observation. Only used when
  `family = "binomial"`. Defaults to `1` (Bernoulli).

## Value

A numeric matrix of dimension \\S \times n\\ containing one replicated
data set per posterior draw.

## Details

For `family = "gaussian"`, each replicated observation is drawn as
\$\$y^{rep}\_{si} \sim \mathcal{N}(\mu\_{si},\\ \sigma_s^2),\$\$ where
\\\mu\_{si}\\ is the fitted mean for draw \\s\\ and observation \\i\\.

For `family = "binomial"`, the linear predictor is passed through the
logistic function \\p = 1 / (1 + e^{-\eta})\\ and \$\$y^{rep}\_{si} \sim
\mathrm{Binomial}(n\\trials,\\ p\_{si}).\$\$

## See also

[`ppc_diagnostics()`](https://utkarshpawade.github.io/predictCheckR/reference/ppc_diagnostics.md),
[`plot_ppc_overlay()`](https://utkarshpawade.github.io/predictCheckR/reference/plot_ppc_overlay.md)

Other ppc-workflow:
[`compare_models_ppc()`](https://utkarshpawade.github.io/predictCheckR/reference/compare_models_ppc.md),
[`plot_ppc_overlay()`](https://utkarshpawade.github.io/predictCheckR/reference/plot_ppc_overlay.md),
[`plot_ppc_stat()`](https://utkarshpawade.github.io/predictCheckR/reference/plot_ppc_stat.md),
[`ppc_diagnostics()`](https://utkarshpawade.github.io/predictCheckR/reference/ppc_diagnostics.md),
[`print.ppc_diagnostics()`](https://utkarshpawade.github.io/predictCheckR/reference/print.ppc_diagnostics.md),
[`theme_ppc()`](https://utkarshpawade.github.io/predictCheckR/reference/theme_ppc.md)

## Examples

``` r
set.seed(42)
S <- 200   # posterior draws
n <- 50    # observations
draws <- matrix(rnorm(S * n, mean = 2), nrow = S, ncol = n)
y_rep  <- simulate_ppc(draws, family = "gaussian")
dim(y_rep)  # 200 x 50
#> [1] 200  50
```
