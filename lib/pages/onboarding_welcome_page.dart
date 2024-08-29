import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:test1/colors.dart';
import 'package:test1/pages/login/login_page.dart';
import 'package:test1/pages/signup/birthday_input_page1.dart';

class OnboardingWelcomePage extends StatelessWidget {
  const OnboardingWelcomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: offwhite,
      backgroundColor: bgcolor, // dark
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(),
                        const Hero(
                          tag: 'app_logo',
                          child: Text(
                            'comet.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 50,
                              // fontWeight: FontWeight.bold,
                              // color: bgcolor,
                              color: yelloww, // dark
                              fontFamily: 'Playwrite_HU',
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        const Text(
                          'Blame the stars and get matched with someone special at insti every week.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 27,
                            // color: Colors.black87,
                            color: greyy, // dark
                            fontFamily: 'Manrope',
                          ),
                        ),
                        const SizedBox(height: 60),
                        ElevatedButton(
                          onPressed: () =>
                              _navigateTo(context, BirthdayInputPage()),
                          style: ElevatedButton.styleFrom(
                            // backgroundColor: bgcolor,
                            backgroundColor: yelloww, // dark
                            // foregroundColor: offwhite,
                            foregroundColor: bgcolor, // dark
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 15),
                            textStyle: const TextStyle(fontSize: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Get Started',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () => _navigateTo(context, LoginPage()),
                          style: TextButton.styleFrom(
                            foregroundColor: greyy,
                          ),
                          child: const Text(
                            'Already have an account? Sign in',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              decoration: TextDecoration.underline,
                              color: offwhite,
                            ),
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.rightToLeft,
        child: page,
        // duration: const Duration(milliseconds: 500),
      ),
    );
  }
}
