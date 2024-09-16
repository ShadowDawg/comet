import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:comet/backend/firebase_tools.dart';
import 'package:comet/colors.dart';
import 'package:comet/initializer_widget.dart';
import 'package:comet/models/user.dart';
import 'package:comet/pages/signup/google_signup_page6.dart';
import 'package:comet/providers/user_data_provider.dart';
import 'package:comet/utils/validators.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class SignupDetailsPage extends StatefulWidget {
  final DateTime birthday;
  final String birthplace;
  final String zodiacSign;
  final bool notificationsEnabled;

  SignupDetailsPage({
    required this.birthday,
    required this.birthplace,
    required this.zodiacSign,
    required this.notificationsEnabled,
  });

  @override
  _SignupDetailsPageState createState() => _SignupDetailsPageState();
}

class _SignupDetailsPageState extends State<SignupDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _handleController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedGender;
  bool _isLoading = false;
  bool _showConnectionMessage = false;
  File? _image;
  final picker = ImagePicker();
  bool _isFormSubmitted = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _handleController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> getImage() async {
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        if (mounted) {
          setState(() {
            _image = File(pickedFile.path);
          });
        }
      }
    } catch (e) {
      _showErrorDialog('Failed to pick image: $e');
    }
  }

  Future<String> uploadImage(File image) async {
    try {
      String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${_nameController.text}';
      Reference firebaseStorageRef =
          FirebaseStorage.instance.ref().child('profile_images/$fileName');
      UploadTask uploadTask = firebaseStorageRef.putFile(image);
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  void _navigateToGoogleSignIn() {
    if (_formKey.currentState!.validate() &&
        _selectedGender != null &&
        _image != null) {
      Navigator.of(context).push(
        PageTransition(
          type: PageTransitionType.rightToLeft,
          child: GoogleSignInPage(
            name: _nameController.text.trim(),
            handle: _handleController.text.trim(),
            phoneNumber: _phoneController.text.trim(),
            gender: _selectedGender!,
            image: _image!,
            birthday: widget.birthday,
            birthplace: widget.birthplace,
            zodiacSign: widget.zodiacSign,
            notificationsEnabled: widget.notificationsEnabled,
          ),
        ),
      );
    } else {
      if (mounted) {
        setState(() {
          _isFormSubmitted = true;
        });
      }
      // _showErrorDialog(
      //     'Please fill in all fields and select a profile picture.');
    }
  }

  Future<void> _signup() async {
    if (!mounted) return;
    setState(() {
      _isFormSubmitted = true;
    });

    if (_formKey.currentState!.validate() && _selectedGender != null) {
      if (!mounted) return;
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
        // TODO replace with api endpoint????
        final result = await InternetAddress.lookup("google.com");
        print(result);
        if (result.isNotEmpty) {
          String photoUrl = await uploadImage(_image!);
          String birthdayIso = widget.birthday.toUtc().toIso8601String();

          Map<String, dynamic> userData = {
            'email': _emailController.text.trim(),
            'password': _passwordController.text,
            'name': _nameController.text.trim(),
            'dateOfBirth': birthdayIso,
            'placeOfBirth': widget.birthplace,
            'photoUrl': photoUrl,
            'gender': _selectedGender!,
            'handle': _handleController.text.trim(),
            'phoneNumber': _phoneController.text.trim(),
            'notificationsEnabled': widget.notificationsEnabled,
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

          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text,
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
              'This email is already registered. Please use a different email or try logging in.';
        }
        _showErrorDialog(message);
      } catch (e) {
        _showErrorDialog('An unexpected error occurred: ${e.toString()}');
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      // _showErrorDialog(
      //     'Please fill in all fields and select a profile picture.');
    }
  }

  Future<T> _timeoutFuture<T>(Future<T> future, Duration timeout) {
    return future.timeout(timeout, onTimeout: () {
      throw TimeoutException('The connection has timed out, please try again!');
    });
  }

  void _showErrorDialog(String message) {
    if (!mounted) return; // Add this check
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Hello ${widget.zodiacSign}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: yelloww,
                    // fontFamily: 'Manrope',
                    fontFamily: 'Playwrite_HU',
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  'Complete Your Profile',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: yelloww,
                    fontFamily: 'Manrope',
                  ),
                ),
                const SizedBox(height: 20),
                CircularProfileImage(
                  imageFile: _image,
                  onTap: getImage,
                ),
                if (_isFormSubmitted && _image == null)
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      'A pfp is required. Feel free to flex your game.',
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 15,
                          fontFamily: 'Manrope'),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 20),
                _buildTextField(
                    _nameController, 'First Name', Validators.validateName),
                _buildTextField(
                    _handleController, 'Username', Validators.validateUsername),
                _buildTextField(
                    _phoneController, 'Phone Number', Validators.validatePhone,
                    isPhone: true),
                _buildGenderDropdown(),
                const SizedBox(height: 30),
                SizedBox(
                  width: double
                      .infinity, // This makes the button container full-width
                  child: ElevatedButton(
                    onPressed: _navigateToGoogleSignIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: yelloww,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text(
                      'Next',
                      style: TextStyle(
                        color: bgcolor,
                        fontSize: 18,
                        fontFamily: 'Manrope',
                      ),
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

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String? Function(String?) validator, {
    bool isPassword = false,
    bool isPhone = false,
  }) {
    final bool isUsername = label == "Username";

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword && _obscurePassword,
        keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
        inputFormatters: isPhone
            ? [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ]
            : null,
        style: const TextStyle(
          fontFamily: 'Manrope',
          color: offwhite,
        ),
        decoration: InputDecoration(
          hintText: isUsername ? "username" : label,
          hintStyle: const TextStyle(
            fontFamily: 'Manrope',
            color: greyy,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: darkGreyy,
          prefixIcon: isUsername
              ? Container(
                  width: 30,
                  alignment: Alignment.center,
                  child: const Text(
                    "@",
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      color: offwhite,
                    ),
                  ),
                )
              : null,
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(_obscurePassword
                      ? Icons.visibility_off
                      : Icons.visibility),
                  onPressed: () {
                    if (mounted) {
                      setState(() => _obscurePassword = !_obscurePassword);
                    }
                  },
                )
              : null,
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
            _passwordController, 'Password', Validators.validatePassword,
            isPassword: true),
      ],
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedGender,
      dropdownColor: bgcolor,
      decoration: InputDecoration(
        hintText: 'Gender',
        hintStyle: const TextStyle(
          fontFamily: 'Manrope',
          color: greyy,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: darkGreyy,
      ),
      style: const TextStyle(
        fontFamily: 'Manrope',
        color: offwhite,
      ),
      items: ['Male', 'Female'].map((String value) {
        return DropdownMenuItem<String>(
          value: value.toLowerCase(),
          child: Text(
            value,
            style: const TextStyle(
              fontFamily: 'Manrope',
              color: offwhite,
            ),
          ),
        );
      }).toList(),
      onChanged: (newValue) {
        if (mounted) {
          setState(() => _selectedGender = newValue);
        }
      },
      validator: (value) => value == null ? 'Please select a gender' : null,
    );
  }
}

// Widget _buildTextField(TextEditingController controller, String label,
//     String? Function(String?) validator,
//     {bool isPassword = false, bool isPhone = false}) {
//   return Padding(
//     padding: const EdgeInsets.only(bottom: 10),
//     child: TextFormField(
//       controller: controller,
//       decoration: InputDecoration(
//         labelText: label,
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//         fillColor: Colors.white10,
//         filled: true,
//       ),
//       style: const TextStyle(color: bgcolor, fontFamily: 'Manrope'),
//       obscureText: isPassword,
//       keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
//       inputFormatters: isPhone
//           ? [
//               FilteringTextInputFormatter.digitsOnly,
//               LengthLimitingTextInputFormatter(10)
//             ]
//           : null,
//       validator: validator,
//     ),
//   );
// }

// Widget _buildGenderDropdown() {
//   return DropdownButtonFormField<String>(
//     value: _selectedGender,
//     decoration: InputDecoration(
//       labelText: 'Gender',
//       border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//       fillColor: Colors.white10,
//       filled: true,
//     ),
//     dropdownColor: offwhite,
//     style: const TextStyle(color: bgcolor, fontFamily: 'Manrope'),
//     items: ['Male', 'Female', 'Other'].map((String value) {
//       return DropdownMenuItem<String>(
//         value: value.toLowerCase(),
//         child: Text(value, style: const TextStyle(color: bgcolor)),
//       );
//     }).toList(),
//     onChanged: (newValue) => setState(() => _selectedGender = newValue),
//     validator: (value) => value == null ? 'Select your gender' : null,
//   );
// }

class CircularProfileImage extends StatelessWidget {
  final File? imageFile;
  final VoidCallback onTap;

  const CircularProfileImage({
    Key? key,
    required this.imageFile,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double avatarRadius = MediaQuery.of(context).size.width * 0.15;
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: avatarRadius,
        backgroundColor: darkGreyy,
        backgroundImage: imageFile != null ? FileImage(imageFile!) : null,
        child: imageFile == null
            ? const Icon(Icons.add_a_photo, size: 50, color: greyy)
            : null,
      ),
    );
  }
}
