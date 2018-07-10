# pseudomonas-organic-acids
Synergistic impacts of organic acids and pH on growth of _Pseudomonas aeruginosa_ \
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
* Input: data/raw

### Running _phenom_
* See run.ipynb
* Same dependencies as preprocessing
* Input: data/processed
* Output: phenom_output

### Running logistic models 
* Written in MatLab version
* Use estimate_logistic_parameters.m 
* Use logged_logisticfitfunction.m
* Input: data/processed
* Output: logistic_output

### Post-hoc analysis 
* Written in R version 3.3.2 or RStudio version 1.1.383
* R packages (version used)
  * ggplot2 (2.2.1)
  * tidyr (0.7.2)
  * dplyr (0.7.4)
  * gridExtra (2.3)
  * grid (NA)
  * plyr (1.8.4)
  * Hmisc (4.0-3)
  * corrplot (0.84)
  * rpgm (1.1.2)
* See lund_pseudo_collab_FINAL.Rmd
* Input: data/phenom_output and data/logistic_output


