# create artifact registry repository
gcloud artifacts repositories create superset-repository \
    --project=$GOOGLE_CLOUD_PROJECT \
    --repository-format=docker \
    --location=$GOOGLE_CLOUD_REGION \
    --description="Apache Superset Docker repository";
