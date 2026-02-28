#' Clean Publication-Ready Theme for Predictive Checking Plots
#'
#' @description
#' A minimal `ggplot2` theme designed for posterior predictive checking
#' visualisations.  It extends [ggplot2::theme_bw()] with modest adjustments
#' for typography, grid lines, and panel borders appropriate for academic
#' figures.
#'
#' @param base_size Numeric. Base font size in points.  Defaults to `12`.
#' @param base_family Character. Base font family.  Defaults to `""` (system
#'   default).
#'
#' @return A `ggplot2` theme object that can be added to any plot with `+`.
#'
#' @importFrom ggplot2 theme_bw theme element_text element_line element_rect
#'   element_blank margin
#'
#' @examples
#' \dontrun{
#'   library(ggplot2)
#'   ggplot(data.frame(x = rnorm(100)), aes(x)) +
#'     geom_histogram(bins = 20) +
#'     theme_ppc()
#' }
#'
#' @export
theme_ppc <- function(base_size = 12, base_family = "") {

  ggplot2::theme_bw(base_size = base_size, base_family = base_family) +
    ggplot2::theme(
      # Panel
      panel.grid.major  = ggplot2::element_line(colour = "grey92", linewidth = 0.4),
      panel.grid.minor  = ggplot2::element_blank(),
      panel.border      = ggplot2::element_rect(colour = "grey60", fill = NA,
                                                linewidth = 0.6),

      # Axes
      axis.title        = ggplot2::element_text(size  = base_size * 0.9,
                                                colour = "grey30"),
      axis.text         = ggplot2::element_text(size  = base_size * 0.8,
                                                colour = "grey40"),
      axis.ticks        = ggplot2::element_line(colour = "grey60",
                                                linewidth = 0.4),

      # Legend
      legend.background = ggplot2::element_rect(fill = "white", colour = NA),
      legend.key        = ggplot2::element_rect(fill = "white", colour = NA),
      legend.text       = ggplot2::element_text(size = base_size * 0.8),
      legend.title      = ggplot2::element_text(size = base_size * 0.85,
                                                face = "bold"),

      # Strip (facets)
      strip.background  = ggplot2::element_rect(fill = "grey95", colour = "grey60",
                                                linewidth = 0.5),
      strip.text        = ggplot2::element_text(size = base_size * 0.85,
                                                face = "bold"),

      # Plot labels
      plot.title        = ggplot2::element_text(size  = base_size * 1.1,
                                                face  = "bold",
                                                colour = "grey20",
                                                margin = ggplot2::margin(b = 6)),
      plot.subtitle     = ggplot2::element_text(size  = base_size * 0.9,
                                                colour = "grey40",
                                                margin = ggplot2::margin(b = 8)),
      plot.caption      = ggplot2::element_text(size  = base_size * 0.75,
                                                colour = "grey55",
                                                hjust = 1),
      plot.margin       = ggplot2::margin(12, 12, 8, 12)
    )
}
