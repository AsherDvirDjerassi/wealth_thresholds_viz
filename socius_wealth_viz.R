# Authors: Asher Dvir-Djerassi and Fabian Pfeffer
# Date Began: 09/21/22
# Last Updated: 11/11/22

# Description: This program creates an interactive visualization that is exported as an HTML file.
# Data: 2019 Survey of Consumer Finances (SCF) public use file and the 2019 Forbes 400.

##############################################################################
################################### I. Set-up ################################
##############################################################################

#############################
#### Packages & Libraries ###
#############################

# Used for its  comma function
install.packages("formattable", repos = "http://cran.us.r-project.org")
library("formattable")

# The wrapper for highcharts, highcharter, imports most need packages in addition to being core to the visualizatio.
# Imported dependencies:	htmlwidgets, magrittr, purrr, rlist, assertthat, zoo, dplyr (≥ 1.0.0), tibble (≥ 1.1), stringr (≥ 1.3.0), broom, xts, quantmod, tidyr, htmltools, jsonlite, igraph, lubridate, yaml, rlang (≥ 0.1.1), rjson
install.packages("highcharter", repos = "http://cran.us.r-project.org")
library("highcharter") # For highcharter visualization

# Import the redlist, which is used for computing weighted statistics, included weighted quantiles.
# Imported dependencies: ps, processx, checkmate, matrixStats, callr, crayon, prettyunits, rprojroot, inline, gridExtra, loo, pkgbuild, desc, Rcpp, rstan, rstantools, BH, RcppArmadillo, RcppEigen, RcppParallel, StanHeaders, densEstBayes
install.packages("reldist", repos = "http://cran.us.r-project.org")
library("reldist")  #For computing weighted statistics 

# Allows saving an HTML object to a file
install.packages("htmltools", repos = "http://cran.us.r-project.org")
library("htmltools")

# Checks if pandoc is installed and prints its location
install.packages("pandoc", repos = "http://cran.us.r-project.org")
library("pandoc")
if(!pandoc_available()){
  pandoc_install()
  pandoc_activate()
}
pandoc_available()

#############################
#### Scientific Notation ####
#############################

options(scipen=999) # removes scientific notation from R output

##############################################################################
################################### II. Data #################################
##############################################################################

#############################
######### Load SCF ##########
#############################

# NOTE: To download raw SCF data from the Fed website, replace FALSE with TRUE.
if(FALSE){
  download.file("https://www.federalreserve.gov/econres/files/scfp2019excel.zip", "SCFP2019.zip")
}

scf <- read.csv(unzip("scfp2019.zip"), header = TRUE) 
system("rm scfp2019.csv") # rm csv of scf
scf <- scf[c("NETWORTH","WGT")]
scf$YEAR <- 2019

#############################
##### Load Forbes 400  ######
#############################

# NOTE: To scrape and clean raw Forbes 400 data for 2019, replace FALSE with TRUE
if(FALSE) {
  # scrape raw forbes 400 data for 2019
  forbes_400_2019 <- cbind.data.frame(jsonlite::fromJSON(paste0("http://www.forbes.com/ajax/list/data?year=", 2019, "&uri=forbes-400", "&type=person")),year= 2019)
  # rename variables
  colnames(forbes_400_2019)[colnames(forbes_400_2019) == "worth"] ="NETWORTH"
  colnames(forbes_400_2019)[colnames(forbes_400_2019) == "year"] ="YEAR"
  # create sample weights
  forbes_400_2019$WGT <- 1
  # transform networth value
  forbes_400_2019$NETWORTH <- forbes_400_2019$NETWORTH*1000000
  # keep subset of variables
  forbes_400_2019 <- forbes_400_2019[c("NETWORTH", "WGT", "YEAR")]
  # drop if na values for networth
  forbes_400_2019 <- na.omit(forbes_400_2019)
  # write csv
  write.csv(forbes_400_2019, "forbes_400_2019.csv", row.names = FALSE)
}

forbes_400 <- read.csv("forbes_400_2019.csv")

##############################################################################
####################### III. FIGURE - Wealth Thresholds ######################
##############################################################################

#############################
####### Data for Viz  #######
#############################

# number of households in net debt - referenced in text
comma(sum(subset(scf$WGT, scf$NETWORTH < 0)))

# create quantiles 
df_quantiles <- data.frame(matrix (nrow = 100, ncol = 0, byrow = 1))
df_quantiles$quantiles <-  c(seq(1, 99, by = 1), "Forbes 400")
df_quantiles$quantiles[100] <- c("Forbes 400")

df_quantiles$"Forbes 400" <- 0
df_quantiles$"Forbes 400"[100] <- min(subset(forbes_400$NETWORTH, forbes_400$YEAR == 2019))
df_quantiles$Thresholds <- 
  c(wtd.quantile(scf$NETWORTH, seq(.01, .99, by = .01), weight = scf$WGT), NA)

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

figure1 <- highchart() %>%
  hc_chart(type ="column",
           barBorderWidth = 1) %>%
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
           type = "category",
           showFirstLabel = TRUE,
           showLastLabel = TRUE
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

save_html(figure1, "figure1.html")
