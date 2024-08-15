// ignore_for_file: avoid_print

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test1/colors.dart';
import 'package:test1/pages/horoscope_page.dart';

import 'package:test1/pages/love_page.dart';
import 'package:test1/pages/onboarding_welcome_page.dart';
import 'package:test1/pages/personal_page.dart';
import 'package:test1/providers/user_data_provider.dart';
import 'package:test1/utils/error_dialog.dart';

class InitializerWidget extends StatefulWidget {
  const InitializerWidget({Key? key}) : super(key: key);

  @override
  _InitializerWidgetState createState() => _InitializerWidgetState();
}

class _InitializerWidgetState extends State<InitializerWidget> {
  late FirebaseAuth _auth;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _auth = FirebaseAuth.instance;
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    print("Initializing user");
    try {
      final connectivity = Connectivity();
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        throw Exception("No internet connection");
      }

      User? user = _auth.currentUser;
      print("Current user: $user");
      if (user != null) {
        final userDataProvider =
            Provider.of<UserDataProvider>(context, listen: false);
        await userDataProvider.fetchUserData(user.uid);
      } else {
        print("No user logged in");
      }
    } catch (e) {
      print("Error during initialization: $e");
      _errorMessage = "Failed to initialize: ${e.toString()}";
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("Initializing...", style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      );
    } else if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: ErrorDialog(
            message: _errorMessage!,
            onRetry: () {
              setState(() {
                _isLoading = true;
                _errorMessage = null;
              });
              _initializeUser();
            },
          ),
        ),
      );
    } else {
      return Consumer<UserDataProvider>(
        builder: (context, userDataProvider, child) {
          final userData = userDataProvider.userData;
          if (userData == null) {
            print("Going to onboarding");
            return OnboardingWelcomePage();
          } else {
            return const NavigationHome();
          }
        },
      );
    }
  }
}

class NavigationHome extends StatefulWidget {
  final int initialIndex;

  const NavigationHome({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  _NavigationHomeState createState() => _NavigationHomeState();
}

class _NavigationHomeState extends State<NavigationHome> {
  int _selectedIndex = 0;

  List<Widget> _pages(BuildContext context) {
    final userData = Provider.of<UserDataProvider>(context).userData;
    print(userData);
    if (userData == null) {
      // Handle the case where userData is not available
      return [Container()]; // or some placeholder widgets
    }
    return [
      HoroscopePage(),
      const LovePage(),
      const PersonalPage(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    print(_selectedIndex);
    return Scaffold(
      body: Stack(
        children: [
          _pages(context).elementAt(_selectedIndex),
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: tile_color,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(Icons.home, 0),
                  _buildNavItem(Icons.favorite, 1),
                  _buildNavItem(Icons.person, 2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    return IconButton(
      icon: Icon(icon),
      color: _selectedIndex == index ? yelloww : whitee,
      onPressed: () => _onItemTapped(index),
    );
  }
}
