# Print Method for ppc_diagnostics Objects

Displays a formatted summary of the predictive diagnostic statistics
returned by
[`ppc_diagnostics()`](https://utkarshpawade.github.io/predictCheckR/reference/ppc_diagnostics.md).

## Usage

``` r
# S3 method for class 'ppc_diagnostics'
print(x, digits = 4, ...)
```

## Arguments

- x:

  An object of class `"ppc_diagnostics"`.

- digits:

  Integer. Number of significant digits to display. Defaults to `4`.

- ...:

  Currently unused; included for S3 method compatibility.

## Value

Invisibly returns `x`.

## See also

[`ppc_diagnostics()`](https://utkarshpawade.github.io/predictCheckR/reference/ppc_diagnostics.md)

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
