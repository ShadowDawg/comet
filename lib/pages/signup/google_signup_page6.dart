import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';
import 'package:comet/colors.dart';
import 'package:comet/models/user.dart';
import 'package:comet/providers/user_data_provider.dart';
import 'package:comet/initializer_widget.dart';
import 'package:comet/backend/firebase_tools.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// Define a list of whitelisted email addresses
final List<String> whitelistedEmails = [
  "shadowpenguin2004@gmail.com",
  "testcometcomet@gmail.com",
  "devmandal2004@gmail.com",
  "cometapp.official@gmail.com",
  "shadowdawg2004@gmail.com",
  "avataraangstudy@gmail.com",
  "erplp7@gmail.com"
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
  final String password;

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
    required this.password,
  });

  @override
  _GoogleSignInPageState createState() => _GoogleSignInPageState();
}

class _GoogleSignInPageState extends State<GoogleSignInPage> {
  bool _isLoading = false;
  bool _showConnectionMessage = false;

  Future<void> _signInWithGoogle() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

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
        // Trigger the Google authentication flow for email verification
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

        // Check if the email already exists in Firebase
        final List<String> signInMethods = await FirebaseAuth.instance
            .fetchSignInMethodsForEmail(googleUser.email);
        if (signInMethods.isNotEmpty) {
          _showErrorDialog(
              'An account with this email already exists. Please log in instead.');
          return;
        }

        // Email is verified and doesn't exist, now sign out from Google
        await GoogleSignIn().signOut();

        // Create user with email and password
        final UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: googleUser.email,
          password:
              widget.password, // Assume password is provided in the widget
        );

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

        UserModel newUser =
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
                .doc(newUser.uid)
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
      if (e.code == 'email-already-in-use') {
        message =
            'This email address is already in use. Please use a different email or try logging in.';
      } else {
        message = 'An error occurred during sign up: ${e.message}';
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
    try {
      // Read the file as bytes
      Uint8List fileBytes = await image.readAsBytes();

      // Generate a unique file name
      String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${widget.name}';

      // Create a reference to the Firebase Storage location
      Reference firebaseStorageRef =
          FirebaseStorage.instance.ref().child('profile_images/$fileName');

      // Start the file upload using putData
      UploadTask uploadTask = firebaseStorageRef.putData(fileBytes);

      // Await the completion of the upload task
      TaskSnapshot taskSnapshot = await uploadTask;

      // Retrieve the download URL of the uploaded file
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      return downloadUrl;
    } on FirebaseException catch (e) {
      // Handle Firebase-specific errors
      print('FirebaseException: ${e.message}');
      throw Exception('Failed to upload image: ${e.message}');
    } on PlatformException catch (e) {
      // Handle platform-specific errors
      print('PlatformException: ${e.message}');
      throw Exception('Failed to upload image: ${e.message}');
    } catch (e) {
      // Handle other errors
      print('Exception: $e');
      throw Exception('Failed to upload image: $e');
    }
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
                "Exclusively for you, your friends and insti. "
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
                    'The stars are cooking...',
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
