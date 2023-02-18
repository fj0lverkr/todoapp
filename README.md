# todoapp

A small, online only (powered by Firebase) Todo app written in dart/flutter.

## Getting Started

### Firebase
When cloning the project Firebase will still need to be set up, follow instructions [here](https://firebase.google.com/docs/flutter/setup), note that you only need to do steps 1 and 2.

For authentication to work, check /lib/model/secret_template.dart for instructions.

In the future we will improve authentication:
- Use Google Auth
- Have a shared list of items as well as private ones
- provide user registration and login options

As of writing this, only the following platforms are supported by Firebase:
- Android
- iOS
- MacOS (beta)
- Web

Keep this in mind.
