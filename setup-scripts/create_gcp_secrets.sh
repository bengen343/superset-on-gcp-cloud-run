#!/bin/bash -xe

printf $SUPERSET_CONNECTION_SECRET | gcloud secrets create superset-connection-string --data-file=- \
    --replication-policy=user-managed \
    --locations=$GOOGLE_CLOUD_REGION;

printf $SUPERSET_SECRET_KEY | gcloud secrets create superset-secret-key --data-file=- \
    --replication-policy=user-managed \
    --locations=$GOOGLE_CLOUD_REGION;

printf $GOOGLE_CLIENT_ID | gcloud secrets create google-client-id --data-file=- \
    --replication-policy=user-managed \
    --locations=$GOOGLE_CLOUD_REGION;

printf $GOOGLE_CLIENT_SECRET | gcloud secrets create google-client-secret --data-file=- \
    --replication-policy=user-managed \
    --locations=$GOOGLE_CLOUD_REGION;