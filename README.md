## Deploying Apache Superset on Google Cloud Run
In broad strokes we will:
* Set up Superset in a local development container.
* Rather than creating the metadata database locally, we'll point our development container to the SQL database within Google Cloud that we'll use to support the final deployment.
* Use our local deployment to configure the GCP SQL database.
* Once the Google Cloud database is configured we'll stage a container in Google Artifact Registry.
* Create the Google Cloud Run service from the Artifact Registry Container.

## Setup
Performing the above steps will require a machine running [Docker](https://www.docker.com/), and utilizing [Visual Studio Code](https://code.visualstudio.com/) and its [Remote Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) extension, and the [Google Cloud CLI](https://cloud.google.com/sdk/docs/install). It's very important that all of the shell commands/scripts outlined below be executed from the terminal inside the VS Code development container.

If you don't have it already, installing Visual Studio Code and the Remote Containers extension is pretty easy. And Docker has comprehensive setup instructions on their website. Be sure both of these are running on your machine before continuing.

## Configuring Google Cloud

### Project Creation
If you don't already have a Google Cloud project set up for this, you'll need to create one. So, to begin with take a jaunt over there: [Google Cloud Console](https://console.cloud.google.com/). Selecting or creating a project is easily done from the drop-down on the top-left next to the 'Google Cloud Platform' text. Once you have your project make sure you're working in the correct project by ensuring the name appears next to the drop-down you just selected.

### Configure Google Consent Screen
Our deployment is designed to allow any user from your Google-based organization to access Superset. In otherwords, if their email contains '@yourorganization.com' they'll be able to sign in. To do this we'll need to configure a few things in the Google Cloud Console before proceeding.
1. From Google Console Home type 'APIs & Services' and choose that section.
2. Choose 'OAuth Consent Screen' from the left-hand menu.
2. Select 'Internal' and click **Create**.
3. Set the following:
    * App name
    * User support email
    * Authorized domains
    * Developer contact information
4. Click **Save and Continue**.
5. Click the **Add or Remove Scopes** button.
6. Select the '*.../auth/userinfo.email*' and '*.../auth/userinfo.profile*' scopes and click **Update**.
7. Click **Save and Continue**.
8. Click the **Back To Dashboard** button.

### Create credentials

1. Select 'Credentials' from the left-hand menu of the 'APIs & Services' screen.
2. Click **+Create Credentials** > 'OAuth Client ID'.
3. Set the **Application type** drop-down to 'Web application'
4. Click **Create**.
4. 'Your Client ID' and 'Your Client Secret' will be displayed in a pop-up. Note these values and copy them into the '.env' file in this repository as the values for their respective environment variables.

### Environment Variables
Ensure that all of the variables provided in this .env file accompanying this repository have values assigned to them. Those that need to be set by you have been left blank. Those with recommended values are pre-populated.

### Create Metadata SQL Database
1. Ensure that Docker is running on your machine and open VS Code.
1.  Within VS Code select the 'Remote Explorer' icon from the left navigation bar to open the 'Remote Containers' extension.
3. Choose the 'Open Folder in Container' button and select the folder containing the entirety of this repositoy. This step can take a few minutes.
4. From the top VS Code menu choose 'Terminal' > 'New Terminal' to open a terminal pane.
5. Login to Google cloud via the terminal by entering the command 'gcloud auth login'. Because the container isn't connected to the outside world it will generate a command that you'll need to copy into your Google Cloud SDK running outside the container. So, open the Google Cloud SDK shell on your machine, paste in the command from the VS Code Terminal.
6. Copy and paste the results from the Google Cloud SDK back into the VS Code terminal. If successful you should get a message saying 'Your are now logged in as...'
7. Switch to the Google Cloud Project you setup earlier by entering typing in the command 'gcloud config set project $GOOGLE_CLOUD_PROJECT' this will take advantage of the environment variable defining the name of your Google Cloud Project that you should have set earlier. 
8. Create the Superset SQL database in Google Cloud by running the 'setup_sql.sh' script from this repository by typing 'setup-scripts/setup_sql.sh' into the VS Code Terminal.

## Secrets
Your Cloud Run service will pull secrets from Google's Secret Manager and mount them as environment variables in the containers. Navigate to [Secret Manager](https://console.cloud.google.com/security/secret-manager) under the *IAM & Admin* menu.
1.  Run the 'create_gcp_secrets.sh' script by entering 'setup-scripts/create_gcp_secrets.sh' into the VS Code terminal


3. Edit the ./.env file with notepad (or whatever) to reflect your configuration. Hopefully, most of this is self explanatory but a few notes to pay attention to.
     * '**SUPERSET_SECRET_KEY**': this shoud be any long string that will be used to seed the encryption used by SuperSet.
     * '**SUPERSET_CONNECTION_STRING**': replace 'PASSWORD' in this string with the password you'll be using for the GCP SQL database. Don't change anything else. We'll use a proxy to reach the SQL server so you should leave the address as 'localhost'. Enter your password for '**SQL_PASSWORD**' as well.
     * '**GOOGLE_CLOUD_REGION**' this can be a region of your choosing. Generally wise to choose one that's near your users or also containing your other resources.
    </br></br>
4. Within VS Code select the Remote Containers extension icon on the left bar, choose 'Open Folder in Container' and choose the parent folder for this repository, 'superset-on-gcp-cloud-run' unless you've renamed it. VS Code will construct the container based on the contents of this repos '.devcontainer' folder.

1.5 If you don't already have a project setup in Google Cloud Platform you can create one from the command line with:
```Bash
gcloud projects create gcp-superset-3437 --name="gcp-superset-3437"
```
I usually choose to make the project name the same as the ID but this isn't necessary. You can choose anything you like to replace 'gcp-superset-3437'. It's considered good practice to append random digits to your chosen name.


### Build Superset Metadata Data Base
1. Connect the VS Code development container to the GCP database we created by running this commnad in the terminal:'
/cloud_sql_proxy -instances=$SUPERSET_CONNECTION_NAME=tcp:5432;'
2. This proxy connection will monopolize the terminal window you were just working in. Open a new terminal window by clicking '+' on the top-right of the terminal window you were just working in. 

# initialize superset database
1. In the new terminal window you've just opened type 'superset db upgrade'. This may take some time to execute but this command is critical as it populates your Google Cloud hosted SQL database with all of the tables needed for Superset to run.


## Cloud Run
The commands below will push a Docker image to a Google Artifact Registry within the Google Cloud project. A Cloud Run service will them be created to deploy that image.

1. Create a Google Artifact Registry container by typing the command 'setup-scripts/create_gcp_artifact.sh' into the VS Code terminal.
2. Upload the contents of this repository's 'src' folder to the repository you just created as a Docker image by typing 'setup-scripts/create_gcp_image.sh' into the VS Code terminal
3. Turn the image you've uploaded into an active Google Cloud Run Service by typing the command 'setup-scripts/create_gcp_cloud_run.sh' into the VS Code terminal

## Update service credential
After running the `gcloud run` command above, you will recieve a Google Cloud Run service URL. Head back to APIs & Services > Credentials on the left, edit your OAUTH credential, and update the *Authorized redirect URI* to *`<CLOUD-RUN-URL>`/oauth-authorized/google*

Navigate to your Cloud Run service URL. This will authenticate you as an admin of the Superset deployment. Once you've done that, you will need to run the steps below to lock down the deployment.

## Refresh Superset roles
Update `AUTH_USER_REGISTRATION_ROLE` in `superset_config.py` to "Public". All new accounts moving forward will default to Public and no longer Admin. 


# create roles and grant permissions
superset init;

2. Upload the contents of this repository's 'src' folder to the repository you just created as a Docker image by typing 'setup-scripts/create_gcp_image.sh' into the VS Code terminal
3. Turn the image you've uploaded into an active Google Cloud Run Service by typing the command 'setup-scripts/create_gcp_cloud_run.sh' into the VS Code terminal

