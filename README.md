 ![superset on google cloud run](https://cdn-images-1.medium.com/max/1600/1*dTCVCKQ90Jq7ye94R2LAiA.png)
# Deploying Apache Superset on Google Cloud Run
This repository is accompanied by a comprehensive guide with screenshots which you can [find on Medium](https://medium.com/@bengen/deploying-apache-superset-on-google-cloud-run).

## Introduction
In broad strokes, we will use this repository to:
* Set up Superset in a local VS Code development container.
* Rather than creating the Superset configuration database locally, we'll point our development container to the SQL database within Google Cloud Platform that we'll use to support the final deployment.
* Use our local deployment to configure the GCP SQL database.
* Once the Google Cloud database is configured we'll stage a container image in Google Artifact Registry.
* Create the Google Cloud Run service from the Artifact Registry Container.

This repository contains:
* ```.devcontainer```: folder containing the files that will create a VS Code development container.
* ```setup-scripts```: folder that contains a collection of shell scripts to set up and configure Google Cloud Platform (GCP) services. These scripts can be customized for your needs but they shouldn't require any customization as they rely on environment variables from the VS Code development container which you'll set in ```.env.template```.
* ```src```: folder that contains the files to build the Google Cloud Run Service.
* ```.env.template``` to allow you to set environment variables with the values for your deployment.

## Prerequisites
Performing the above steps will require:
1. [Docker Desktop](https://www.docker.com/)
2. [Visual Studio Code](https://code.visualstudio.com/)
    * The [Remote Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) extension
3. [Google Cloud CLI](https://cloud.google.com/sdk/docs/install)

It's very important that all of the shell commands/scripts outlined below be executed from the terminal inside the VS Code development container.

Install each of the above prerequisites in the order presented. Visual Studio Code, the Remote Containers extension, and the Google Cloud CLI are all easy to install. **Follow the Docker installation instructions explicitly!** Docker itself has a number of prerequisite steps. If you don't already have Docker installed be very mindful of the installation steps.

**If you encounter an error in the below steps it is likely because you didn't execute the prerequisite installation steps correctly.**

## Getting Started
1. Once you've completed the prerequisite installations, clone this repository to your machine. Do not rename the repository root folder from ```superset-on-gcp-cloud-run```.
2. Rename the file ```./.env.template``` to ```./.env``` and open this file in Notepad or another text editor. Keep it open until instructed to save and close it. We'll be populating some needed values in the next section.

## Configuring Google Cloud

### Project Creation
If you don't already have a Google Cloud project set up for this, you'll need to create one. So, take a jaunt over to the Google Cloud Platform web interface -- [Google Cloud Console](https://console.cloud.google.com/).

 Selecting or creating a project is easily done from the drop-down on the top-left next to the 'Google Cloud Platform' text. Once you've created your project make sure you're working in it by ensuring the correct project name appears next to the drop-down you just selected.

 ![google cloud console](https://cdn-images-1.medium.com/max/1600/1*Hwbi8LbCBWl2vueYFJZLUQ.png)

 Be sure to **enable billing** on the project that you've created. 
 1. Type 'Billing' in the top search bar and choose that option.
 2. You should be greeted by a notification saying that the project has no billing account. Choose **Link a Billing Account**.
 3. Choose (or create) your billing account. 

 Make sure the ```GOOGLE_CLOUD_PROJECT``` variable in ```./.env``` is set to match whatever you've chosen for your project name. Note that this value needs to be used in the ```SUPERSET_CONNECTION_NAME``` and ```SUPERSET_CONECTION_SECRET``` variables as well, so replace that portion of those strings as well now. 

### Configure Google Consent Screen
Our deployment is designed to allow any user from your Google-based organization to access Superset. In other words, if their email contains '@yourorganization.com' they'll be able to sign in. To do this we'll need to configure a few things in the Google Cloud Console before proceeding.
1. From Google Console Home type 'APIs & Services' and choose that section.
2. Choose 'OAuth Consent Screen' from the left-hand menu.
3. Select 'Internal' and click **Create**.
4. Set the below fields. All can be at your discretion but note that 'Authorized domains' will determine access so be sure that's your organization's correct, top-level domain.
    * App name
    * User support email
    * Authorized domains
    * Developer contact information
5. Click **Save and Continue**.
6. Click the **Add or Remove Scopes** button.
7. Select the _'openid'_ scope and click **Update**.
8. Click **Save and Continue**.
9. Click the **Back To Dashboard** button.

### Create credentials
1. Select **'Credentials'** from the left-hand menu of the 'APIs & Services' screen.
2. Click **'+Create Credentials'** > **'OAuth Client ID'**.
3. Set the **Application type** drop-down to 'Web application' and choose a 'Name' of your liking.
4. Click **Create**.
5. 'Your Client ID' and 'Your Client Secret' will be displayed in a pop-up. Note these values and copy them into their respective variables in the ```./.env``` file: ```GOOGLE_CLIENT_ID``` and ```GOOGLE_CLIENT_SECRET```. Be mindful of leading/trailing white space. It'd be wise to **Download JSON** as well. You shouldn't need it, but just in case.

## Environment Variables

Ensure that all of the variables in the ```./.env``` file accompanying this repository now have values assigned to them. Save and close the ```./.env``` file.

## Open the Local Development Container

1. Ensure that Docker is running and open on your machine and then open VS Code.
2.  Within VS Code select the **'Remote Explorer'** icon from the left navigation bar to open the 'Remote Containers' extension.
3. Choose the **'Open Folder in Container'** button and select the folder containing the entirety of this repository: ```superset-on-gcp-cloud-run```. This step can take 5-10 minutes while the dependencies download and the container is built. When the container is fully built the file tree should display in the left pane.
4. From the top VS Code menu choose **'Terminal'** > **'New Terminal'** to open a terminal pane.
5. Enter the command ```printenv``` in the terminal and press return. This will print a list of all the environment variables in your container. Scan through this to make sure those variables defined in ```./.env``` are displaying the correct values. If they aren't double-check that file, save it, and rebuild the container. You won't be able to proceed if there are inaccuracies.

 ![vs code controls](https://cdn-images-1.medium.com/max/1600/1*SxLBoZTiM6_ulzrAnXE4WA.png)

## Configure Google Cloud Platform Infrastructure

1. Log in to Google cloud via the terminal by entering the command ```gcloud auth login```. Because the container isn't connected to the outside world, it will generate a command that you'll need to copy into your Google Cloud SDK running outside the container. So, open the Google Cloud SDK Shell on your machine and paste in the command from the VS Code Terminal. This should open a browser window seeking your authorization to continue. Grant it access using your Google account of the same domain that you're deploying Superset on.
2. Copy and paste the results from the Google Cloud SDK back into the VS Code terminal. If successful you should get a message saying 'You are now logged in as...'
3. Switch to the Google Cloud Project you set up earlier by entering the command ```gcloud config set project $GOOGLE_CLOUD_PROJECT``` this will take advantage of the environment variable defining the name of your Google Cloud Project that you should have set earlier. If successful the terminal should return 'Updated property [core/project].'
4. Enable the various Google Cloud services we'll need within the project by typing ```setup-scripts/enable_gcp_services.sh``` into the VS Code terminal.

_Some users have reported getting a 'Permission denied' error when attempting to run these shell scripts. If that happens to you, simply give yourself permission to execute the script by typing ```chmod u+x setup-scripts/enable_gcp_services.sh``` for example. This will give you execute permission on the script you designate._

### Create the Superset Configuration SQL Database
1. Create the Superset SQL database in Google Cloud by running the ```setup_sql.sh``` script from this repository by typing ```setup-scripts/setup_sql.sh``` into the VS Code Terminal.

### Set Secrets & Service Accounts
Your Cloud Run service will pull secrets from GCP [Secret Manager](https://console.cloud.google.com/security/secret-manager). These secrets will all be created based on the values you set in the ```./.env``` file.
1.  Run the ```create_gcp_secrets.sh``` script by entering ```setup-scripts/create_gcp_secrets.sh``` into the VS Code terminal.
2. We'll also need to create a service account for Superset to use and grant it access to the secrets we just created as well as the various services we'll rely on. Run ```setup-scripts/create_gcp_service_account.sh``` in the VS Code terminal to create a service account named 'superset' in your project that can do this.

### Build Superset Configuration SQL Database
1. Connect the VS Code development container to the GCP database we created by running this command in the terminal: ```/cloud_sql_proxy -instances=$SUPERSET_CONNECTION_NAME=tcp:5432```. If it's successful you should see the number next to the 'PORTS' heading at the top of the terminal increase by one and a pop-up may display informing you that 'Your application is now running on port 5432'.
2. This proxy connection will monopolize the terminal window you were just working in. Open a new terminal window by clicking '**+**' on the top-right of the terminal window you were just working in. 
3. In the new terminal window you've just opened type ```superset db upgrade```. This may take some time to execute but this command is critical as it populates your Google Cloud hosted SQL database with all of the tables needed for Superset to run.


## Build & Deploy the Apache Superset Container

Next, we will push a Docker image to a Google Artifact Registry within the Google Cloud project. A Cloud Run service will then be created to deploy that image.
1. Create a Google Artifact Registry container by typing the command ```setup-scripts/create_gcp_artifact.sh``` into the VS Code terminal.
2. Upload the contents of this repository's ```src``` folder to the repository you just created as a Docker image by typing ```setup-scripts/create_gcp_image.sh``` into the VS Code terminal.
3. Turn the image you've uploaded into an active Google Cloud Run Service by typing the command ```setup-scripts/create_gcp_cloud_run.sh``` into the VS Code terminal

### Update Service Credential
After running the script above, you will receive a Google Cloud Run service URL.
1. Return to [Google Cloud Console](https://console.cloud.google.com/).
2. Search for and select **APIs & Services** in the top search bar.
3. Select **Credentials** from the left navigation bar.
4. Choose the **pencil icon** to edit your OAuth credential, and update the *Authorized redirect URIs* to ```<CLOUD-RUN-URL>/oauth-authorized/google```, replacing ```<CLOUD-RUN-URL>``` with the value the VS Code terminal returned. **Wait a few minutes before proceeding**.
5. Navigate to the Cloud Run service URL displayed by the VS Terminal (*without the extra text you added in Step 4.). This will authenticate you as an admin of the Superset deployment.

 Once you've done that, you will need to run the steps below to ensure future users are not granted admin access.

### Refresh Superset Roles
1. Update ```AUTH_USER_REGISTRATION_ROLE``` in ```superset_config.py``` to 'Public'. Save and close that file. All new accounts moving forward will default to Public and no longer Admin.
2. Update the container image by again typing ```setup-scripts/create_gcp_image.sh``` into the VS Code terminal.
3. Deploy your new container version by again typing ```setup-scripts/create_gcp_cloud_run.sh``` into the VS Code terminal.

### Initialize Superset
1. Make sure you're still connected via the Google cloud sql proxy and type ```superset init``` into the VS Code Terminal. This will take several minutes to complete.

## Congratulations
Everything should now be running successfully and you should be able to access your deployment by visiting the URL returned when running ```setup-scripts/create_gcp_cloud_run.sh```.
