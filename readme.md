# The U.S. Wealth Distribution: Off the Charts

This repository houses a replication package for and all elements of a 2022 [Socius](https://journals.sagepub.com/home/srd) interactive visualization submission titled The U.S. Wealth Distribution: Off the Charts. This interactive visualization and article was authored by [Fabian Pfeffer](https://lsa.umich.edu/soc/people/faculty/fpfeffer.html) and [Asher Dvir-Djerassi](https://lsa.umich.edu/soc/people/current-graduate-students/asher-dvir-djerassi.html).

* [index.html](index.html) contains html and css code that generates a webpage with the full article text, an embedded interactive visualization, and links to the full screen version of the interactive visualization and supplemental information. This webpage can be found at the following URL: https://asherdvirdjerassi.github.io/wealth_thresholds_viz

* [supplement.html](supplement.html) contains html and css code that generates a webpage with the full supplemental information contained in the article. This webpage can be found at the following URL: https://asherdvirdjerassi.github.io/wealth_thresholds_viz/supplement.html

* [figure1.html](figure1.html) and the directory [lib](lib) contain the html, css, and js code that produces the interactive visualization. 

* [socius_wealth_viz.R](socius_wealth_viz.R) is the R replication package that allows any user to directly reproduce figure 1. This R script directly downloads the data used in the construction of figure1 and, via the Highcharter library, produces the interactive visualization.  

* [SCFP2019.zip](SCFP2019.zip) is a zipped csv file of the 2019 Survey of Consumer Finances, which socius_wealth_viz.R downloads from the Federal Reserve website. 

* [forbes_400_2019.csv](forbes_400_2019.csv) is a csv of the net worth of the Forbes 400 for 2019, which is acquired by socius_wealth_viz.R via scraping the Forbes magazine website.

# Acknowledgments

The visualization was created with support from the [Stone Center for Inequality Dynamics (CID)](https://www.inequalitydynamics.umich.edu/) and a NICHD training grant to the Population Studies Center at the University of Michigan (T32HD007339). The content is solely the responsibility of the authors and does not necessarily represent the official views of the National Institutes of Health.
