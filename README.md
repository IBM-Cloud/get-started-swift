[![Build Status - Master](https://travis-ci.org/IBM-Cloud/get-started-swift.svg?branch=master)](https://travis-ci.org/IBM-Cloud/get-started-swift)
![macOS](https://img.shields.io/badge/os-macOS-green.svg?style=flat)
![Linux](https://img.shields.io/badge/os-linux-green.svg?style=flat)

# Getting started with Swift on IBM Cloud
The Getting Started tutorial for Swift uses this sample application to provide you with a sample workflow for working with any Swift app; you set up a development environment, deploy an app locally and on the cloud, and then integrate an IBM Cloud database service in your app.

The Swift app uses the [Kitura CouchDB package](https://github.com/IBM-Swift/Kitura-CouchDB) to interact with the [Cloudant Java Client](https://github.com/cloudant/java-cloudant) to add information to a database and then return information from a database to the UI.

<p align="center">
  <kbd>
    <img src="docs/GettingStarted.gif" width="300" style="1px solid" alt="Gif of the sample app contains a title that says, Welcome, a prompt asking the user to enter their name, and a list of the database contents which are the names Joe, Jane, and Bob. The user enters the name, Mary and the screen refreshes to display, Hello, Mary, I've added you to the database. The database contents listed are now Mary, Joe, Jane, and Bob.">
  </kbd>
</p>

The following steps are the general procedure to set up and deploy your app to IBM Cloud. See more detailed instructions in the [Getting started tutorial for Swift](https://console.bluemix.net/docs/runtimes/swift/getting-started.html#getting-started-tutorial).

## Before you begin

You'll need a [IBM Cloud account](https://console.ng.bluemix.net/registration/), [Git](https://git-scm.com/downloads), [Cloud Foundry CLI](https://github.com/cloudfoundry/cli#downloads), and [Swift](https://swift.org/download/) installed.
