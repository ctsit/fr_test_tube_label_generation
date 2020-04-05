library(tidyverse)
library(sendmailR)
library(dotenv)
library(baRcodeR)
# devtools::install_github("ropensci/baRcodeR")
library(REDCapR)


# email credentials
email_server <- list(smtpServer = Sys.getenv("SMTP_SERVER"))
email_from <- Sys.getenv("EMAIL_FROM")
email_to <- unlist(strsplit(Sys.getenv("EMAIL_TO")," "))
email_cc <- unlist(strsplit(Sys.getenv("EMAIL_CC")," "))
email_subject <- Sys.getenv("EMAIL_SUBJECT")

# TODO: change redcap_uri and api token for production project
test_tube_label <- redcap_read_oneshot(redcap_uri = 'https://redcap.ctsi.ufl.edu/redcap/api/',
                                       token = Sys.getenv("API_TOKEN"))$data %>%   
  slice(rep(1:n(), each = 4)) %>% 
  # test code starts
  slice(1:80) %>% 
  mutate(
         frcovid_fn = substr(frcovid_fn, 1, 1),
         subject_id = paste(frcovid_fn, frcovid_ln, frcovid_dob),
         site = c(rep("KED", 40), rep("SHED", 30), rep("AED", 10))) %>% 
  # test code ends
  arrange(site, frcovid_ln)  

# create folder to store output
output_dir <- as.character(Sys.Date())
dir.create(output_dir, recursive = T)

# create per site roster
test_tube_label %>% 
  split(.$site) %>% 
  walk2(paste0(output_dir, "/", names(.), ".csv"), write.csv, row.names = F)

# create per site barcode pdfs
test_tube_label %>% 
  select(sample_id, site, subject_id) %>% 
  split(.$site) %>% 
  map(~ custom_create_PDF(Labels = .$sample_id,
                          alt_text = .$subject_id,
                          type = "linear",
                          denote = c("(",")"),
                          Fsz = 4.5,
                          label_height = .30,
                          label_width = 1.8,
                          name = paste0(output_dir, "/", .$site, 
                                         '_fr_covid_test_tube_labels_', 
                                         Sys.Date())))
                  
# create FreezerPro dataset
freezer_pro <- test_tube_label %>% 
  select(Description = barcode_label) %>%  
  add_column("Name" = "", "Volume" = "", "Sample" = "",
             "Type" = "", "Freezer" = "", "Level1" = "", "Level2" = "",
             "Level3" = "", "Level4" = "", "Level5" = "", "Box" = "",
             "Position" = "", "Vial" = "", "Label" = "", "Cap" = "",
             "Obtained" = "", "Date" = "")
write.csv(freezer_pro, paste0(output_dir, "/FreezerPro_",Sys.Date(), ".csv"),
          row.names = F)

# Zip the reports generated
zipfile_name = paste0("Reports_", output_dir, ".zip")
zip(zipfile_name, output_dir)


# attach the zip file and email it
attachment_object <- mime_part(zipfile_name, zipfile_name)
body <- paste0("The attached files include labels to be printed for the First Responder COVID-19 testing project.",
               "These labels are designed for the serum tubes and swab collection kits to be used at the collection sites.",
               "These labels should be printed and packaged with the serum and swab kits for their respective sites.",
               "The attached files were generated on ", Sys.Date(), "."
               )
body_with_attachment <- list(body, attachment_object)

# send the email with the attached output file
sendmail(from = email_from, to = email_to, cc = email_cc,
         subject = email_subject, body_with_attachment, 
         control = email_server)

