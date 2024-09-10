import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:comet/backend/firebase_tools.dart';
import 'package:comet/colors.dart';
import 'package:comet/initializer_widget.dart';
import 'package:comet/models/user.dart';
import 'package:comet/pages/login/login_notifications_permission_page.dart';
import 'package:comet/providers/user_data_provider.dart';
import 'package:comet/pages/login/password_reset_page.dart';

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

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String? Function(String?) validator, {
    bool isPassword = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword && _obscurePassword,
        style: const TextStyle(
          fontFamily: 'Manrope',
          color: offwhite,
        ),
        decoration: InputDecoration(
          hintText: label,
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
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: offwhite,
                  ),
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

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: darkGreyy,
        title: const Text(
          'Login Error',
          style: TextStyle(
            fontFamily: "manrope",
            color: offwhite,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: "manrope",
            color: greyy,
          ),
        ),
        actions: [
          TextButton(
            child: const Text(
              'Okay',
              style: TextStyle(
                fontFamily: "manrope",
                color: greyy,
              ),
            ),
            onPressed: () => Navigator.of(context).pop(),
          )
        ],
      ),
    );
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        UserModel userData =
            await backendFirebaseGetUserData(userCredential.user!.uid);
        if (mounted) {
          Provider.of<UserDataProvider>(context, listen: false)
              .setUserData(userData);
        }

        if (!userData.notificationsEnabled) {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              PageTransition(
                type: PageTransitionType.topToBottom,
                child: const LoginNotificationPermissionPage(),
              ),
            );
          }
        } else {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              PageTransition(
                type: PageTransitionType.topToBottom,
                child: const NavigationHome(),
              ),
            );
          }
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          _showErrorDialog('No account found with this email.');
        } else if (e.code == 'wrong-password') {
          _showErrorDialog('Incorrect password. Please try again.');
        } else if (e.code == 'invalid-credential') {
          _showErrorDialog('The email or password used is incorrect.');
        } else {
          _showErrorDialog(e.message ?? 'An error occurred during login');
        }
      } catch (e) {
        _showErrorDialog('An unexpected error occurred during login.');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
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
          icon: const Icon(Icons.arrow_back, color: yelloww),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'welcome back.',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: yelloww,
                        fontFamily: 'Playwrite_HU',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    _buildTextField(_emailController, 'Email', _validateEmail),
                    _buildTextField(
                        _passwordController, 'Password', _validatePassword,
                        isPassword: true),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            PageTransition(
                              type: PageTransitionType.rightToLeft,
                              child: PasswordResetPage(),
                            ),
                          );
                        },
                        child: const Text(
                          'Forgot password?',
                          style: TextStyle(
                            color: yelloww,
                            fontFamily: 'Manrope',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: yelloww,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              color: yelloww,
                            )
                          : const Text(
                              'Login',
                              style: TextStyle(
                                color: bgcolor,
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
        ),
      ),
    );
  }
}
