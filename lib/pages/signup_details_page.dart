import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:test1/backend/firebase_tools.dart';
import 'package:test1/colors.dart';
import 'package:test1/initializer_widget.dart';
import 'package:test1/providers/user_data_provider.dart';
import '../models/user_and_astro_data.dart';
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
  File? _image;
  final picker = ImagePicker();
  bool _isFormSubmitted = false;

  Future<void> getImage() async {
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick image: $e');
    }
  }

  Future<String> uploadImage(File image) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
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

  Future<void> _signup() async {
    setState(() {
      _isFormSubmitted = true;
    });

    if (_formKey.currentState!.validate() &&
        _selectedGender != null &&
        _image != null) {
      setState(() {
        _isLoading = true;
      });
      try {
        if (_formKey.currentState!.validate() &&
            _selectedGender != null &&
            _image != null) {
          setState(() {
            _isLoading = true;
          });
          try {
            String photoUrl = await uploadImage(_image!);
            String birthdayIso = widget.birthday.toUtc().toIso8601String();

            Map<String, dynamic> userData = {
              'email': _emailController.text,
              'password': _passwordController.text,
              'name': _nameController.text,
              'dateOfBirth': birthdayIso,
              'placeOfBirth': widget.birthplace,
              'photoUrl': photoUrl,
              'gender': _selectedGender!,
              'handle': _handleController.text,
              'phoneNumber': _phoneController.text,
              'notificationsEnabled': widget.notificationsEnabled,
            };

            if (widget.notificationsEnabled) {
              String? token = await FirebaseMessaging.instance.getToken();
              if (token != null) {
                userData['fcmToken'] = token;
              }
            }

            UserAndAstroData newUser =
                await backendFirebaseCreateNewUser(userData);

            await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: _emailController.text,
              password: _passwordController.text,
            );

            if (widget.notificationsEnabled) {
              FirebaseMessaging.instance.onTokenRefresh.listen((String token) {
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(newUser.user.uid)
                    .update({'fcmToken': token});
              });
            }

            Provider.of<UserDataProvider>(context, listen: false)
                .setUserData(newUser);

            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => NavigationHome()),
            );
          } catch (e) {
            _showErrorSnackBar('An error occurred: $e');
          } finally {
            setState(() {
              _isLoading = false;
            });
          }
        } else {
          _showErrorSnackBar(
              'Please fill in all fields and select a profile picture.');
        }
      } catch (e) {
        _showErrorSnackBar('An error occurred: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      _showErrorSnackBar(
          'Please fill in all fields and select a profile picture.');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: offwhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: bgcolor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: bgcolor))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Hello ${widget.zodiacSign}!',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontFamily: 'Manrope',
                        ),
                      ),
                      const Text(
                        'Complete Your Profile',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: bgcolor,
                          fontFamily: 'Manrope',
                        ),
                      ),
                      const SizedBox(height: 20),
                      CircularProfileImage(imageFile: _image, onTap: getImage),
                      if (_isFormSubmitted && _image == null)
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Profile picture is required',
                            style: TextStyle(
                                color: Colors.red,
                                fontSize: 15,
                                fontFamily: 'Manrope'),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      const SizedBox(height: 20),
                      _buildTextField(_nameController, 'Name',
                          (value) => value!.isEmpty ? 'Enter your name' : null),
                      _buildTextField(
                          _handleController,
                          'Username',
                          (value) =>
                              value!.isEmpty ? 'Enter your username' : null),
                      _buildTextField(
                          _emailController,
                          'Email',
                          (value) => !value!.contains('@')
                              ? 'Enter a valid email'
                              : null),
                      _buildTextField(
                          _passwordController,
                          'Password',
                          (value) => value!.length < 6
                              ? 'Password must be at least 6 characters'
                              : null,
                          isPassword: true),
                      _buildTextField(
                          _phoneController,
                          'Phone Number',
                          (value) => value!.length != 10
                              ? 'Phone number must be 10 digits'
                              : null,
                          isPhone: true),
                      _buildGenderDropdown(),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _signup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: bgcolor,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text(
                          'Create Account',
                          style: TextStyle(
                            color: offwhite,
                            fontSize: 18,
                            fontFamily: 'Manrope',
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

  Widget _buildTextField(TextEditingController controller, String label,
      String? Function(String?) validator,
      {bool isPassword = false, bool isPhone = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          fillColor: Colors.white10,
          filled: true,
        ),
        style: const TextStyle(color: bgcolor, fontFamily: 'Manrope'),
        obscureText: isPassword,
        keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
        inputFormatters: isPhone
            ? [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10)
              ]
            : null,
        validator: validator,
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedGender,
      decoration: InputDecoration(
        labelText: 'Gender',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        fillColor: Colors.white10,
        filled: true,
      ),
      dropdownColor: offwhite,
      style: const TextStyle(color: bgcolor, fontFamily: 'Manrope'),
      items: ['Male', 'Female', 'Other'].map((String value) {
        return DropdownMenuItem<String>(
          value: value.toLowerCase(),
          child: Text(value, style: const TextStyle(color: bgcolor)),
        );
      }).toList(),
      onChanged: (newValue) => setState(() => _selectedGender = newValue),
      validator: (value) => value == null ? 'Select your gender' : null,
    );
  }
}

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
        backgroundColor: Colors.grey[200],
        backgroundImage: imageFile != null ? FileImage(imageFile!) : null,
        child: imageFile == null
            ? Icon(Icons.add_a_photo, size: 50, color: Colors.grey[800])
            : null,
      ),
    );
  }
}
