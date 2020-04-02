library(dplyr)
library(sendmailR)
library(dotenv)

# email credentials
email_server <- list(smtpServer = Sys.getenv("SMTP_SERVER"))
email_from <- Sys.getenv("EMAIL_FROM")
email_to <- unlist(strsplit(Sys.getenv("EMAIL_TO")," "))
email_cc <- unlist(strsplit(Sys.getenv("EMAIL_CC")," "))
email_subject <- Sys.getenv("EMAIL_SUBJECT")

# will update to read data directly using api
test_tube_label <- read.csv("TesttubeLabels_DATA_2020-04-02_1340.csv") %>% 
  slice(rep(1:n(), each = 4))

# create output file
file_name <- paste0("test_tube_labels_", Sys.Date(), ".csv")
write.csv(test_tube_label, file_name, row.names = F, na = "")

# read in the output file and attach it to email
attachment_object <- mime_part(file_name, file_name)
body <- paste0("The attached file includes the labels to be printed.",
               "File generated on ", Sys.time())
body_with_attachment <- list(body, attachment_object)

# send the email with the attached output file
sendmail(from = email_from, to = email_to, cc = email_cc,
         subject = email_subject, body_with_attachment, 
         control = email_server)

# delete the output file
unlink(file_name)


# library(RCurl)
# result <- postForm(	
#   uri = 'https://redcap-warrior.ctsi.ufl.edu/prod/api/',	
#   token = Sys.getenv("API_TOKEN"),	
#   content = 'report',	
#   format = 'csv',
#   rawOrLabel = 'raw',	
#   rawOrLabelHeaders = 'raw',	
#   returnFormat = 'csv'	
# )
# 
# df <- read.csv(textConnection(result)) 

