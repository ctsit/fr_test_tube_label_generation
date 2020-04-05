#!/bin/sh
## PROJECT METADATA
# DATA="token=<API_TOKEN>&content=project&format=json&returnFormat=json"
# CURL=`which curl`
# $CURL -H "Content-Type: application/x-www-form-urlencoded" \
#       -H "Accept: application/json" \
#       -X POST \
#       -d $DATA \
#       https://redcap.ctsi.ufl.edu/redcap/api/


## ALL RECORDS
DATA="token=<API_TOKEN>&content=record&format=json&type=flat&rawOrLabel=raw&rawOrLabelHeaders=raw&exportCheckboxLabel=false&exportSurveyFields=false&exportDataAccessGroups=false&returnFormat=json"
CURL=`which curl`
$CURL -H "Content-Type: application/x-www-form-urlencoded" \
      -H "Accept: application/json" \
      -X POST \
      -d $DATA \
      https://redcap.ctsi.ufl.edu/redcap/api/
