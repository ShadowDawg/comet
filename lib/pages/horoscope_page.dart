import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test1/colors.dart';
import 'package:test1/pages/horoscope_widgets.dart';
import 'package:test1/providers/user_data_provider.dart';
import '../models/user_and_astro_data.dart'; // Adjust the path to where your UserModel is located

class HoroscopePage extends StatelessWidget {
  HoroscopePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userDataProvider = Provider.of<UserDataProvider>(context);
    final UserAndAstroData? userData = userDataProvider.userData;

    if (userData == null) {
      // Handle the case where userData is not available
      return const Scaffold(
        backgroundColor: bgcolor,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    double avatarRadius = MediaQuery.of(context).size.width * 0.15;
    return Scaffold(
      backgroundColor: bgcolor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              GreetingWidget(userName: userData.user.name),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: HoroscopeCard(
                  photoUrl: userData.user.photoUrl,
                  avatarRadius: avatarRadius,
                  horoscope: userData.astroData.dailyHoroscope,
                  // horoscope: "Your friendships are as solid as your cg—prepare for a breakup when exams hit.",
                  userName: userData.user.name,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              // ActionTable(tableData: tableData),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Card(
                  color: yelloww,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Text(
                        //   "Do's and Don'ts",
                        //   style: Theme.of(context).textTheme.titleLarge,
                        // ),
                        // SizedBox(height: 16),
                        ActionTable(tableData: userData.astroData.actionTable),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              // Bottom nav bar
            ],
          ),
        ),
      ),
    );
  }
}

class ActionTable extends StatelessWidget {
  final Map<String, List<String>> tableData;

  const ActionTable({
    Key? key,
    required this.tableData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double fontSizeEntry = MediaQuery.of(context).size.width * 0.05;
    double fontSizeHeader = MediaQuery.of(context).size.width * 0.08;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: Icon(
                Icons.done_rounded,
                size: fontSizeHeader,
                color: Colors.green,
              ),
            ),
            Expanded(
              child: Icon(
                Icons.cancel_rounded,
                size: fontSizeHeader,
                color: Colors.red,
              ),
            ),
          ],
        ),
        for (int i = 0; i < (tableData['yes']?.length ?? 0); i++)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: Text(
                  tableData['yes']?[i] ?? '',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Lora',
                    fontSize: fontSizeEntry,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  tableData['no']?[i] ?? '',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Lora',
                    fontSize: fontSizeEntry,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
