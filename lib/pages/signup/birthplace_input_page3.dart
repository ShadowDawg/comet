import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:test1/colors.dart';
import 'package:test1/pages/signup/notification_permission_page4.dart';

class BirthplaceInputPage extends StatefulWidget {
  final DateTime birthday;

  BirthplaceInputPage({required this.birthday});

  @override
  _BirthplaceInputPageState createState() => _BirthplaceInputPageState();
}

class _BirthplaceInputPageState extends State<BirthplaceInputPage> {
  final _birthplaceController = TextEditingController();
  bool _isBirthplaceEntered = false;

  @override
  void initState() {
    super.initState();
    _birthplaceController.addListener(_updateBirthplaceStatus);
  }

  @override
  void dispose() {
    _birthplaceController.removeListener(_updateBirthplaceStatus);
    _birthplaceController.dispose();
    super.dispose();
  }

  void _updateBirthplaceStatus() {
    setState(() {
      _isBirthplaceEntered = _birthplaceController.text.trim().isNotEmpty;
    });
  }

  String calculateZodiacSign(DateTime birthday) {
    int month = birthday.month;
    int day = birthday.day;

    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) return 'Aries';
    if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) return 'Taurus';
    if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) return 'Gemini';
    if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) return 'Cancer';
    if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) return 'Leo';
    if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) return 'Virgo';
    if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) return 'Libra';
    if ((month == 10 && day >= 23) || (month == 11 && day <= 21))
      return 'Scorpio';
    if ((month == 11 && day >= 22) || (month == 12 && day <= 21))
      return 'Sagittarius';
    if ((month == 12 && day >= 22) || (month == 1 && day <= 19))
      return 'Capricorn';
    if ((month == 1 && day >= 20) || (month == 2 && day <= 18))
      return 'Aquarius';
    return 'Pisces';
  }

  void _navigateToNextPage() {
    if (_isBirthplaceEntered) {
      String zodiacSign = calculateZodiacSign(widget.birthday);
      Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.topToBottom,
          child: NotificationPermissionPage(
            birthday: widget.birthday,
            birthplace: _birthplaceController.text.trim(),
            zodiacSign: zodiacSign,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Please enter your place of birth before proceeding.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: offwhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: bgcolor),
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
                'Where were you born?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontFamily: 'Manrope',
                ),
              ),
              const SizedBox(height: 20),
              CupertinoTextField(
                controller: _birthplaceController,
                placeholder: 'Enter city',
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: bgcolor),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white10,
                ),
                placeholderStyle: const TextStyle(
                    color: Colors.black38, fontFamily: 'Manrope'),
                style:
                    const TextStyle(color: Colors.black, fontFamily: 'Manrope'),
              ),
              const Spacer(),
              Text(
                'Your data is used only for your personalized horoscopes and match-finding. It is never shared with third parties.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                  fontFamily: 'Manrope',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _navigateToNextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: bgcolor,
                  foregroundColor: offwhite,
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
