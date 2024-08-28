import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test1/colors.dart';
// import 'package:test1/pages/horoscope_widgets.dart';
import 'package:test1/pages/personal_page_widgets.dart';
import 'package:test1/providers/user_data_provider.dart';
import '../models/user_and_astro_data.dart';
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
    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<UserDataProvider>(context, listen: false)
          .refreshUserData();
    } catch (e) {
      _showErrorDialog('Failed to refresh data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgcolor,
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

  Widget _buildContent(UserAndAstroData userData) {
    return Column(
      children: [
        GreetingWidget(
          userName: userData.user.name,
          userData: userData,
        ),
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
        color: tile_color,
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
        setState(() {
          _selectedTab = v;
        });
      },
    );
  }

  Widget _buildSelectedTabContent(UserAndAstroData userData) {
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
  final UserAndAstroData userData;

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
            fontSize: 22,
            color: whitee,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          userData.astroData.dailyHoroscope,
          style: const TextStyle(
            fontSize: 20,
            color: whitee,
            fontFamily: 'Manrope',
          ),
          textAlign: TextAlign.left,
        ),
        const SizedBox(height: 24),
        const Text(
          "Detailed Reading",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: whitee,
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
            color: whitee,
            fontFamily: 'Manrope',
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class ChartTab extends StatelessWidget {
  final UserAndAstroData userData;

  const ChartTab({Key? key, required this.userData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String formattedBirthday = DateFormat('MMMM d, yyyy \'at\' h:mm a')
        .format(DateTime.parse(userData.user.dateOfBirth));

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
          userData.user.placeOfBirth,
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
  final UserAndAstroData userData;

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
      return "Your stars are aligned for greatness!";
    }
  }

  @override
  Widget build(BuildContext context) {
    // Format the birthday
    String formattedBirthday = formatBirthday(userData.user.dateOfBirth);
    String subtitle = getSubtitle(userData.user.dateOfBirth);
    String name = capitalizeEveryWord(
      userData.user.name,
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
