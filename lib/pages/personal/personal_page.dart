import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:comet/colors.dart';
import 'package:comet/models/user.dart';
// import 'package:comet/pages/horoscope_widgets.dart';
import 'package:comet/pages/personal/personal_page_widgets.dart';
import 'package:comet/pages/personal/settings/settings_page.dart';
import 'package:comet/providers/user_data_provider.dart';
import 'package:intl/intl.dart';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';

String capitalizeEveryWord(String text) {
  if (text.isEmpty) return text;

  return text.split(' ').map((word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join(' ');
}

class PersonalPage extends StatefulWidget {
  const PersonalPage({Key? key}) : super(key: key);

  @override
  _PersonalPageState createState() => _PersonalPageState();
}

class _PersonalPageState extends State<PersonalPage> {
  int _selectedTab = 1; // Default to 'Today'
  bool _isLoading = false;

  Future<void> _refreshData(BuildContext context) async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    try {
      await Provider.of<UserDataProvider>(context, listen: false)
          .refreshUserData();
    } catch (e) {
      _showErrorDialog('Failed to refresh data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.rightToLeft,
            child: const SettingsPage(),
          ),
        );
      }
    } catch (e) {
      print('Error during logout: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to log out. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgcolor,
      appBar: AppBar(
        toolbarHeight: kToolbarHeight + MediaQuery.of(context).padding.top,
        automaticallyImplyLeading: false,
        backgroundColor: bgcolor,
        flexibleSpace: SafeArea(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              double height = kToolbarHeight * 1.4;
              double fontSize = height * 0.4;

              return Container(
                height: height,
                padding: EdgeInsets.symmetric(
                  horizontal: constraints.maxWidth * 0.05,
                  vertical: height * 0.1,
                ),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: yelloww,
                      width: 2.0,
                    ),
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Center(
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: Text(
                          'you.',
                          style: TextStyle(
                            fontFamily: 'Playwrite_HU',
                            fontSize: fontSize,
                            color: yelloww,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      child: IconButton(
                        icon: Icon(
                          Icons.settings,
                          color: yelloww,
                          size: fontSize,
                        ),
                        onPressed: () => _logout(context),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _refreshData(context),
          child: Consumer<UserDataProvider>(
            builder: (context, userDataProvider, child) {
              final userData = userDataProvider.userData;

              if (userData == null) {
                return _buildLoadingOrError();
              }

              return _buildContent(userData);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingOrError() {
    return Center(
      child: _isLoading
          ? const CircularProgressIndicator(color: yelloww)
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: yelloww),
                const SizedBox(height: 16),
                const Text(
                  'Failed to load user data',
                  style: TextStyle(color: yelloww, fontSize: 18),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _refreshData(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tile_color,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
    );
  }

  Widget _buildContent(UserModel userData) {
    return Column(
      children: [
        // GreetingWidget(),
        const SizedBox(height: 16),
        _buildSegmentedControl(),
        Expanded(
          child: Center(
            child: _buildSelectedTabContent(userData),
          ),
        ),
      ],
    );
  }

  Widget _buildSegmentedControl() {
    return CustomSlidingSegmentedControl<int>(
      initialValue: _selectedTab,
      innerPadding: const EdgeInsets.all(5),
      children: const {
        1: Text('Today',
            style: TextStyle(color: yelloww, fontFamily: 'Playwrite_HU')),
        2: Text('Signs',
            style: TextStyle(color: yelloww, fontFamily: 'Playwrite_HU')),
        // 3: Text('Chart',
        //     style: TextStyle(color: yelloww, fontFamily: 'Playwrite_HU')),
      },
      decoration: BoxDecoration(
        color: darkGreyy,
        borderRadius: BorderRadius.circular(8),
      ),
      thumbDecoration: BoxDecoration(
        color: bgcolor,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.3),
            blurRadius: 4.0,
            spreadRadius: 1.0,
            offset: const Offset(0.0, 2.0),
          ),
        ],
      ),
      duration: const Duration(milliseconds: 50),
      curve: Curves.easeInToLinear,
      onValueChanged: (v) {
        if (mounted) {
          setState(() {
            _selectedTab = v;
          });
        }
      },
    );
  }

  Widget _buildSelectedTabContent(UserModel userData) {
    // Implement this method based on your existing logic
    switch (_selectedTab) {
      case 1:
        return TodayTab(userData: userData);
      case 2:
        return SignsTab(userData: userData);
      case 3:
        return ChartTab(userData: userData);

      default:
        return Container(); // or some default widget
    }
  }
}

class TodayTab extends StatelessWidget {
  final UserModel userData;

  const TodayTab({Key? key, required this.userData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String today = DateFormat('MMMM d, yyyy').format(DateTime.now());
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        UserProfileHeader(userData: userData),
        Text(
          "Today, $today",
          style: const TextStyle(
            fontSize: 19,
            color: greyy,
            fontFamily: 'Manrope',
          ),
          textAlign: TextAlign.left,
        ),
        const SizedBox(height: 16),
        Text(
          userData.astroData.dailyHoroscope,
          style: const TextStyle(
            fontSize: 20,
            color: offwhite,
            fontFamily: 'Manrope',
          ),
          textAlign: TextAlign.left,
        ),
        const SizedBox(height: 24),
        const Text(
          "Deep Dive",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: greyy,
            fontFamily: 'Manrope',
          ),
          textAlign: TextAlign.left,
        ),
        const SizedBox(height: 8),
        Text(
          userData.astroData.detailedReading,
          textAlign: TextAlign.left,
          style: const TextStyle(
            fontSize: 16,
            color: offwhite,
            fontFamily: 'Manrope',
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class ChartTab extends StatelessWidget {
  final UserModel userData;

  const ChartTab({Key? key, required this.userData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String formattedBirthday = DateFormat('MMMM d, yyyy \'at\' h:mm a')
        .format(DateTime.parse(userData.dateOfBirth));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          "Your Birth Chart",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: whitee,
            fontFamily: 'Manrope',
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Text(
          formattedBirthday,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: yelloww,
            fontFamily: 'Manrope',
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          userData.placeOfBirth,
          style: const TextStyle(
            fontSize: 18,
            color: whitee,
            fontFamily: 'Manrope',
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        const Text(
          "Birth Chart Placeholder",
          style: TextStyle(
            fontSize: 18,
            color: whitee,
            fontFamily: 'Manrope',
          ),
          textAlign: TextAlign.center,
        ),
        // TODO: Replace with actual birth chart image
        // Image.asset('assets/birthchart.png'),
      ],
    );
  }
}

class SignsTab extends StatelessWidget {
  final UserModel userData;

  const SignsTab({Key? key, required this.userData}) : super(key: key);

  String formatPlanetName(String name) {
    return name.replaceAll('_', ' ').toUpperCase();
  }

  String formatBirthday(String isoString) {
    DateTime birthday = DateTime.parse(isoString);
    return DateFormat('MMMM d, yyyy').format(birthday);
  }

  String getSubtitle(String isoString) {
    DateTime birthday = DateTime.parse(isoString);
    if (birthday.month % 2 == 0) {
      return "ngl your signs say you're cooked";
    } else {
      return "Your stars are aligned for greatness.";
    }
  }

  @override
  Widget build(BuildContext context) {
    // Format the birthday
    String formattedBirthday = formatBirthday(userData.dateOfBirth);
    String subtitle = getSubtitle(userData.dateOfBirth);
    String name = capitalizeEveryWord(
      userData.name,
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          name,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey[300],
            fontFamily: 'Playwrite_HU',
          ),
          textAlign: TextAlign.center,
        ),
        // const SizedBox(height: 8),
        Text(
          formattedBirthday,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.grey[300],
            fontFamily: 'Manrope',
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 16,
            // fontStyle: FontStyle.italic,
            color: Colors.grey[400],
            fontFamily: 'Manrope',
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Table(
          children: userData.astroData.planetSigns.entries.map((entry) {
            return TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    formatPlanetName(entry.key),
                    style: const TextStyle(
                      color: whitee,
                      fontFamily: 'Manrope',
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ColorFiltered(
                    colorFilter:
                        const ColorFilter.mode(yelloww, BlendMode.srcIn),
                    child: Image.asset(
                      'assets/icons/${entry.value.toLowerCase()}-icon.png',
                      width: 30,
                      height: 30,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    entry.value.toUpperCase(),
                    style: const TextStyle(
                      color: whitee,
                      fontFamily: 'Manrope',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
