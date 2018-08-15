## Connecting to a MongoDB Database

You'll need access to a MongoDB instance. The below steps outline how to do this:

1. Sign in to your IBM Cloud Console, and select the 'Create Resource' button in the top right of the page.
2. Type 'MongoDB' in the search field and select 'Compose for MongoDB' under the 'Data & Analytics' section.
3. Check that the name/region/organization/space/pricing fields are accurate.
4. Select the 'Create' button in the bottom left of the page.
5. Return to the IBM Cloud dashboard and select the newly created service.
6. In the sidebar on the left side of the page, select 'Service Credentials'
7. Select the 'New Credential' button, and then the 'Add' button in the page that appears.

To prepare the application for use in a local environment, use the below steps. Otherwise, skip the steps to move on to deploying the application to IBM Cloud:

1. Make a copy of the 'my-mongo-credentials.json.example' file (remove the '.example' extension) in the 'config' directory.
2. Copy the contents of the 'uri' field in the credentials generated from earlier into the field (replacing "<uri>").
3. Run the application using the '.build/debug/get-started-swift' command from the root directory of the repository.

Before deploying the application, make sure that it builds successfully by running `swift build` and `.build/debug/get-started-swift` from the root directory of the project (where this README document is located). If no errors are shown, run `cf push` to deploy the applciation. Once the deployment process completes, run `cf bind-service Get-Started-Swift [SERVICE_NAME]`, where [SERVICE_NAME] is the name of your MongoDB service. Finally, run `cf restage Get-Started-Swift`. Once this finishes, you can access the application using the URL provided in the output from the `cf push` command from earlier.

## Additional Notes on Changes

The application may work with either Cloudant or MongoDB. However, if both services are available, **the application will default to MongoDB**.

When deployed on IBM Cloud, this application **does not** require bound MongoDB services to have some permutation of 'mongodb' in the name. User-provided services (as created with the cf utility) are also acceptable.

## For Mac OS Users

The MongoDB drivers will use Apple Secure Transport on Mac OS systems (rather than OpenSSL on Linux), and may not be able to connect to the database service. The below steps can be used to resolve this:

1. Create a new file 'mongo.crt' and open it in a text editor.
2. Add the following to the first line of the file: "-----BEGIN CERTIFICATE-----".
3. Paste the contents of the 'ca_certificate_base64' field from the credentials you generated earlier.
4. Add the following to the last line of the file: "-----END CERTIFICATE-----".
5. Open the "Keychain Access" app (in the 'Applications/Utilities' directory)
6. Select "File"->"Import Items" and browse for the 'mongo.crt' file.
7. Find the imported certificate in the main window (the icon may have a red 'X' on it).
8. Right click on the certificate and select 'Get Info'.
9. In the new window, expand the 'Trust' section.
10. In the dropdown menu next to 'When using this certificate," select 'Always Trust' and close the window.
11. After the application is restarted, it should be able to connect to the database.
