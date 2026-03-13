# EventFlow

## Project Overview

EventFlow is a mobile application designed to simplify the process of discovering, organising, and attending social events. The platform allows users to host parties, discover venues and DJs, invite friends, and manage events through a single mobile interface.

The goal of the application is to centralise event planning and make it easier for users to organise social gatherings while providing hosts with tools to manage invitations and event visibility (public or private).

The project is being developed as part of the **IT Professional Skills module** and focuses on building a full-stack mobile application using modern development technologies.

---

## Project Idea

During the initial project planning phase, the team discussed several potential application ideas. Some of the concepts considered included:

* 3D printer improvement system
* Outfit visualisation app
* Receipt management application
* Eye-tracking shooting game
* Social party planning platform

After evaluating the feasibility and potential value of each idea, the team selected the **Party App** concept.

The selected idea provides users with a platform to:

* Host parties or events
* Discover venues and DJs
* Invite friends to events
* Set events as public or private
* Manage event participation
* An Interactive Map

---

## System Architecture

The system architecture was designed and agreed upon during the **project inception phase**.

A **layered architecture** was chosen to clearly separate the different components of the application. This approach improves maintainability, scalability, and organisation of the codebase.

The architecture consists of the following layers:

1. **Mobile Application Layer**

   * User interface developed using Flutter
   * Handles user interaction and presentation

2. **Application Logic Layer**

   * Backend services responsible for authentication, event management, and business logic

3. **Data Layer**

   * Database responsible for storing users, events, and related data

4. **External Services Layer**

   * Communication between the mobile application and backend via REST APIs

---

## Technology Stack

The application is built using a modern full-stack development stack.

**Frontend**

* Flutter (Dart)
* Cross-platform mobile development for Android and iOS

**Backend**

* Node.js
* Express.js

**Database**

* MongoDB Atlas (Cloud database)

**Communication**

* REST API using HTTP requests

---

## Key Features

* User registration and login
* User profile management
* Event creation and management
* Public and private event visibility
* Friend invitations
* Venue and DJ booking support
* Event discovery
* Interactive map

---

## Project Structure

```
QT-EO-RO-AJ-Project
│
├── frontend
│   └── Flutter mobile application
│
├── backend
│   └── Node.js + Express API
│
└── README.md
```

---

## Development Approach

The project follows a collaborative development approach where responsibilities are shared across the team. The system architecture, technology stack, and feature roadmap were defined during the early planning stages to ensure alignment across all contributors.

The application is currently under active development as part of the course project.
