# Authors: Asher Dvir-Djerassi and Fabian Pfeffer
# Date Began: 09/21/22
# Last Updated: 09/25/22

# Description: This program creates an interactive visualization that is exported as an HTML file.
# Data: 2019 Survey of Consumer Finances (SCF) public use file and the 2019 Forbes 400.

##############################################################################
################################### I. Set-up ################################
##############################################################################

#############################
#### Packages & Libraries ###
#############################

install.packages("formattable")
library("formattable")
install.packages("dplyr")
library("dplyr")
install.packages("ggplot2")
library("ggplot2")

# Allows saving an HTML object to a file
install.packages("htmltools")
library("htmltools")

# The wrapper for highcharts, highcharter, imports most need packages in addition to being core to the visualizatio.
# Imported dependencies:	htmlwidgets, magrittr, purrr, rlist, assertthat, zoo, dplyr (≥ 1.0.0), tibble (≥ 1.1), stringr (≥ 1.3.0), broom, xts, quantmod, tidyr, htmltools, jsonlite, igraph, lubridate, yaml, rlang (≥ 0.1.1), rjson
install.packages("highcharter")
library("highcharter") # For highcharter visualization

# Import the redlist, which is used for computing weighted statistics, included weighted quantiles.
# Imported dependencies: ps, processx, checkmate, matrixStats, callr, crayon, prettyunits, rprojroot, inline, gridExtra, loo, pkgbuild, desc, Rcpp, rstan, rstantools, BH, RcppArmadillo, RcppEigen, RcppParallel, StanHeaders, densEstBayes
install.packages('reldist')
library("reldist")  #For computing weighted statistics 

#############################
#### Scientific Notation ####
#############################

options(scipen=999) # this remove scientific notation from R output

##############################################################################
################################### II. Data #################################
##############################################################################

#############################
######### Load SCF ##########
#############################

scf <- read.csv(file='scf.csv', header = TRUE, row.names = 1) 

#############################
##### Load Forbes 400  ######
#############################

forbes_400 <- read.csv("forbes_400.csv")

#############################
#### Merge Forbes & SCF #####
#############################

# create forbes indicator
forbes_400$Forbes_indicator <- 1
scf$Forbes_indicator <- 0

# keep only networth in 2019 USD
forbes_400$NETWORTH <- forbes_400$NETWORTH_2019
forbes_400$NETWORTH_2019 <- NULL

scf_non_forbes <- scf
scf <- dplyr::bind_rows(scf, forbes_400[c("NETWORTH","YEAR","WGT", "Forbes_indicator")])

# subset 2019
scf_2019_forbes <- subset(scf, YEAR == 2019)

# number of households in net debt
comma(sum(subset(scf_2019_forbes$WGT, scf_2019_forbes$NETWORTH < 0)))

##############################################################################
####################### III. FIGURE - Wealth Thresholds ######################
##############################################################################

#############################
####### Data for Viz  #######
#############################

df_quantiles <- data.frame(matrix (nrow = 100, ncol = 0, byrow = 1))
df_quantiles$quantiles <-  c(seq(1, 99, by = 1), "Forbes 400")
df_quantiles$quantiles[100] <- c("Forbes 400")

df_quantiles$"Forbes 400" <- 0
df_quantiles$"Forbes 400"[100] <- min(subset(forbes_400$NETWORTH, forbes_400$YEAR == 2019))
df_quantiles$Thresholds <- c(wtd.quantile(subset(scf_2019_forbes$NETWORTH,scf_2019_forbes$Forbes_indicator == 0), seq(.01, .99, by = .01), weight = subset(scf_2019_forbes$WGT,scf_2019_forbes$Forbes_indicator == 0)),NA)

#############################
#### Highcharter Options ####
#############################

options(highcharter.theme = hc_theme_smpl(tooltip = list(valueDecimals = 0, thousandsSep = ',')))
lang <- getOption("highcharter.lang")
lang$numericSymbols <- c(" Thousand"," Million"," Billion"," Trillion")
lang$thousandsSep <- ","
options(highcharter.lang = lang)

#############################
########## Figure 1 #########
#############################

figure <-
 highchart() %>%
  hc_chart(type ="column",
           barBorderWidth = 0) %>%
  hc_title(text = "Figure 1: Wealth thresholds") %>%
  hc_chart(zoomType = "x") %>%
  hc_plotOptions(column = list(
    dataLabels = list(enabled = FALSE),
    stacking = "normal",
    groupPadding = 0,
    pointPadding = 0,
    enableMouseTracking = TRUE)) %>% 
  hc_yAxis_multiples(
    list(title = list(text = "Wealth in 2019 USD", style = list(fontSize = '13px')), opposite = FALSE),
    list(title = list(text = "Wealth in 2019 USD", style = list(fontSize = '13px')), opposite = TRUE)) %>%
  hc_xAxis(title = list(text = "Wealth Percentiles", style = list(fontSize = '13px')),
           categories = df_quantiles$quantiles, 
           showFirstLabel = TRUE,
           showLastLabel = TRUE,
           plotBands = list(
             list(
               from = 49,
               to = 49,
               color = "rgba(0, 0, 0, 0.5)"
             )
           )
        ) %>%
  hc_annotations(
    list(
      labels = list(
        list(point = list(x = 49, y = 5, xAxis = 0, yAxis = 0), text = "Median"))
    )
  ) %>%
  hc_add_series(data = round(df_quantiles$Thresholds), name = "Wealth Thresholds", color = "grey", showInLegend = FALSE, visible = TRUE) %>%
  hc_add_series(name = "<p style='font-size:15px; color:black'> Include Forbes 400 wealth threshold </p>", data = round(df_quantiles$`Forbes 400`), color = "red", showInLegend = TRUE, visible = FALSE,  fontSize = '200px') %>%
  hc_legend(
    align = "left",
    verticalAlign = "top",
    x = 75,
    y = 0
    ) %>%
  hc_exporting(enabled = TRUE) %>%
  hc_tooltip(
    useHTML = TRUE,                              
    formatter = JS(
      "
      function(){
        outHTML = '<b> Wealth Percentile: </b>' + this.x + '<br> <b> Threshold Value: </b>' + '$' + Number(this.y).toLocaleString()
        return(outHTML)
      }
      "
    ),
    shape = "callout", # Options are square, circle and callout
    borderWidth = 1   # No border on the tooltip shape
  )

save_html(figure, file = 'figure.html')

