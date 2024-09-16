import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:comet/backend/firebase_tools.dart';
import 'package:comet/colors.dart';
import 'package:comet/initializer_widget.dart';
import 'package:comet/models/user.dart';
import 'package:comet/pages/signup/google_signup_page6.dart';
import 'package:comet/pages/login/login_notifications_permission_page.dart';
import 'package:comet/providers/user_data_provider.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _showConnectionMessage = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Login Error'),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('Okay'),
            onPressed: () => Navigator.of(context).pop(),
          )
        ],
      ),
    );
  }

  Future<void> _loginWithGoogle() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _showConnectionMessage = false;
    });

    // Start a timer to show the connection message after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _isLoading) {
        setState(() {
          _showConnectionMessage = true;
        });
      }
    });

    try {
      // Sign out the current Google user to always show the account picker
      await GoogleSignIn().signOut();

      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        // User canceled the sign-in process
        throw Exception('Google Sign-In was canceled');
      }

      // Check if the email is a valid college email or in the whitelist
      if (!googleUser.email.toLowerCase().endsWith('@smail.iitm.ac.in') &&
          !whitelistedEmails.contains(googleUser.email.toLowerCase())) {
        if (mounted) {
          _showErrorDialog(
              'Please use your college email address ending with @smail.iitm.ac.in');
        }
        return;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // Fetch user data
      UserModel userData =
          await backendFirebaseGetUserData(userCredential.user!.uid);

      if (!mounted) return;

      // Update user data in the provider
      Provider.of<UserDataProvider>(context, listen: false)
          .setUserData(userData);

      // Navigate based on notification settings
      if (!userData.notificationsEnabled) {
        Navigator.pushReplacement(
          context,
          PageTransition(
            type: PageTransitionType.topToBottom,
            child: const LoginNotificationPermissionPage(),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          PageTransition(
            type: PageTransitionType.topToBottom,
            child: const NavigationHome(),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        if (e.code == 'user-not-found') {
          _showErrorDialog(
              'No account found with this email. Please create an account first.');
        } else {
          _showErrorDialog(
              e.message ?? 'An error occurred during Google sign-in');
        }
      }
    } catch (e) {
      if (mounted) {
        if (e is Exception &&
            e.toString().contains('Google Sign-In was canceled')) {
          // User canceled the sign-in process, no need to show an error
          print('Google Sign-In was canceled by the user');
        } else {
          print(e);
          // assuming that this is only called when no account associated with valid email
          _showErrorDialog(
              'An unexpected error occurred during Google sign-in.');
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _showConnectionMessage = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: yelloww,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: bgcolor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'welcome back.',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: bgcolor,
                    fontFamily: 'Playwrite_HU',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                _isLoading
                    ? Column(
                        children: [
                          const CircularProgressIndicator(color: bgcolor),
                          if (_showConnectionMessage)
                            const Padding(
                              padding: EdgeInsets.only(top: 20),
                              child: Text(
                                'Yup, the stars are really spitting right now. Just a sec...',
                                style: TextStyle(
                                  // color: Colors.red[700],
                                  color: Colors.black45,
                                  fontSize: 16,
                                  fontFamily: 'Manrope',
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                        ],
                      )
                    : ElevatedButton.icon(
                        onPressed: _loginWithGoogle,
                        icon: const FaIcon(
                          FontAwesomeIcons.google,
                          color: yelloww,
                        ),
                        // icon: Image.asset(
                        //   // 'assets/google_logo.png',
                        //   'assets/icons/libra-icon.png',
                        //   height: 24.0,
                        // ),
                        label: const Text(
                          'Login with smail',
                          style: TextStyle(
                            color: yelloww,
                            fontSize: 18,
                            fontFamily: 'Manrope',
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: bgcolor,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
