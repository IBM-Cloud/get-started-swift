[![Build Status - Master](https://travis-ci.org/IBM-Cloud/get-started-swift.svg?branch=master)](https://travis-ci.org/IBM-Cloud/get-started-swift)
![macOS](https://img.shields.io/badge/os-macOS-green.svg?style=flat)
![Linux](https://img.shields.io/badge/os-linux-green.svg?style=flat)

# Getting started with Swift on IBM Cloud
The Getting Started tutorial for Swift uses this sample application to provide you with a sample workflow for working with any Swift app; you set up a development environment, deploy an app locally and on the cloud, and then integrate an IBM Cloud database service in your app.

The *estado* branch is meant to for ICp testing. It contains 0 dependencies, while retaining most of the functionality of the full api

### API

#### GET /api/visitors

Returns all visitors.

#### GET /database

Responds with the current storage type

#### POST /api/visitors

Accepts json payloads of the form {"name": "your-name-here"}

##### Response
- Cloudant Bound : "Hello \(name)! You've been added to the cloudant database."
- Unbound        : "Hello \(name)! You've been added to the local store."
