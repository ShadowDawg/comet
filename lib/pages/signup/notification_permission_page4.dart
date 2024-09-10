import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:page_transition/page_transition.dart';
import 'package:comet/colors.dart';
import 'package:comet/pages/signup/signup_details_page5.dart';

class NotificationPermissionPage extends StatefulWidget {
  final DateTime birthday;
  final String birthplace;
  final String zodiacSign;

  const NotificationPermissionPage({
    Key? key,
    required this.birthday,
    required this.birthplace,
    required this.zodiacSign,
  }) : super(key: key);

  @override
  _NotificationPermissionPageState createState() =>
      _NotificationPermissionPageState();
}

class _NotificationPermissionPageState
    extends State<NotificationPermissionPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // This will be called after the widget has been built
      FocusScope.of(context).unfocus();
    });
  }

  Future<void> _requestPermissionAndNavigate() async {
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

      if (mounted) {
        _navigateToSignupDetails(notificationsEnabled);
      }
    } catch (e) {
      print('Error requesting notification permission: $e');
      if (mounted) {
        _showErrorDialog();
      }
    }
  }

  void _navigateToSignupDetails(bool notificationsEnabled) {
    Navigator.pushReplacement(
      context,
      PageTransition(
        type: PageTransitionType.rightToLeft,
        child: SignupDetailsPage(
          birthday: widget.birthday,
          birthplace: widget.birthplace,
          zodiacSign: widget.zodiacSign,
          notificationsEnabled: notificationsEnabled,
        ),
      ),
    );
  }

  void _showErrorDialog() {
    if (context.mounted) {
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
                  _navigateToSignupDetails(false);
                },
              ),
              TextButton(
                child: const Text('Try Again'),
                onPressed: () {
                  Navigator.of(context).pop();
                  _requestPermissionAndNavigate();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgcolor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: greyy,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.notifications_active,
                    size: 80,
                    color: yelloww,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Stay in the loop!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: yelloww,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Manrope',
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Enable notifications to get timely updates. Pinky promise we're much more fun than InstiSpace.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: greyy,
                      fontSize: 16,
                      fontFamily: 'Manrope',
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () => _requestPermissionAndNavigate(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkGreyy,
                      foregroundColor: yelloww,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Enable Notifications",
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Manrope',
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _navigateToSignupDetails(false),
                    child: const Text(
                      "Maybe Later",
                      style: TextStyle(
                        color: greyy,
                        fontSize: 16,
                        fontFamily: 'Manrope',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
