#!/bin/bash -xe

# Create the service account
gcloud iam service-accounts create superset;

# add various IAM roles to the service account
gcloud projects add-iam-policy-binding $GOOGLE_CLOUD_PROJECT \
    --member="serviceAccount:superset@$GOOGLE_CLOUD_PROJECT.iam.gserviceaccount.com" \
    --role=roles/cloudsql.client;

gcloud projects add-iam-policy-binding $GOOGLE_CLOUD_PROJECT \
    --member="serviceAccount:superset@$GOOGLE_CLOUD_PROJECT.iam.gserviceaccount.com" \
    --role=roles/bigquery.jobUser;

gcloud projects add-iam-policy-binding $GOOGLE_CLOUD_PROJECT \
    --member="serviceAccount:superset@$GOOGLE_CLOUD_PROJECT.iam.gserviceaccount.com" \
    --role=roles/bigquery.dataViewer;

# Give the new service account access to Google Secret Manager secrets
gcloud secrets add-iam-policy-binding projects/$GOOGLE_CLOUD_PROJECT/secrets/superset-connection-string \
    --member serviceAccount:superset@$GOOGLE_CLOUD_PROJECT.iam.gserviceaccount.com \
    --role roles/secretmanager.secretAccessor;

gcloud secrets add-iam-policy-binding projects/$GOOGLE_CLOUD_PROJECT/secrets/superset-secret-key \
    --member serviceAccount:superset@$GOOGLE_CLOUD_PROJECT.iam.gserviceaccount.com \
    --role roles/secretmanager.secretAccessor;

gcloud secrets add-iam-policy-binding projects/$GOOGLE_CLOUD_PROJECT/secrets/google-client-id \
    --member serviceAccount:superset@$GOOGLE_CLOUD_PROJECT.iam.gserviceaccount.com \
    --role roles/secretmanager.secretAccessor;

gcloud secrets add-iam-policy-binding projects/$GOOGLE_CLOUD_PROJECT/secrets/google-client-secret \
    --member serviceAccount:superset@$GOOGLE_CLOUD_PROJECT.iam.gserviceaccount.com \
    --role roles/secretmanager.secretAccessor;
