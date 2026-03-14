# Compare Two Models via Posterior Predictive Performance Metrics

Computes a side-by-side comparison of two competing posterior predictive
distributions with respect to three scalar metrics:

- RMSE:

  Root mean squared error of the column-wise predictive means against
  the observed data.

- MAE:

  Mean absolute error of the column-wise predictive means against the
  observed data.

- Pred. Variance Gap:

  Absolute difference between the average predictive variance across
  observations and the empirical variance of the observed data. Smaller
  values indicate that the model captures the spread of the data more
  faithfully.

Lower values are better for all three metrics. The function also
computes the difference (Model 1 − Model 2) for each metric so the
direction and magnitude of improvement are immediately visible.

## Usage

``` r
compare_models_ppc(
  y_obs,
  y_rep1,
  y_rep2,
  model_names = c("Model 1", "Model 2")
)
```

## Arguments

- y_obs:

  Numeric vector of length \\n\\.

- y_rep1:

  Numeric matrix \\S_1 \times n\\. Posterior predictive draws for Model
  1 (e.g. from
  [`simulate_ppc()`](https://utkarshpawade.github.io/predictCheckR/reference/simulate_ppc.md)).

- y_rep2:

  Numeric matrix \\S_2 \times n\\. Posterior predictive draws for
  Model 2. \\S_1\\ and \\S_2\\ need not be equal.

- model_names:

  Character vector of length 2 giving display names for the two models.
  Defaults to `c("Model 1", "Model 2")`.

## Value

A `data.frame` with four columns:

- `metric`:

  Name of the performance metric.

- `model1`:

  Value for Model 1.

- `model2`:

  Value for Model 2.

- `diff_m1_minus_m2`:

  Signed difference (Model 1 − Model 2). Negative values indicate Model
  1 is better for that metric.

## See also

[`ppc_diagnostics()`](https://utkarshpawade.github.io/predictCheckR/reference/ppc_diagnostics.md),
[`simulate_ppc()`](https://utkarshpawade.github.io/predictCheckR/reference/simulate_ppc.md)

## Examples

``` r
set.seed(42)
n  <- 60
S  <- 150
y  <- rnorm(n, mean = 3)

# Model 1: well-specified
draws1 <- matrix(rnorm(S * n, mean = 3), nrow = S, ncol = n)
y_rep1 <- simulate_ppc(draws1)

# Model 2: slightly mis-specified mean
draws2 <- matrix(rnorm(S * n, mean = 5), nrow = S, ncol = n)
y_rep2 <- simulate_ppc(draws2)

compare_models_ppc(y, y_rep1, y_rep2, model_names = c("Correct", "Shifted"))
#>               metric  Correct  Shifted diff_m1_minus_m2
#> 1               RMSE 1.122712 2.347675        -1.224963
#> 2                MAE 0.865520 2.047945        -1.182424
#> 3 Pred. Variance Gap 0.719815 0.767053        -0.047237
```
