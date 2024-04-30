import 'package:firebase_ui_auth/firebase_ui_auth.dart' as firebase_ui_auth;
import 'package:flutter/material.dart';

import '../utilities/constants.dart';
import 'dialog_buildler.dart';

class SignInWithMobile extends StatelessWidget {
  const SignInWithMobile({
    super.key,
    required GlobalKey<firebase_ui_auth.PhoneInputState> phoneInputKey,
    required GlobalKey<firebase_ui_auth.SMSCodeInputState> smsCodeInputKey,
  })  : _phoneInputKey = phoneInputKey,
        _smsCodeInputKey = smsCodeInputKey;

  final GlobalKey<firebase_ui_auth.PhoneInputState> _phoneInputKey;
  final GlobalKey<firebase_ui_auth.SMSCodeInputState> _smsCodeInputKey;

  @override
  Widget build(BuildContext context) {
    return firebase_ui_auth.AuthFlowBuilder<
        firebase_ui_auth.PhoneAuthController>(
      listener: (oldState, newState, controller) async {
        if (newState is firebase_ui_auth.PhoneVerified ||
            newState is firebase_ui_auth.UserCreated ||
            newState is firebase_ui_auth.SignedIn) {
          if (context.mounted) {
            print(
                'Login Screen | SignInWithMobile - PhoneAuthController listener state: ${newState.toString()} - redirecting to Home');

            // TODO: route to the home screen
            dialogBuilder(context, 'Login successful');
          }
        }
      },
      builder: (context, state, ctrl, child) {
        if (state is firebase_ui_auth.AwaitingPhoneNumber) {
          return Column(
            children: [
              firebase_ui_auth.PhoneInput(
                key: _phoneInputKey,
                initialCountryCode: 'US',
                autofocus: false,
                onSubmit: (phoneNumber) {
                  ctrl.acceptPhoneNumber(phoneNumber);
                },
              ),
              const SizedBox(height: kSpacer * 2),
              ElevatedButton(
                onPressed: () {
                  final mobile = firebase_ui_auth.PhoneInput.getPhoneNumber(
                      _phoneInputKey);
                  if (mobile != null) {
                    ctrl.acceptPhoneNumber(mobile);
                  }
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'SEND OTP',
                    ),
                  ],
                ),
              ),
            ],
          );
        } else if (state is firebase_ui_auth.SMSCodeSent) {
          return Column(
            children: [
              firebase_ui_auth.SMSCodeInput(
                key: _smsCodeInputKey,
              ),
              const SizedBox(height: kSpacer * 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      ctrl.reset();
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('BACK'),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final smsCode = _smsCodeInputKey.currentState?.code;
                      if (smsCode != null && smsCode.length < 6) {
                        return;
                      }

                      ctrl.verifySMSCode(
                        smsCode!,
                        verificationId: state.verificationId,
                        confirmationResult: state.confirmationResult,
                      );
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'VALIDATE',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        } else if (state is firebase_ui_auth.SMSCodeRequested ||
                state is firebase_ui_auth.SigningIn
            // || state is firebase_ui_auth.SignedIn
            ) {
          return const Center(
            child: SizedBox(
              width: kSpacer * 4,
              height: kSpacer * 4,
              child: CircularProgressIndicator(),
            ),
          );
        } else if (state is firebase_ui_auth.AuthFailed) {
          print('Login Screen | SignInWithMobile - Firebase Auth Failed');

          return Center(
            child: Column(
              children: [
                Text(state.exception.toString()),
                const SizedBox(height: kSpacer * 2),
                ElevatedButton(
                  onPressed: () {
                    ctrl.reset();
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('TRY AGAIN'),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else if (state is firebase_ui_auth.UserCreated ||
            state is firebase_ui_auth.SignedIn) {
          print(
              'Login Screen | SignInWithMobile - Firebase Auth successful - user created');

          return Center(
            child: Column(
              children: [
                const Text('Login Successful'),
                const SizedBox(height: kSpacer * 2),
                ElevatedButton(
                  onPressed: () {
                    ctrl.reset();
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('START OVER'),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          print('Unknown state $state');

          return Center(
            child: Column(
              children: [
                Text('Unknown state $state'),
                const SizedBox(height: kSpacer * 2),
                ElevatedButton(
                  onPressed: () {
                    ctrl.reset();
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('TRY AGAIN'),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
