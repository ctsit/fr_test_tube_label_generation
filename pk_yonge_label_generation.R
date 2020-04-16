library(tidyverse)
library(sendmailR)
library(dotenv)
library(devtools)
# install dev version of baRcodeR if not previously installed
# devtools::install_github('ropensci/baRcodeR')
library(baRcodeR)
library(REDCapR)
library(lubridate)

source("functions.R")

# set the timezone
Sys.setenv(TZ = Sys.getenv("TIME_ZONE"))

# When script is run Mon-Fri appt_date is the next day
# When script is run on Sat appt_day is Monday
appt_date <- case_when(
  wday(now()) == 7 ~ today() + 2,
  TRUE ~ today() + 1
)

# email credentials
email_server <- list(smtpServer = Sys.getenv("SMTP_SERVER"))
email_from <- Sys.getenv("PK_EMAIL_FROM")
email_to <- unlist(strsplit(Sys.getenv("PK_EMAIL_TO")," "))
email_cc <- unlist(strsplit(Sys.getenv("PK_EMAIL_CC")," "))
email_subject <- paste(Sys.getenv("PK_EMAIL_SUBJECT"), appt_date)

test_tube_label <- get_pk_test_tube_label()

appt_counts <- test_tube_label %>%
  count(site_long_name) %>%
  add_row(site_long_name = "Total", n = nrow(test_tube_label)) %>%
  unite("Counts", sep = " = ")

# create folder to store output
output_dir <- paste0("pk_covid19_", appt_date)
dir.create(output_dir, recursive = T)

# create per site roster
test_tube_label %>%
  select(-subject_id) %>%
  write.csv(paste0(output_dir, "/pk_yonge_roster_", appt_date, ".csv"),
            na = "", row.names = F)


sites <- unique(test_tube_label$site_short_name)
# create per site barcode pdfs
for (site in sites){

  per_site_df <- test_tube_label %>%
    select(research_encounter_id, site_short_name, subject_id) %>%
    filter(site_short_name == site)

  if(nrow(per_site_df) <= 19){
    per_site_df <- per_site_df %>%
      add_new_row(.before = 1) %>%
      slice(rep(1:n(), each = 4))
  } else if (nrow(per_site_df) <= 38){
    per_site_df <- per_site_df %>%
      add_new_row(.before = 1) %>%
      add_new_row(.before = 21) %>%
      slice(rep(1:n(), each = 4))
  } else {
    per_site_df <- per_site_df %>%
      add_new_row(.before = 1) %>%
      add_new_row(.before = 21) %>%
      add_new_row(.before = 41) %>%
      slice(rep(1:n(), each = 4))
  }

  custom_create_PDF(Labels = per_site_df$research_encounter_id,
                    alt_text = per_site_df$subject_id,
                    type = "matrix",
                    label_height = 0.3,
                    denote = c("\n","\n"),
                    Fsz = 5,
                    trunc = T,
                    y_space = 0.5,
                    ErrCorr = "Q",
                    name = paste0(output_dir, "/", site,
                                  '_pk_covid_test_tube_labels_',
                                  appt_date))
}


# Zip the reports generated
zipfile_name = paste0(output_dir, ".zip")
zip(zipfile_name, output_dir)

# attach the zip file and email it
attachment_object <- mime_part(zipfile_name, zipfile_name)
body <- paste0("The attached files include labels to be printed for the PK Yonge COVID-19 project.",
               " These labels are designed for the blood spot cards and swab collection kits to be used at the collection sites.",
               " These labels should be printed and packaged with the blood spot and swab kits for their respective sites.",
               " The attached files were generated on ", now(), ".",
               "\n\nNumber of appts for ", appt_date, ": ", str_remove_all(appt_counts,"[[:punct:]]")
)

body_with_attachment <- list(body, attachment_object)

# send the email with the attached output file
sendmail(from = email_from, to = email_to, cc = email_cc,
         subject = email_subject, msg = body_with_attachment,
         control = email_server)

# uncomment to delete output once on tools4
# unlink(zipfile_name, recursive = T)
# unlink(output_dir, recursive = T)
