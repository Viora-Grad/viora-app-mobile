# Fastlane Setup

This directory contains the configuration for **Fastlane**, a tool used to automate common development tasks such as building and distributing mobile applications.

## What is Fastlane?

Fastlane helps automate processes like:

- Building the Android application
- Running predefined development tasks
- Preparing builds for distribution

It allows developers to define workflows called **lanes**, which are automated scripts that perform specific tasks.

## Project Structure

After initialization, Fastlane creates the following files:

```
fastlane/
 ├── Fastfile
 ├── Appfile
 └── README.md
```

**Appfile**

Contains basic configuration such as the Android package name.

**Fastfile**

Defines automation workflows (lanes). Each lane represents a task that can be executed from the command line.

## Running Fastlane

Navigate to the Android directory:

```
cd android
```

Run a lane:

```
fastlane <lane_name>
```

Fastlane will execute the commands defined inside the corresponding lane in the `Fastfile`.

## Purpose

Fastlane helps simplify repetitive tasks and ensures consistent build and deployment processes across development environments.
