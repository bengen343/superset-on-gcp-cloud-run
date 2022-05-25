#!/bin/bash -xe

gcloud services enable compute.googleapis.com;
gcloud services enable secretmanager.googleapis.com;
gcloud services enable sqladmin.googleapis.com;
gcloud services enable artifactregistry.googleapis.com;
gcloud services enable cloudbuild.googleapis.com;
gcloud services enable run.googleapis.com;
