import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:test1/colors.dart';

class GreetingWidgetLove extends StatelessWidget {
  const GreetingWidgetLove({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // Use a default height if the constraint is undefined
        double height = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : MediaQuery.of(context).size.height * 0.1;

        double fontSize = height * 0.4; // Adjust this factor as needed

        return Container(
          height: height,
          padding: EdgeInsets.symmetric(
            vertical: height * 0.1,
            horizontal: constraints.maxWidth * 0.05,
          ),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Color(0xFFC0C0BE),
              ),
            ),
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.contain,
              child: Text(
                'love.',
                style: TextStyle(
                  fontFamily: 'Playwrite_HU',
                  fontSize: fontSize,
                  color: yelloww,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class MatchmakingInfoWidget extends StatelessWidget {
  const MatchmakingInfoWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.yellow.shade300,
            Colors.amber.shade700,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "The stars are about to align",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: bgcolor,
                fontFamily: 'Playwrite_HU',
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Every week, we consult the cosmos (and our algorithms) to find your celestial soulmate. Or at least someone who won't ghost you immediately.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontFamily: 'Manrope',
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.timer,
                        color: bgcolor,
                      ),
                      SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          "Every Wednesday 4:20PM",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: bgcolor,
                            fontFamily: "Manrope",
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
