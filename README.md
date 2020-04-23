# REDCap First Responder Roster and Test Kit Label Generation

This project provides data products in support of the First Responders COVID-19 Testing project at the University of Florida. The data products are created via R Scripts run by a Docker container.

## Prerequisites

This script uses R and these R packages:

    tidyverse
    dotenv
    REDCapR
    sendmailR
    lubridate
    baRcodeR

To build the Docker container, you will need only Docker.

This project is designed to read data from [`First_Responder_COVID19.xml`](https://github.com/ctsit/fr_covidata/blob/master/example/First_Responder_COVID19.xml) in the [fr_covidata REDCap module](https://github.com/ctsit/fr_covidata) and subsequently create a zip folder containing the `csv` file of appointments and a `pdf` file of barcodes generated via [baRcodeR](https://docs.ropensci.org/baRcodeR/) for every site where First Responder COVID-19 testing is administered. The zipped folder is then emailed to the addressees named in an environment file. 

This script uses the REDCap API to download the data from REDCap. The API must be enabled on the REDCap project and the host where this script runs will need to have access to it.

## Setup and Configuration

This script is configured entirely via the environment. An example `.env` file is provided as [`example.env`](example.env). To use this file, copy it to the name `.env` and customize according to your project needs. Follow these steps to build the required components and configure the script's `.env` file.

1. Create the REDCap project from [`First_Responder_COVID19.xml`](https://github.com/ctsit/fr_covidata/blob/master/example/First_Responder_COVID19.xml). 
1. Give a user User Rights of _Full Data Set_ for _Data Exports_
1. The user will need an API key for the project.
1. Add the API key to the .env file.
1. Set `TIME_ZONE` to assure that time stamps used in the file names and the email are accurate.
1. Revise the `EMAIL_*` and `SMTP_SERVER` settings to reflect your local needs.

## Running the R script

The primary script is [`label_generation.R`](label_generation.R). It can be run at the command line, in RStudio, or by building and running the docker container. In each case the script will read its configuration from the `.env` file.

Build the image and run the report using docker within the project directory like this:

`docker build -t label_generation_all .`

`docker run --rm --env-file <path_to_dir_full_of_env_files>/my.env label_generation_all Rscript *label_generation.R`



