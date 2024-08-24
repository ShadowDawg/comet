import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';
import 'package:test1/colors.dart';
import 'package:test1/providers/user_data_provider.dart';
import 'package:test1/models/user_and_astro_data.dart';
import 'package:test1/initializer_widget.dart';
import 'package:test1/backend/firebase_tools.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// Define a list of whitelisted email addresses
final List<String> whitelistedEmails = [
  "shadowpenguin2004@gmail.com",
  "testcometcomet@gmail.com",
];

class GoogleSignInPage extends StatefulWidget {
  final String name;
  final String handle;
  final String phoneNumber;
  final String gender;
  final File image;
  final DateTime birthday;
  final String birthplace;
  final String zodiacSign;
  final bool notificationsEnabled;

  GoogleSignInPage({
    required this.name,
    required this.handle,
    required this.phoneNumber,
    required this.gender,
    required this.image,
    required this.birthday,
    required this.birthplace,
    required this.zodiacSign,
    required this.notificationsEnabled,
  });

  @override
  _GoogleSignInPageState createState() => _GoogleSignInPageState();
}

class _GoogleSignInPageState extends State<GoogleSignInPage> {
  bool _isLoading = false;
  bool _showConnectionMessage = false;

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
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
      // Check internet connectivity
      final result = await InternetAddress.lookup("google.com");
      if (result.isNotEmpty) {
        // Sign out the user from GoogleSignIn
        await GoogleSignIn().signOut();

        // Trigger the authentication flow
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

        if (googleUser == null) {
          // User canceled the sign-in process
          throw Exception('Google Sign-In was canceled');
        }

        // Check if the email is a valid college email or in the whitelist
        if (!googleUser.email.toLowerCase().endsWith('@smail.iitm.ac.in') &&
            !whitelistedEmails.contains(googleUser.email.toLowerCase())) {
          // Show an error message and return early
          _showErrorDialog(
              'Please use your college email address ending with @smail.iitm.ac.in');
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

        // Upload the image to Firebase Storage
        String photoUrl = await _uploadImage(widget.image);

        Map<String, dynamic> userData = {
          'email': userCredential.user!.email,
          'name': widget.name,
          'dateOfBirth': widget.birthday.toUtc().toIso8601String(),
          'placeOfBirth': widget.birthplace,
          'photoUrl': photoUrl,
          'gender': widget.gender,
          'handle': widget.handle,
          'phoneNumber': "+91${widget.phoneNumber.trim()}",
          'notificationsEnabled': widget.notificationsEnabled,
          'zodiacSign': widget.zodiacSign,
        };

        if (widget.notificationsEnabled) {
          String? token = await FirebaseMessaging.instance.getToken();
          if (token != null) {
            userData['fcmToken'] = token;
          }
        }

        UserAndAstroData newUser =
            await backendFirebaseCreateNewUser(userData).timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            throw TimeoutException('Connection timed out. Please try again.');
          },
        );

        if (widget.notificationsEnabled) {
          FirebaseMessaging.instance.onTokenRefresh.listen((String token) {
            FirebaseFirestore.instance
                .collection('users')
                .doc(newUser.user.uid)
                .update({'fcmToken': token});
          });
        }

        if (!mounted) return;
        Provider.of<UserDataProvider>(context, listen: false)
            .setUserData(newUser);

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const NavigationHome()),
        );
      }
    } on SocketException catch (_) {
      _showErrorDialog(
          'No internet connection. Please check your network and try again.');
    } on TimeoutException catch (_) {
      _showErrorDialog('Connection timed out. Please try again later.');
    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred during authentication.';
      if (e.code == 'account-exists-with-different-credential') {
        message =
            'An account already exists with the same email address but different sign-in credentials. Please try signing in with a different method.';
      }
      _showErrorDialog(message);
    } catch (e) {
      _showErrorDialog('An unexpected error occurred: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _showConnectionMessage = false;
        });
      }
    }
  }

  Future<String> _uploadImage(File image) async {
    String fileName = '${DateTime.now().millisecondsSinceEpoch}_${widget.name}';
    Reference firebaseStorageRef =
        FirebaseStorage.instance.ref().child('profile_images/$fileName');
    UploadTask uploadTask = firebaseStorageRef.putFile(image);
    TaskSnapshot taskSnapshot = await uploadTask;
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: offwhite,
      backgroundColor: bgcolor, // dark
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        forceMaterialTransparency: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            // color: bgcolor,
            color: greyy,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Not like us.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  // color: bgcolor,
                  color: yelloww, // dark
                  fontFamily: 'Playwrite_HU',
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                "Exclusively for you, your friends and IITM. "
                "Use your smail to finish creating your account.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  // color: Colors.grey[700],
                  color: greyy, // dark
                  fontFamily: 'Manrope',
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _signInWithGoogle,
                  style: ElevatedButton.styleFrom(
                    // backgroundColor: bgcolor,
                    backgroundColor: yelloww, // dark
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FaIcon(
                              FontAwesomeIcons.google,
                              // color: offwhite,
                              color: bgcolor, // dark
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Continue with smail',
                              style: TextStyle(
                                // color: offwhite,
                                color: bgcolor, // dark
                                fontSize: 18,
                                fontFamily: 'Manrope',
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              if (_showConnectionMessage)
                const Padding(
                  padding: EdgeInsets.only(top: 20),
                  // child: Text(
                  //   'We\'re having trouble. Please check your connection.',
                  //   style: TextStyle(
                  //     color: Colors.red,
                  //     fontSize: 16,
                  //   ),
                  //   textAlign: TextAlign.center,
                  // ),
                  child: Text(
                    'Listening to the stars...',
                    style: TextStyle(
                      color: greyy,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
