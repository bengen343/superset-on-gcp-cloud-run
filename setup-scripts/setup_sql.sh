#!/bin/bash -xe

# Create the SQL instance
gcloud sql instances create $SQL_INSTANCE_NAME --database-version=POSTGRES_12 \
        --tier=db-g1-small \
        --region $GOOGLE_CLOUD_REGION;

# Create the Superset metadata SQL database
gcloud sql databases create $SQL_DATABASE -i $SQL_INSTANCE_NAME;

# Create the Superset user
gcloud sql users create $SQL_USER --password $SQL_PASSWORD -i  $SQL_INSTANCE_NAME;

