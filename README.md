# FR Test Tube Label Generation

This repository contains the script `label_generation.R` that reads data from REDCap then creates a zip folder containing the `.csv` file of appointments and a `.pdf` file of barcodes generated via [baRcodeR](https://docs.ropensci.org/baRcodeR/) for every site where COVID-19 first responder testing is administered. The zipped folder is then emailed to the addressees named in an environment file. A `.env` must be created to store your REDCap API token to access the data. See [`env.example`](./env.example) for details on how to set up your `.env` file.

A docker container is run Monday to Saturday at 3:00 pm EDT via cron to create the appointments for the following day.

To build the image and run the report using docker within the project directory do:

`docker build -t <image_name> .`

`docker run --env-file .env -v path/from/host:/home/fr_test_tube_label_generation <image_name>`


