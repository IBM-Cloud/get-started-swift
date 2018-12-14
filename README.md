[![Build Status - Master](https://travis-ci.org/IBM-Cloud/get-started-swift.svg?branch=master)](https://travis-ci.org/IBM-Cloud/get-started-swift)
![macOS](https://img.shields.io/badge/os-macOS-green.svg?style=flat)
![Linux](https://img.shields.io/badge/os-linux-green.svg?style=flat)

# Getting started with Swift on IBM Cloud
The Getting Started tutorial for Swift uses this sample application to provide you with a sample workflow for working with any Swift app; you set up a development environment, deploy an app locally and on the cloud, and then integrate an IBM Cloud database service in your app.

The Swift app uses the [Kitura Web Framework](http://www.kitura.io/) and a [Cloudant NoSQL DB](https://cloud.ibm.com/catalog/services/cloudant) to illustrate how to store information in a database and then return information from a database to the UI. To learn more about how the app connects to Cloudant, see the [Kitura CouchDB Library](https://github.com/IBM-Swift/Kitura-CouchDB).

<p align="center">
  <kbd>
    <img src="docs/GettingStarted.gif" width="300" style="1px solid" alt="Gif of the sample app contains a title that says, Welcome, a prompt asking the user to enter their name, and a list of the database contents which are the names Joe, Jane, and Bob. The user enters the name, Mary and the screen refreshes to display, Hello, Mary, I've added you to the database. The database contents listed are now Mary, Joe, Jane, and Bob.">
  </kbd>
</p>

The following steps are the general procedure to set up and deploy your app to IBM Cloud. See more detailed instructions in the [Getting started tutorial for Swift](https://cloud.ibm.com/docs/runtimes/swift/getting-started.html#getting-started-tutorial).

## Before you begin

You'll need a [IBM Cloud account](https://cloud.ibm.com/), [Git](https://git-scm.com/downloads), [IBM Cloud CLI](https://cloud.ibm.com/docs/cli/index.html#overview), and [Swift](https://swift.org/download/) installed.
