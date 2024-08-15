import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:page_transition/page_transition.dart';
import 'package:test1/colors.dart';
import 'package:test1/pages/signup_details_page.dart';

class NotificationPermissionPage extends StatelessWidget {
  final DateTime birthday;
  final String birthplace;
  final String zodiacSign;

  const NotificationPermissionPage({
    Key? key,
    required this.birthday,
    required this.birthplace,
    required this.zodiacSign,
  }) : super(key: key);

  Future<void> _requestPermissionAndNavigate(BuildContext context) async {
    try {
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
          print('FCM Token: $token');
          // TODO: Store this token securely for later use
        }
      }

      _navigateToSignupDetails(context, notificationsEnabled);
    } catch (e) {
      print('Error requesting notification permission: $e');
      _showErrorDialog(context);
    }
  }

  void _navigateToSignupDetails(
      BuildContext context, bool notificationsEnabled) {
    Navigator.pushReplacement(
      context,
      PageTransition(
        type: PageTransitionType.rightToLeft,
        child: SignupDetailsPage(
          birthday: birthday,
          birthplace: birthplace,
          zodiacSign: zodiacSign,
          notificationsEnabled: notificationsEnabled,
        ),
      ),
    );
  }

  void _showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Oops!'),
          content: const Text(
              'There was an error requesting notification permissions. You can try again or proceed without notifications.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Proceed Without Notifications'),
              onPressed: () {
                Navigator.of(context).pop();
                _navigateToSignupDetails(context, false);
              },
            ),
            TextButton(
              child: const Text('Try Again'),
              onPressed: () {
                Navigator.of(context).pop();
                _requestPermissionAndNavigate(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tile_color,
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
              const Icon(Icons.notifications_active, size: 80, color: offwhite),
              const SizedBox(height: 24),
              const Text(
                "Stay in the loop!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Manrope',
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Enable notifications to get timely updates. Pinky promise we don't spam!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Manrope',
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => _requestPermissionAndNavigate(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: offwhite,
                  foregroundColor: bgcolor,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Enable Notifications",
                  style: TextStyle(fontSize: 18, fontFamily: 'Manrope'),
                ),
              ),
              TextButton(
                onPressed: () => _navigateToSignupDetails(context, false),
                child: const Text(
                  "Maybe Later",
                  style: TextStyle(
                    color: offwhite,
                    fontSize: 16,
                    fontFamily: 'Manrope',
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
