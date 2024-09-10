import 'package:flutter/material.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:comet/colors.dart';

class EditBirthplacePage extends StatefulWidget {
  final String currentBirthplace;

  const EditBirthplacePage({Key? key, required this.currentBirthplace})
      : super(key: key);

  @override
  _EditBirthplacePageState createState() => _EditBirthplacePageState();
}

class _EditBirthplacePageState extends State<EditBirthplacePage> {
  final TextEditingController _birthplaceController = TextEditingController();
  Prediction? _placePrediction;

  @override
  void initState() {
    super.initState();
    _birthplaceController.text = widget.currentBirthplace;
  }

  @override
  void dispose() {
    _birthplaceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgcolor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Edit Birthplace', style: TextStyle(color: offwhite)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: greyy),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GooglePlaceAutoCompleteTextField(
                textEditingController: _birthplaceController,
                googleAPIKey: "AIzaSyDzOQdO-3whdfsgMPtAx-Wa4XNlr-iyB9M",
                textStyle:
                    const TextStyle(color: offwhite, fontFamily: "Manrope"),
                boxDecoration: const BoxDecoration(
                  color: darkGreyy,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                inputDecoration: const InputDecoration(
                  hintStyle: TextStyle(fontFamily: "Manrope", color: greyy),
                  hintText: "Enter your birth city/town",
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                ),
                debounceTime: 400,
                containerHorizontalPadding: 10,
                // countries: const ["in", "fr"],
                isLatLngRequired: true,
                getPlaceDetailWithLatLng: (Prediction prediction) {
                  print("placeDetails" + prediction.lat.toString());
                },
                itemClick: (Prediction prediction) {
                  _birthplaceController.text = prediction.description ?? "";
                  _placePrediction = prediction;
                  _birthplaceController.selection = TextSelection.fromPosition(
                    TextPosition(offset: _birthplaceController.text.length),
                  );
                },
                itemBuilder: (context, index, Prediction prediction) {
                  return Container(
                    decoration: const BoxDecoration(color: bgcolor),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 16),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: yelloww),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            prediction.description ?? "",
                            style: const TextStyle(
                                fontFamily: "Manrope", color: offwhite),
                          ),
                        )
                      ],
                    ),
                  );
                },
                isCrossBtnShown: true,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(
                      context,
                      _placePrediction?.structuredFormatting?.mainText ??
                          _birthplaceController.text);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: yelloww,
                  foregroundColor: bgcolor,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Save',
                    style: TextStyle(fontSize: 18, fontFamily: 'Manrope')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
