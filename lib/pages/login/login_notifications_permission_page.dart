import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:test1/backend/firebase_tools.dart';
import 'package:test1/colors.dart';
import 'package:test1/initializer_widget.dart';
import 'package:test1/providers/user_data_provider.dart';

class LoginNotificationPermissionPage extends StatelessWidget {
  const LoginNotificationPermissionPage({Key? key}) : super(key: key);

  Future<void> _requestPermissionAndUpdate(BuildContext context) async {
    final userDataProvider =
        Provider.of<UserDataProvider>(context, listen: false);
    final userData = userDataProvider.userData;

    if (userData == null) {
      // Handle the case where userData is not available
      print('User data is not available');
      return;
    }

    final messaging = FirebaseMessaging.instance;

    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    bool notificationsEnabled =
        settings.authorizationStatus == AuthorizationStatus.authorized;

    if (notificationsEnabled) {
      String? token = await messaging.getToken();
      if (token != null) {
        bool updated = await backendFirebaseUpdateUserNotificationPermission(
          userId: userData.uid,
          fcmToken: token,
        );
        if (updated) {
          // Update the user data in the provider
          userDataProvider.updateUserData(
            (currentData) => currentData.copyWith(
              notificationsEnabled: true,
              fcmToken: token,
            ),
          );
        } else {
          // Handle update failure (e.g., show an error message)
          print('Failed to update notification settings');
        }
      }
    }

    // Navigate to the home page
    Navigator.pushReplacement(
      context,
      PageTransition(
        type: PageTransitionType.fade,
        child: const NavigationHome(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: yelloww,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: offwhite),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.notifications_active,
                size: 80,
                color: bgcolor,
              ),
              const SizedBox(height: 24),
              const Text(
                "InstiSpace never saw this coming.",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: bgcolor,
                  fontFamily: 'Playwrite_HU',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                "Get notified about your daily horoscopes and when your match slides into your dm's. Pinky promise we don't spam.",
                style: TextStyle(
                  fontSize: 16,
                  color: bgcolor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => _requestPermissionAndUpdate(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: bgcolor,
                  foregroundColor: offwhite,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  "Enable Notifications",
                  style: TextStyle(
                    color: yelloww,
                    fontFamily: "Manrope",
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to the home page without enabling notifications
                  Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.fade,
                      child: const NavigationHome(),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: bgcolor,
                ),
                child: const Text(
                  "Not Now",
                  style: TextStyle(
                    color: bgcolor,
                    fontFamily: "Manrope",
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
