# todoapp

A small, online only (powered by Firebase) Todo app written in dart/flutter.

## Getting Started

### Firebase
- When cloning the project Firebase will still need to be set up, follow instructions [here](https://firebase.google.com/docs/flutter/setup), note that you only need to do steps 1 and 2.
- I've set the database rules as follows:
```
{
  "rules": {
    "items": {
      ".read": "auth !== null",
      ".write": "auth !== null",
       "$uid": {
        ".read": "auth !== null && (auth.uid === $uid || $uid === 'sharedItems')",
        ".write": "auth !== null && (auth.uid === $uid || $uid === 'sharedItems')"
      }
    }
  }
}
```
- This ensures only authenticated users can read and write from/to items and from/to sharedItems, while only the corresponding user can read/write from/to their private items.
- In the Firebase console, under *Authentication*  *Sign-in method*, set up the *Email/password* provider.

In the future we will improve authentication:
- stay logged in over different app launches
- Potentially use Google Auth

As of writing this, only the following platforms are supported by Firebase:
- Android
- iOS
- MacOS (beta)
- Web

Keep this in mind.
