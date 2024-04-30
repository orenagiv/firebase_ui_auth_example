# Firebase UI Auth Example
This is a simple Flutter app which demonstrates the usage of the Fireabse UI Auth package for the purpose of this pull request:  
https://github.com/firebase/FirebaseUI-Flutter/pull/334  

As per the PR, please note this example app uses a dependency override of the flutter_ui_auth package:  
https://github.com/orenagiv/FirebaseUI-Flutter.git  

## Getting Started
Run the app and test Sign In with Mobile (OTP) flow using the following phone number:
```
+1 650-555-1234
```
And the following verification code:
```
123456
```

Please note the app only demonstrates the phone-number (OTP) flow.
The "Sign in with Google" and "Sign in with Apple" buttons are not configured, since they are not related to the Pull Request changes.

The relevant Widget which demonstrates the usage of the Firebase UI Auth flow is:  
```
widgets/sign_in_with_mobile.dart
```
