import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:async';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart' as firebase_ui_auth;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../utilities/constants.dart';
import 'widgets/dialog_buildler.dart';
import 'widgets/sign_in_with_mobile.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _phoneInputKey = GlobalKey<firebase_ui_auth.PhoneInputState>();
  final _smsCodeInputKey = GlobalKey<firebase_ui_auth.SMSCodeInputState>();

  @override
  void initState() {
    super.initState();

    // Logout the Firebase user
    FirebaseAuth.instance.signOut();
  }

  /// Sign In with Google
  ///
  /// Currently not configured for this example app.
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      print('signInWithGoogle | ${e.message} (${e.code})');
    } catch (e) {
      print('signInWithGoogle | Failed: ${e.toString()}');
    }

    return null;
  }

  /// Generate Nonce
  ///
  /// Generates a cryptographically secure random nonce, to be included in a credential request.
  String generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Sign In with Apple
  ///
  /// Currently not configured for this example app.
  Future<UserCredential?> signInWithApple() async {
    try {
      // To prevent replay attacks with the credential returned from Apple, we
      // include a nonce in the credential request. When signing in with
      // Firebase, the nonce in the id token returned by Apple, is expected to
      // match the sha256 hash of `rawNonce`.
      final rawNonce = generateNonce();
      final nonce = sha256ofString(rawNonce);

      // Request credential for the currently signed in Apple account.
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      // Create an `OAuthCredential` from the credential returned by Apple.
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      print('signInWithApple | Success');

      // Sign in the user with Firebase. If the nonce we generated earlier does
      // not match the nonce in `appleCredential.identityToken`, sign in will fail.
      return await FirebaseAuth.instance.signInWithCredential(oauthCredential);
    } on FirebaseAuthException catch (e) {
      print('signInWithApple | ${e.message} (${e.code})');
    } catch (e) {
      print('signInWithApple | Failed ${e.toString()}');
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          // Dismiss the keyboard when clicking the background
          return FocusManager.instance.primaryFocus?.unfocus();
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                color: Theme.of(context).colorScheme.primary,
                alignment: Alignment.center,
                // height: 30.h,
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: kSpacer * 12,
                    right: kSpacer * 8,
                    bottom: kSpacer * 8,
                    left: kSpacer * 8,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Firebase UI',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: kSpacer * 4,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Auth Example',
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: kSpacer * 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(kSpacer * 3),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      constraints: const BoxConstraints(
                        minHeight: kSpacer * 23,
                      ),
                      child: SignInWithMobile(
                        phoneInputKey: _phoneInputKey,
                        smsCodeInputKey: _smsCodeInputKey,
                      ),
                    ),
                    const SizedBox(height: kSpacer * 2),
                    Container(
                      height: kSpacer * 2,
                      color: Theme.of(context).colorScheme.background,
                      child: Stack(
                        alignment: AlignmentDirectional.center,
                        children: [
                          Container(
                            height: 1.0,
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                          Container(
                            width: kSpacer * 4,
                            color: Theme.of(context).colorScheme.background,
                            child: Text(
                              'or',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: kSpacer * 2),
                    OutlinedButton(
                      onPressed: () async {
                        dialogBuilder(context,
                            'Sign In with Google is not configured for this example app.');
                        // signInWithGoogle().then((userCredential) {
                        //   if (userCredential != null) {
                        //     // TODO: route to home screen
                        //     _dialogBuilder(context, 'Login successful');
                        //   }
                        // });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/logos/google_sign_in.png',
                            height: kSpacer * 3,
                          ),
                          const SizedBox(width: kSpacer),
                          Text(
                            'Sign In with Google',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: kSpacer * 2),
                    Platform.isIOS
                        ? OutlinedButton(
                            onPressed: () async {
                              dialogBuilder(context,
                                  'Sign In with Apple is not configured for this example app.');
                              // signInWithApple().then((userCredential) {
                              //   if (userCredential != null) {
                              //     // TODO: route to home screen
                              //     _dialogBuilder(context, 'Login successful');
                              //   }
                              // });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/logos/apple_sign_in.png',
                                  height: kSpacer * 3,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground,
                                ),
                                const SizedBox(width: kSpacer),
                                Text(
                                  'Sign In with Apple',
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                              ],
                            ),
                          )
                        : Container(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
