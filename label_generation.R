library(tidyverse)
library(sendmailR)
library(dotenv)
library(REDCapR)
library(baRcodeR)

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
  mutate(subject_id = paste(frcovid_fn, frcovid_ln, frcovid_dob, sep = " ")) 

# date and 24hr time
time <- format(Sys.time(), "%Y-%m-%d_%H%M")

# output file name
file_name <- paste0('fr_covid_test_tube_labels_', time)

# create pdf containing test tube labels
# barcode created from fn ln dob
custom_create_PDF(user=FALSE, Labels = test_tube_label[,7], 
                  name = file_name, 
                  type = 'linear', Fsz = 5, Across = TRUE, 
                  trunc = FALSE, numrow = 20, 
                  numcol = 4, page_width = 8.5, page_height = 11, 
                  width_margin = 0.25, height_margin = 0.5)

# read in the output file and attach it to email
pdf_file_name <- paste0(file_name, ".pdf")
attachment_object <- mime_part(pdf_file_name, pdf_file_name)
body <- paste0("The attached files include labels to be printed for the First Responder COVID-19 testing project.",
               "These labels are designed for the serum tubes and swab collection kits to be used at the collection sites.",
               "These labels should be printed and packaged with the serum and swab kits for their respective sites.",
               "The attached files were generated on ", Sys.time(), "."
               )
body_with_attachment <- list(body, attachment_object)

# send the email with the attached output file
sendmail(from = email_from, to = email_to, cc = email_cc,
         subject = email_subject, body_with_attachment, 
         control = email_server)

# delete the output file
unlink(pdf_file_name)
