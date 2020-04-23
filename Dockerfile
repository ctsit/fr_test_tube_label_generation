FROM rocker/tidyverse

WORKDIR /home/label_generation

RUN apt update -y && apt install -y libcurl4-openssl-dev

#install necessary libraries
RUN R -e "install.packages(c('sendmailR', 'dotenv', 'REDCapR', 'RCurl', 'checkmate', 'qrcode', 'lubridate'))"

# install barcoder form github
RUN R -e "devtools::install_github('ropensci/baRcodeR')"

ADD *label_generation.R /home/label_generation/
ADD functions.R /home/label_generation/

# Note where we are and what is there
CMD pwd && ls -AlhF ./
