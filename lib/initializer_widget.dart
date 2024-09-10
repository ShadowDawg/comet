import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:comet/colors.dart';
import 'package:comet/pages/friends/friends_page.dart';
import 'package:comet/pages/horoscope/horoscope_page.dart';
import 'package:comet/pages/love/love_page.dart';
import 'package:comet/pages/onboarding_welcome_page.dart';
import 'package:comet/pages/personal/personal_page.dart';
import 'package:comet/providers/user_data_provider.dart';
import 'package:comet/utils/error_dialog.dart';

class InitializerWidget extends StatefulWidget {
  const InitializerWidget({Key? key}) : super(key: key);

  @override
  _InitializerWidgetState createState() => _InitializerWidgetState();
}

class _InitializerWidgetState extends State<InitializerWidget> {
  late FirebaseAuth _auth;
  bool _isLoading = true;
  String? _errorMessage;
  bool _showConnectionMessage = false;
  Timer? _connectionMessageTimer;

  @override
  void initState() {
    super.initState();
    _auth = FirebaseAuth.instance;
    _initializeUser();
  }

  @override
  void dispose() {
    _connectionMessageTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeUser() async {
    print("Initializing user");
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _showConnectionMessage = false;
    });

    _connectionMessageTimer = Timer(const Duration(seconds: 12), () {
      if (mounted && _isLoading) {
        setState(() {
          _showConnectionMessage = true;
        });
      }
    });

    try {
      final connectivity = Connectivity();
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        throw Exception("No internet connection");
      }

      User? user = _auth.currentUser;
      print("Current user: $user");
      final userDataProvider =
          Provider.of<UserDataProvider>(context, listen: false);

      if (user != null) {
        await userDataProvider.fetchUserData(user.uid);
      } else {
        print("No user logged in");
        userDataProvider.clearUserData();
      }
    } catch (e) {
      print("Error during initialization, go to onboarding!: $e");
      _errorMessage = "The stars are acting sus. You'll have to login again :(";
    } finally {
      _connectionMessageTimer?.cancel();
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserDataProvider>(
      builder: (context, userDataProvider, child) {
        if (_isLoading) {
          return Scaffold(
            backgroundColor: bgcolor,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Colors.white),
                  const SizedBox(height: 24),
                  const Text(
                    "✨ Aligning the stars for you ✨",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Your cosmic journey is about to begin...",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  if (_showConnectionMessage)
                    const Padding(
                      padding: EdgeInsets.only(top: 24.0),
                      child: Text(
                        "Hmm, the stars are taking their time.\nPlease check your internet connection.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.yellow,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        } else if (_errorMessage != null) {
          return Scaffold(
            body: Center(
              child: SimpleErrorDialog(
                message: _errorMessage!,
                onRetry: _initializeUser,
              ),
            ),
          );
        } else {
          return AuthWrapper();
        }
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userDataProvider = Provider.of<UserDataProvider>(context);
    final userData = userDataProvider.userData;

    if (userData == null) {
      print("Going to onboarding");
      return const OnboardingWelcomePage();
    } else {
      return const NavigationHome();
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
    if (userData == null) {
      return [
        Container(),
        Container(),
        Container(),
        Container(),
      ];
    }
    return [
      const HoroscopePage(),
      const FriendsPage(),
      const LovePage(),
      const PersonalPage(),
    ];
  }

  void _onItemTapped(int index) {
    if (mounted) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages(context).elementAt(_selectedIndex),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          navigationBarTheme: NavigationBarThemeData(
            indicatorColor: yelloww,
            labelTextStyle: WidgetStateProperty.all(
              const TextStyle(color: yelloww),
            ),
            iconTheme: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const IconThemeData(color: bgcolor);
              }
              return const IconThemeData(color: bgcolor);
            }),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onItemTapped,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home),
              label: '',
            ),
            NavigationDestination(
              icon: Icon(Icons.people),
              label: '',
            ),
            NavigationDestination(
              icon: Icon(Icons.favorite),
              label: '',
            ),
            NavigationDestination(
              icon: Icon(Icons.person),
              label: '',
            ),
          ],
          backgroundColor: tile_color,
          indicatorColor: yelloww,
        ),
      ),
    );
  }
}


class SimpleErrorDialog extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const SimpleErrorDialog({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Error'),
      content: Text(message),
      actions: <Widget>[
        TextButton(
          child: const Text('OK'),
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const OnboardingWelcomePage()),
            );
          },
        ),
        if (onRetry != null)
          TextButton(
            child: Text('Retry'),
            onPressed: () {
              Navigator.of(context).pop();
              onRetry!();
            },
          ),
      ],
    );
  }
}
