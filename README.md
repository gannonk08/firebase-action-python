# GitHub Actions for Firebase

This Action for [firebase-tools](https://github.com/firebase/firebase-tools) enables arbitrary actions with the 
`firebase` command-line client, it is a shameless fork of [firebase-action](https://github.com/w9jds/firebase-action) 
but with a python focus as I could not get that library to work properly to create a virtual environment.

## Inputs
* `args` - **Required**. This is the arguments you want to use for the `firebase` cli

## Environment variables

* `GCP_SA_KEY` - A **normal** service account key (json format) or a **base64 encoded** service account key with the needed permissions for what you are trying to deploy/update.
  * Since the service account is using the App Engine default service account in the deploy process, it also needs the `Service Account User` role.
  * If deploying functions, you would also need the `Cloud Functions Developer` role.
    * If the deploy has scheduled functions, include the `Cloud Scheduler Admin` role.
    * If the deploy requires access to secrets, include the `Secret Manager Viewer` role.
    * If updating Firestore Rules, include the `Firebase Rules Admin` role.
    * If the project is using Blocking functions (beforeCreate or beforeSignin) , include the `Firebase Functions Admin` role.
  * If updating Firestore Indexes, include the `Cloud Datastore Index Admin` role.
  * If deplying Hosting files, include the `Firebase Hosting Admin` role.
  * For more details: https://firebase.google.com/docs/hosting/github-integration

* `GOOGLE_APPLICATION_CREDENTIALS` - **Required if GCP_SA_KEY **. the location of a credential JSON file. For more details: https://cloud.google.com/docs/authentication/application-default-credentials#GAC

* `PROJECT_ID` - **Optional**. To specify a specific project to use for all commands. Not required if you specify a project in your `.firebaserc` file. If you use this, you need to give `Viewer` permission roles to your service account otherwise the action will fail with authentication errors.

* `PROJECT_PATH` - **Optional**. The path to where your requirements.txt should exist and where the python virtual environment will be created
* 
* `CREATE_VENV` - **Optional**. This determines whether to create the virtual environment based on the requirements.txt, you will need  

* `CONFIG_VALUES` - **Optional**. The configuration values for Firebase function that would normally be set with `firebase functions:config:set [value]`. Example: `CONFIG_VALUES: stripe.secret_key=SECRET_KEY zapier.secret_key=SECRET_KEY`.


## Example

To authenticate with Firebase, and deploy to a Firebase Function on merges/pushes to `main` branch:

```yaml
name: Build and Deploy
on:
  push:
    branches:
      - main

jobs:
  build:
    name: Build
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Repo
        uses: actions/checkout@master
      - name: Install Dependencies
        run: npm install
      - name: Build
        run: npm run build-prod
      - name: Archive Production Artifact
        uses: actions/upload-artifact@master
        with:
          name: dist
          path: dist
  deploy:
    name: Deploy
    needs: build
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Repo
        uses: actions/checkout@master
      - name: Deploy to Firebase
        uses: gannonk08/firebase-action-python@v0.0.1
        with:
          args: deploy --only functions --debug
        env:
          CREATE_VENV: true
          PROJECT_PATH: functions
          GCP_SA_KEY: ${{ secrets.FIREBASE_SERVICE_ACCOUNT_KEY }}
```

If you have multiple hosting environments you can specify which one in the args line.
e.g. `args: deploy --only hosting:[environment name]`

If you want to add a message to a deployment (e.g. the Git commit message) you need to take extra care and escape the quotes or the YAML breaks.

```yaml
        with:
          args: deploy --message \"${{ github.event.head_commit.message }}\"
```

## Alternate versions

The versioning of this project increments with `firebase-tools` starting at version `13.16.0`. The container is versioned
alongside in order to allow different version of `firebase-tools` to be used. You can also pull down the container locally
to modify and inspect it as needed. e.g.

```yaml
  name: Deploy to Firebase
  uses: docker://gannonk/firebase-action-python:master
  with:
    args: deploy --only functions --debug
  env:
    CREATE_VENV: true
    FIREBASE_TOKEN: ${{ secrets.FIREBASE_TOKEN }}

```

## License

The Dockerfile and associated scripts and documentation in this project are released under the [MIT License](LICENSE).


### Recommendation

If you decide to do separate jobs for build and deployment (which is probably advisable), then make sure to clone your
repo as the Firebase-cli requires the firebase repo to deploy (specifically the `firebase.json`)

### Limitations

I have only personally used this to deploy a firebase function. If there are issues deploying other python firebase
components feel free to submit an issue or create a pull request. 
