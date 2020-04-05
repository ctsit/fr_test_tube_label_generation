FROM rocker/tidyverse

WORKDIR /home/fr_test_tube_label_generation

RUN apt update -y && apt install -y \
 libcurl4-openssl-dev 

#install necessary libraries
RUN R -e "install.packages(c('dplyr', 'sendmailR', 'dotenv', 'REDCapR', 'RCurl', 'checkmate','devtools'))"

# install barcoder form github
RUN R -e "devtools::install_github('ropensci/baRcodeR')"

#set the unix commands to run the app
CMD R -e "source('label_generation.R')"
