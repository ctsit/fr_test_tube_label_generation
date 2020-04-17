FROM rocker/tidyverse

WORKDIR /home/label_generation

RUN apt update -y && apt install -y \
 libcurl4-openssl-dev

#install necessary libraries
RUN R -e "install.packages(c('dplyr', 'sendmailR', 'dotenv', 'REDCapR', 'RCurl', 'checkmate','devtools', 'qrcode', 'lubridate'))"

# install barcoder form github
RUN R -e "devtools::install_github('ropensci/baRcodeR')"

#set the unix commands to run the app
CMD pwd && ls -AlhF ./
