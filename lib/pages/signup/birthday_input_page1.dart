import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:page_transition/page_transition.dart';
import 'package:test1/colors.dart';
import 'package:test1/pages/signup/birth_time_input_page2.dart';

class BirthdayInputPage extends StatefulWidget {
  @override
  _BirthdayInputPageState createState() => _BirthdayInputPageState();
}

class _BirthdayInputPageState extends State<BirthdayInputPage> {
  DateTime _selectedDate = DateTime.now()
      .subtract(const Duration(days: 365 * 18)); // Default to 18 years ago
  bool _isDateSelected = false;

  void _onDateChanged(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
      _isDateSelected = true;
    });
  }

  void _navigateToNextPage() {
    if (_isDateSelected) {
      Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.rightToLeft,
          child: BirthTimeInputPage(birthday: _selectedDate),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select your birthday before proceeding.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: offwhite,
      backgroundColor: bgcolor, // dark
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        forceMaterialTransparency: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            // color: bgcolor,
            color: greyy, // dark
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'When were you born?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  // color: Colors.black87,
                  color: greyy, // dark
                  fontFamily: 'Manrope',
                ),
              ),
              const SizedBox(
                  height: 8), // Add some space between title and subtitle
              const Text(
                'We\'ll remember to wish you happy bday :)',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors
                      .white54, // Using yellow for contrast, adjust as needed
                  fontFamily: 'Manrope',
                  // fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Center(
                  child: Container(
                    height: 200,
                    child: CupertinoTheme(
                      data: const CupertinoThemeData(
                        textTheme: CupertinoTextThemeData(
                          dateTimePickerTextStyle: TextStyle(
                            // color: Colors.black87,
                            color: yelloww,
                            fontSize: 20,
                            fontFamily: 'Manrope',
                          ),
                        ),
                      ),
                      child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.date,
                        initialDateTime: _selectedDate,
                        maximumDate: DateTime.now(),
                        minimumYear: 1900,
                        maximumYear: DateTime.now().year,
                        onDateTimeChanged: _onDateChanged,
                      ),
                    ),
                  ),
                ),
              ),
              // Text(
              //   'Your data is used only for your personalized horoscopes and match-finding. It is never shared with third parties.',
              //   style: TextStyle(
              //     fontSize: 14,
              //     color: Colors.grey[600],
              //     fontStyle: FontStyle.italic,
              //     fontFamily: 'Manrope',
              //   ),
              // ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _navigateToNextPage,
                style: ElevatedButton.styleFrom(
                  // backgroundColor: bgcolor,
                  backgroundColor: yelloww, // dark
                  // foregroundColor: offwhite,
                  foregroundColor: bgcolor, // dark
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Next',
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Manrope',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
