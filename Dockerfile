FROM rocker/tidyverse

WORKDIR /home/fr_test_tube_label_generation

RUN apt update -y && apt install -y \
 libcurl4-openssl-dev 
 
COPY label_generation.R label_generation.R

#install necessary libraries
RUN R -e "install.packages(c('dplyr', 'sendmailR', 'dotenv', 'REDCapR', 'RCurl', 'checkmate','baRcodeR'))"

#set the unix commands to run the app
CMD R -e "source('label_generation.R')"
