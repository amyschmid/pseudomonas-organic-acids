# pseudomonas-organic-acids
Synergistic impacts of organic acids and pH on growth of Pseudomonas aeruginosa \\
2018 Francesca Bushell, Peter D. Tonner, Sara Jabarri, Gareth Hughes, Amy K. Schmid, and Peter A. Lund

# Setup

## Requirements

### Preprocessing
* Written in Python version 
* See preprocess.ipynb
* Dependencies 
  * pandas 
  * numpy
  * re
  * os
  * pickle
  * patsy

### Running _phenom_
* See run.ipynb
* Same dependencies as preprocessing

### Running logistic models 
* Written in MatLab version
* Use estimate_logistic_parameters.m 
* Use logged_logisticfitfunction.m

### Post-hoc analysis 
* Written in R version 3.3.2 or RStudio version 1.1.383
* R packages 
  * ggplot2
  * tidyr
  * dplyr
  * gridExtra
  * grid
  * plyr
  * Hmisc
  * corrplot
  * rpgm
* See lund_pseudo_collab_FINAL.Rmd  

