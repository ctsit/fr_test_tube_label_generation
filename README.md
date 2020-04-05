# FR Test Tube Label Generation

This repo contains the script `label_generation.R` that reads test tube label data from REDCap, duplicates every record four times and emails a `csv` file of the report to the addressees named in an environment file. A `.env` must be created to store your REDCap API token. See `env.example` for details on how to set up your `.env` file.

To build the image and run the report using docker within the project directory do:

`docker build -t <image_name> .`

`docker run --env-file .env <image_name>`

To install docker on your Mac:
`brew cask install docker`

To run docker on your MAC:
`open /Applications/Docker.app`

Cron details to follow...
