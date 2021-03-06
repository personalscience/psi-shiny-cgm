% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/psi_plot.R
\name{plot_notes_overlay}
\alias{plot_notes_overlay}
\title{Generate a ggplot2 overlay for notes dataframe}
\usage{
plot_notes_overlay(g, notes_df)
}
\arguments{
\item{g}{a ggplot graphic object}

\item{notes_df}{a valid notes dataframe}
}
\value{
ggplot object
}
\description{
When following a \code{plot_glucose()} call to generate a ggplot object, this returns a
ggplot object to draw the correct information from the notes dataframe
}
