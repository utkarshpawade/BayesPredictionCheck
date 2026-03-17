# example_ppc.R
# Reproducible example: Posterior Predictive Checking with predictCheckR
# Generates three publication-quality plots saved to man/figures/

devtools::load_all(".")
library(ggplot2)

set.seed(42)

# ── Data: simple normal regression y = 2 + 3x + N(0,1) ──────────────────────
n <- 100
x <- seq(0, 1, length.out = n)
y_obs <- 2 + 3 * x + rnorm(n, mean = 0, sd = 1)

# ── Posterior draws (simulating a well-fitted Bayesian model) ─────────────────
S <- 500
posterior_draws <- cbind(
  intercept = rnorm(S, mean = 2.0, sd = 0.15),
  slope     = rnorm(S, mean = 3.0, sd = 0.12)
)
X           <- cbind(1, x)
sigma_draws <- abs(rnorm(S, mean = 1.0, sd = 0.08))

# ── Step 1: Simulate posterior predictive samples ────────────────────────────
y_rep <- simulate_ppc(
  posterior_draws = posterior_draws,
  X               = X,
  family          = "gaussian",
  sigma_posterior = sigma_draws
)

# ── Step 2: Diagnostic statistics ───────────────────────────────────────────
diag_result <- ppc_diagnostics(y_obs = y_obs, y_rep = y_rep)
print(diag_result)

# ── Plot 1: PPC density overlay ──────────────────────────────────────────────
p1 <- plot_ppc_overlay(y_obs, y_rep, n_samples = 50) +
  ggplot2::labs(
    title    = "Posterior Predictive Check: Density Overlay",
    subtitle = "Dark line = observed data; light lines = posterior predictive replicates",
    x        = "y",
    y        = "Density"
  )

ggsave("man/figures/ppc_overlay.png", plot = p1,
       width = 7, height = 4.5, dpi = 150, bg = "white")
message("Saved: man/figures/ppc_overlay.png")

# ── Plot 2: Test-statistic distribution — mean ───────────────────────────────
p2 <- plot_ppc_stat(y_obs, y_rep, stat = "mean") +
  ggplot2::labs(
    title    = "Posterior Predictive Check: Mean Statistic",
    subtitle = "Distribution of replicated means vs. observed mean (vertical line)",
    x        = "T(y) = mean(y)",
    y        = "Count"
  )

ggsave("man/figures/ppc_density.png", plot = p2,
       width = 7, height = 4.5, dpi = 150, bg = "white")
message("Saved: man/figures/ppc_density.png")

# ── Plot 3: Test-statistic distribution — SD ────────────────────────────────
p3 <- plot_ppc_stat(y_obs, y_rep, stat = "sd") +
  ggplot2::labs(
    title    = "Posterior Predictive Check: SD Statistic",
    subtitle = "Distribution of replicated SDs vs. observed SD (vertical line)",
    x        = "T(y) = sd(y)",
    y        = "Count"
  )

ggsave("man/figures/ppc_diagnostics.png", plot = p3,
       width = 7, height = 4.5, dpi = 150, bg = "white")
message("Saved: man/figures/ppc_diagnostics.png")

message("\nAll plots saved to man/figures/")
