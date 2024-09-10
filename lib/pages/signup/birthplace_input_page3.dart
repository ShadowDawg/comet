import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
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
  Prediction? _placePrediction;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _birthplaceController.addListener(_updateBirthplaceStatus);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  void dispose() {
    _birthplaceController.removeListener(_updateBirthplaceStatus);
    _birthplaceController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _updateBirthplaceStatus() {
    if (mounted) {
      setState(() {
        _isBirthplaceEntered = _birthplaceController.text.trim().isNotEmpty;
      });
    }
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
    if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) {
      return 'Scorpio';
    }
    if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) {
      return 'Sagittarius';
    }
    if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) {
      return 'Capricorn';
    }
    if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) {
      return 'Aquarius';
    }
    return 'Pisces';
  }

  void _navigateToNextPage() {
    if (_isValidSelection()) {
      String zodiacSign = calculateZodiacSign(widget.birthday);
      Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.rightToLeft,
          child: NotificationPermissionPage(
            birthday: widget.birthday,
            birthplace: _placePrediction?.structuredFormatting?.mainText ?? "",
            zodiacSign: zodiacSign,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Please select a location from the suggestions before proceeding.'),
        ),
      );
    }
  }

  bool _isValidSelection() {
    return _placePrediction != null && _birthplaceController.text != "";
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
                'Where were you born?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  // color: Colors.black87,
                  color: greyy,
                  fontFamily: 'Manrope',
                ),
              ),
              // const SizedBox(
              //     height: 8), // Add some space between title and subtitle
              // const Text(
              //   'Yeah this too lmao',
              //   style: TextStyle(
              //     fontSize: 16,
              //     color: Colors
              //         .white54, // Using yellow for contrast, adjust as needed
              //     fontFamily: 'Manrope',
              //     // fontStyle: FontStyle.italic,
              //   ),
              // ),
              const SizedBox(height: 20),
              GooglePlaceAutoCompleteTextField(
                focusNode: _focusNode,
                textEditingController: _birthplaceController,
                googleAPIKey: "AIzaSyDzOQdO-3whdfsgMPtAx-Wa4XNlr-iyB9M",
                textStyle: const TextStyle(
                  color: offwhite,
                  fontFamily: "Manrope",
                ),
                boxDecoration: const BoxDecoration(
                  color: darkGreyy,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                inputDecoration: const InputDecoration(
                  hintStyle: TextStyle(
                    fontFamily: "Manrope",
                    color: greyy,
                  ),
                  hintText: "Enter your birth city/town",
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                ),
                debounceTime: 400,
                // countries: ["in", "fr"],
                isLatLngRequired: true,
                getPlaceDetailWithLatLng: (Prediction prediction) {
                  print("placeDetails" + prediction.lat.toString());
                },

                itemClick: (Prediction prediction) {
                  _birthplaceController.text = prediction.description ?? "";
                  _placePrediction = prediction;
                  // Safely set cursor to the end of the text
                  _birthplaceController.selection = TextSelection.fromPosition(
                    TextPosition(offset: _birthplaceController.text.length),
                  );
                  print("PLACE LAT: ${prediction.lat}");
                  print(prediction.lng);
                  print(prediction.toJson());
                },
                // seperatedBuilder: const Divider(),
                containerHorizontalPadding: 10,
                seperatedBuilder: null,

                // OPTIONAL// If you want to customize list view item builder
                itemBuilder: (context, index, Prediction prediction) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: bgcolor,
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 16),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: yelloww,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            prediction.description ?? "",
                            style: const TextStyle(
                              fontFamily: "Manrope",
                              color: offwhite,
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                },

                isCrossBtnShown: true,

                // default 600 ms ,
              ),
              const Spacer(),
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
                  // backgroundColor: bgcolor,
                  backgroundColor: yelloww,
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
