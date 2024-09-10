import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:page_transition/page_transition.dart';
import 'package:comet/colors.dart';
import 'package:comet/pages/signup/birth_time_input_page2.dart';

class BirthdayInputPage extends StatefulWidget {
  @override
  _BirthdayInputPageState createState() => _BirthdayInputPageState();
}

class _BirthdayInputPageState extends State<BirthdayInputPage> {
  DateTime _selectedDate = DateTime.now()
      .subtract(const Duration(days: 365 * 18)); // Default to 18 years ago
  bool _isDateSelected = false;

  void _onDateChanged(DateTime newDate) {
    if (mounted) {
      setState(() {
        _selectedDate = newDate;
        _isDateSelected = true;
      });
    }
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
      backgroundColor: bgcolor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        forceMaterialTransparency: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: greyy,
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
                  color: greyy,
                  fontFamily: 'Manrope',
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
              const SizedBox(height: 20),
              Text(
                'This data is needed for match-making and accurate horoscopes. It is not shared with third parties.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[400],
                  fontStyle: FontStyle.italic,
                  fontFamily: 'Manrope',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _navigateToNextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: yelloww,
                  foregroundColor: bgcolor,
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
