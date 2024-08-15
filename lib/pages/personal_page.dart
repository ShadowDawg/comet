import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test1/colors.dart';
import 'package:test1/pages/personal_page_widgets.dart';
import 'package:test1/providers/user_data_provider.dart';
import '../models/user_and_astro_data.dart';
import 'package:intl/intl.dart';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';

class PersonalPage extends StatefulWidget {
  const PersonalPage({Key? key}) : super(key: key);

  @override
  _PersonalPageState createState() => _PersonalPageState();
}

class _PersonalPageState extends State<PersonalPage> {
  int _selectedTab = 1; // Default to 'Map'

  @override
  Widget build(BuildContext context) {
    final userDataProvider = Provider.of<UserDataProvider>(context);
    final userData = userDataProvider.userData;

    if (userData == null) {
      return const Scaffold(
        backgroundColor: bgcolor,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: bgcolor,
      body: SafeArea(
        child: Column(
          children: [
            GreetingWidget(
              userName: userData.user.name,
              userData: userData,
            ),
            // SizedBox(height: MediaQuery.of(context).size.height * 0.021),
            const SizedBox(height: 16),
            // UserProfileHeader(userData: userData),
            CustomSlidingSegmentedControl<int>(
              initialValue: _selectedTab,
              innerPadding: const EdgeInsets.all(5),
              children: const {
                1: Text(
                  'Today',
                  style: TextStyle(
                    color: yelloww,
                    fontFamily: 'Playwrite_HU',
                  ),
                ),
                2: Text(
                  'Chart',
                  style: TextStyle(
                    color: yelloww,
                    fontFamily: 'Playwrite_HU',
                  ),
                ),
                3: Text(
                  'Signs',
                  style: TextStyle(
                    color: yelloww,
                    fontFamily: 'Playwrite_HU',
                  ),
                ),
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
                    offset: const Offset(
                      0.0,
                      2.0,
                    ),
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
            ),
            Expanded(
              child: _buildSelectedTabContent(userData),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedTabContent(UserAndAstroData userData) {
    switch (_selectedTab) {
      case 1:
        return _buildToday(userData);
      case 2:
        return _buildChart(userData);
      case 3:
        return _buildSigns(userData);
      default:
        return Container(); // This should never happen
    }
  }

  Widget _buildSigns(UserAndAstroData userData) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          "Your Planetary Positions",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: whitee,
            fontFamily: 'Manrope',
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Table(
          border: TableBorder.all(color: whitee.withOpacity(0.3)),
          children: [
            TableRow(
              decoration: BoxDecoration(color: yelloww.withOpacity(0.1)),
              children: ["Planet", "Sign", "Symbol"]
                  .map((text) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          text,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: whitee,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ))
                  .toList(),
            ),
            ...userData.astroData.planetSigns.entries.map((entry) {
              return TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      entry.key,
                      style: TextStyle(color: whitee),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      entry.value,
                      style: TextStyle(color: whitee),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
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
                ],
              );
            }).toList(),
          ],
        ),
      ],
    );
  }

  Widget _buildChart(UserAndAstroData userData) {
    // Format the birthday to include date and time
    String formattedBirthday = DateFormat('MMMM d, yyyy \'at\' h:mm a')
        .format(DateTime.parse(userData.user.dateOfBirth));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
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
        // Text(
        //   "Born on",
        //   style: TextStyle(
        //     fontSize: 18,
        //     color: whitee,
        //     fontFamily: 'Manrope',
        //   ),
        //   textAlign: TextAlign.center,
        // ),
        // SizedBox(height: 8),
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
        // SizedBox(height: 16),
        Text(
          "${userData.user.placeOfBirth}",
          style: TextStyle(
            fontSize: 18,
            color: whitee,
            fontFamily: 'Manrope',
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        // Placeholder for the birth chart image
        Text(
          "Birth Chart Placeholder",
          style: TextStyle(
            fontSize: 18,
            color: whitee,
            fontFamily: 'Manrope',
          ),
          textAlign: TextAlign.center,
        ),
        // You would replace this with an actual image of the birth chart
        // Image.asset('assets/birthchart.png'),
      ],
    );
  }

  Widget _buildToday(UserAndAstroData userData) {
    String today = DateFormat('MMMM d, yyyy').format(DateTime.now());
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        UserProfileHeader(userData: userData),
        Text(
          "Today, $today",
          style: TextStyle(
            fontSize: 22,
            color: whitee,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          userData.astroData.dailyHoroscope,
          style: TextStyle(
            fontSize: 20,
            color: whitee,
            fontFamily: 'Manrope',
          ),
          textAlign: TextAlign.left,
        ),
        const SizedBox(height: 24),
        Text(
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
          style: TextStyle(
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
