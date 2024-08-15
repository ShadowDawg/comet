import 'package:flutter/material.dart';
import 'package:test1/colors.dart';

class GreetingWidgetLove extends StatelessWidget {
  const GreetingWidgetLove({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height:
          MediaQuery.of(context).size.height * 0.10, // 15% of the screen height
      padding: const EdgeInsets.all(16), // Padding inside the container
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFC0C0BE), // Colored bottom border
          ),
        ),
      ),
      alignment:
          Alignment.center, // Centers the text horizontally and vertically
      child: const Text(
        'love.',
        style: TextStyle(
          fontFamily: 'Playwrite_HU', fontSize: 30, color: yelloww,
          fontWeight:
              FontWeight.bold, // Uncomment if you decide to make the text bold
        ),
      ),
    );
  }
}

class MatchmakingInfoWidget extends StatelessWidget {
  const MatchmakingInfoWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "The stars are going to align",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: whitee, // Assuming 'whitee' is defined in your colors file
              fontFamily: 'Playwrite_HU',
            ),
          ),
          SizedBox(height: 16),
          Text(
            "Every week, we consult the cosmos (and our algorithms) to find your celestial soulmate. Or at least someone who won't ghost you immediately.",
            style:
                TextStyle(fontSize: 16, color: whitee, fontFamily: 'Manrope'),
          ),
          SizedBox(height: 24),
          Text(
            "Next matchmaking: Wednesday at 6:00 PM",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: whitee,
            ),
          ),
        ],
      ),
    );
  }
}
