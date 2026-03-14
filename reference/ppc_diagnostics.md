# Posterior Predictive Diagnostic Statistics

Computes a suite of predictive discrepancy statistics that quantify how
well the posterior predictive distribution \\p(y^{rep} \mid y)\\ matches
the observed data \\y\\. All statistics are scalar summaries derived
from the \\S \times n\\ replicated data matrix.

## Usage

``` r
ppc_diagnostics(y_obs, y_rep, credible_mass = 0.95)
```

## Arguments

- y_obs:

  Numeric vector of length \\n\\ containing the observed outcomes.

- y_rep:

  Numeric matrix of dimension \\S \times n\\ where each row is one
  posterior predictive replicate (e.g. the output of
  [`simulate_ppc()`](https://utkarshpawade.github.io/predictCheckR/reference/simulate_ppc.md)).

- credible_mass:

  Numeric scalar in \\(0, 1)\\ specifying the credible interval mass
  used for the coverage calculation. Defaults to `0.95`.

## Value

An object of class `"ppc_diagnostics"` (a named list) with the following
elements:

- `mean_diff`:

  Difference between the mean of the replicated means and the observed
  mean: \\\bar{\mu}\_{rep} - \bar{y}\\.

- `var_diff`:

  Difference between the mean of the replicated variances and the
  observed variance: \\\bar{v}\_{rep} - \mathrm{Var}(y)\\.

- `bayesian_p_value`:

  Proportion of draws for which the replicated mean exceeds the observed
  mean. Values near 0.5 indicate good calibration.

- `rmse`:

  Root mean squared error between the column-wise predictive means and
  the observed values: \\\sqrt{n^{-1}\sum_i (\bar{y}^{rep}\_i -
  y_i)^2}\\.

- `coverage`:

  Proportion of observations whose value falls inside the
  `credible_mass` posterior predictive interval.

- `n_draws`:

  Number of posterior draws \\S\\.

- `n_obs`:

  Number of observations \\n\\.

- `credible_mass`:

  The credible mass used for the coverage calculation.

## See also

[`simulate_ppc()`](https://utkarshpawade.github.io/predictCheckR/reference/simulate_ppc.md),
[`print.ppc_diagnostics()`](https://utkarshpawade.github.io/predictCheckR/reference/print.ppc_diagnostics.md)

## Examples

``` r
set.seed(1)
y     <- rnorm(50, mean = 2, sd = 1)
draws <- matrix(rnorm(200 * 50, mean = 2), nrow = 200, ncol = 50)
y_rep <- simulate_ppc(draws)
diag  <- ppc_diagnostics(y, y_rep)
print(diag)
#> 
#> -- Posterior Predictive Diagnostics (predictCheckR) --
#> 
#>   Draws  : 200
#>   Obs    : 50
#> 
#>   Discrepancy Statistics:
#>     Mean difference        : -0.1107
#>     Variance difference    : 1.353
#>     Bayesian p-value       : 0.28
#>     RMSE (pred vs. obs)    : 0.8518
#>     Coverage (95% CI)      : 1
#> 
```
