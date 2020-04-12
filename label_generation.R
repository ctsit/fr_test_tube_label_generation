library(tidyverse)
library(sendmailR)
library(dotenv)
library(devtools)
# install dev version of baRcodeR if not previously installed
# devtools::install_github('ropensci/baRcodeR')
library(baRcodeR)
library(REDCapR)
library(lubridate)

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
email_from <- Sys.getenv("EMAIL_FROM")
email_to <- unlist(strsplit(Sys.getenv("EMAIL_TO")," "))
email_cc <- unlist(strsplit(Sys.getenv("EMAIL_CC")," "))
email_subject <- paste(Sys.getenv("EMAIL_SUBJECT"), appt_date)

test_tube_label <- redcap_read_oneshot(redcap_uri = 'https://redcap.ctsi.ufl.edu/redcap/api/',
                                       token = Sys.getenv("API_TOKEN"))$data %>%
  select(research_encounter_id, ce_firstname, ce_lastname, patient_dob,
         site_short_name, site_long_name, test_date_and_time) %>%
  mutate(ce_firstname = str_to_title(ce_firstname),
         ce_lastname = str_to_title(ce_lastname),
         subject_id = paste(ce_firstname, ce_lastname, patient_dob)) %>%
  filter(as_date(test_date_and_time) == appt_date) %>%
  arrange(site_short_name, test_date_and_time)

appt_counts <- test_tube_label %>%
  count(site_short_name) %>%
  add_row(site_short_name = "Total", n = nrow(test_tube_label)) %>%
  unite("Counts", sep = " = ")

# create folder to store output
output_dir <- paste0("fr_covid19_", appt_date)
dir.create(output_dir, recursive = T)

# create per site roster
test_tube_label %>%
  select(-subject_id) %>%
  split(.$site_short_name) %>%
  walk2(paste0(output_dir, "/", names(.), "_", appt_date, ".csv"), write.csv, row.names = F)

# add sitname and appt date at specified position
add_new_row <- function(per_site_df, ...){
  add_row(per_site_df,
          subject_id = paste("Appt Date:", appt_date),
          research_encounter_id = unique(per_site_df$site_short_name),
          site_short_name = unique(per_site_df$site_short_name),
          ...)
}


sites <- unique(test_tube_label$site_short_name)
# create per site barcode pdfs
for (site in sites){

  per_site_df <- test_tube_label %>%
    select(research_encounter_id, site_short_name, subject_id) %>%
    filter(site_short_name == site)

  if(nrow(per_site_df) <= 18){
    per_site_df <- per_site_df %>%
      add_new_row(.before = 1) %>%
      add_new_row() %>%
      slice(rep(1:n(), each = 4))
  } else if (nrow(per_site_df) <= 40){
    per_site_df <- per_site_df %>%
      add_new_row(.before = 1) %>%
      add_new_row(.before = 20) %>%
      add_new_row(.before = 21) %>%
      add_new_row() %>%
      slice(rep(1:n(), each = 4))
  } else {
    per_site_df <- per_site_df %>%
      add_new_row(.before = 1) %>%
      add_new_row(.before = 20) %>%
      add_new_row(.before = 21) %>%
      add_new_row(.before = 40) %>%
      add_new_row(.before = 41) %>%
      add_new_row() %>%
      slice(rep(1:n(), each = 4))
  }

  custom_create_PDF(Labels = per_site_df$research_encounter_id,
                    alt_text = per_site_df$subject_id,
                    type = "linear",
                    denote = c("(",")"),
                    label_height = .20,
                    name = paste0(output_dir, "/", site,
                                  '_fr_covid_test_tube_labels_',
                                  appt_date))
}


# Zip the reports generated
zipfile_name = paste0(output_dir, ".zip")
zip(zipfile_name, output_dir)

# attach the zip file and email it
attachment_object <- mime_part(zipfile_name, zipfile_name)
body <- paste0("The attached files include labels to be printed for the First Responder COVID-19 project.",
               " These labels are designed for the serum tubes and swab collection kits to be used at the collection sites.",
               " These labels should be printed and packaged with the serum and swab kits for their respective sites.",
               " The attached files were generated on ", now(), ".",
               "\n\nNumber of appts for ", appt_date, ": ", str_remove_all(appt_counts,"[[:punct::]]")
)

body_with_attachment <- list(body, attachment_object)

# send the email with the attached output file
sendmail(from = email_from, to = email_to, cc = email_cc,
         subject = email_subject, msg = body_with_attachment,
         control = email_server)

# uncomment to delete output once on tools4
# unlink(zipfile_name, recursive = T)
# unlink(output_dir, recursive = T)
