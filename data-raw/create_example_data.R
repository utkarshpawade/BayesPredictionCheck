## data-raw/create_example_data.R
## Run this script once to regenerate data/example_data.rda
## Requires the usethis package (or manual save with base R).

set.seed(2024)

n         <- 100L
x         <- rnorm(n, mean = 0, sd = 1)
epsilon   <- rnorm(n, mean = 0, sd = 1)
y         <- 2 + 3 * x + epsilon

example_data <- data.frame(x = x, y = y)

## Persist as compressed .rda in data/
save(example_data,
     file    = "data/example_data.rda",
     compress = "bzip2",
     version  = 3L)

message("data/example_data.rda written successfully.")
