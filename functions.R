get_test_tube_label <- function(){

  records <- redcap_read_oneshot(redcap_uri = 'https://redcap.ctsi.ufl.edu/redcap/api/',
                                 token = Sys.getenv("API_TOKEN"))$data

  baseline_records <- records %>%
    filter(redcap_event_name == 'baseline_arm_1' & !is.na(ce_firstname)) %>%
    select(record_id, ce_firstname, ce_lastname, patient_dob) %>%
    mutate(ce_firstname = str_to_title(ce_firstname),
           ce_lastname = str_to_title(ce_lastname),
           subject_id = paste(ce_firstname, ce_lastname,"\n", patient_dob))

  test_tube_label <- records %>%
    select(research_encounter_id, record_id, redcap_event_name,
           site_short_name, site_long_name, test_date_and_time) %>%
    filter(as_date(test_date_and_time) == appt_date) %>%
    left_join(baseline_records, by = "record_id") %>%
    arrange(site_short_name, test_date_and_time)

return(test_tube_label)

}

# add sitname and appt date at specified position
add_new_row <- function(per_site_df, ...){
  add_row(per_site_df,
          subject_id = paste("Appt Date:", appt_date),
          research_encounter_id = unique(per_site_df$site_short_name),
          site_short_name = unique(per_site_df$site_short_name),
          ...)
}
