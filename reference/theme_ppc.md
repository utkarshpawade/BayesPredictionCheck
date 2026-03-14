# Clean Publication-Ready Theme for Predictive Checking Plots

A minimal `ggplot2` theme designed for posterior predictive checking
visualisations. It extends
[`ggplot2::theme_bw()`](https://ggplot2.tidyverse.org/reference/ggtheme.html)
with modest adjustments for typography, grid lines, and panel borders
appropriate for academic figures.

## Usage

``` r
theme_ppc(base_size = 12, base_family = "")
```

## Arguments

- base_size:

  Numeric. Base font size in points. Defaults to `12`.

- base_family:

  Character. Base font family. Defaults to `""` (system default).

## Value

A `ggplot2` theme object that can be added to any plot with `+`.

## Examples

``` r
if (FALSE) { # \dontrun{
  library(ggplot2)
  ggplot(data.frame(x = rnorm(100)), aes(x)) +
    geom_histogram(bins = 20) +
    theme_ppc()
} # }
```
