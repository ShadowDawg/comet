import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:page_transition/page_transition.dart';
import 'package:test1/colors.dart';
import 'package:test1/pages/signup/birthplace_input_page3.dart';

class BirthTimeInputPage extends StatefulWidget {
  final DateTime birthday;

  BirthTimeInputPage({required this.birthday});

  @override
  _BirthTimeInputPageState createState() => _BirthTimeInputPageState();
}

class _BirthTimeInputPageState extends State<BirthTimeInputPage> {
  late DateTime _selectedDateTime;
  bool _isTimeSelected = false;

  @override
  void initState() {
    super.initState();
    _selectedDateTime = widget.birthday;
  }

  void _onTimeChanged(DateTime newTime) {
    setState(() {
      _selectedDateTime = DateTime(
        _selectedDateTime.year,
        _selectedDateTime.month,
        _selectedDateTime.day,
        newTime.hour,
        newTime.minute,
      );
      _isTimeSelected = true;
    });
  }

  void _navigateToNextPage() {
    if (_isTimeSelected) {
      Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.rightToLeft,
          child: BirthplaceInputPage(birthday: _selectedDateTime),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select your birth time before proceeding.')),
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
        elevation: 0,
        forceMaterialTransparency: true,
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
                'What time were you born?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  // color: Colors.black87,
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
                            // color: Colors.black87,
                            color: yelloww, // dark
                            fontSize: 20,
                            fontFamily: 'Manrope',
                          ),
                        ),
                      ),
                      child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.time,
                        initialDateTime: _selectedDateTime,
                        use24hFormat:
                            false, // Set to true if you prefer 24-hour format
                        onDateTimeChanged: _onTimeChanged,
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
