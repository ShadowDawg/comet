import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:test1/colors.dart';

String capitalizeFirstLetter(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1);
}

class HoroscopeCard extends StatelessWidget {
  final String photoUrl;
  final double avatarRadius;
  final String horoscope;
  final String userName;

  const HoroscopeCard({
    Key? key,
    required this.photoUrl,
    required this.avatarRadius,
    required this.horoscope,
    required this.userName,
  }) : super(key: key);

  String _getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  String _getTodayInfo() {
    final now = DateTime.now();
    final dayName = DateFormat('EEEE').format(now);
    final monthName = DateFormat('MMMM').format(now);
    final day = DateFormat('d').format(now);
    return "It's $dayName, $monthName $day. Today at a glance:";
  }

  @override
  Widget build(BuildContext context) {
    String capitalizedName = capitalizeFirstLetter(userName);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: bgcolor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '${_getGreeting()}, $capitalizedName',
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'Playwrite_HU',
                color: whitee,
              ),
            ),
            SizedBox(height: 8),
            Text(
              _getTodayInfo(),
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Manrope',
                color: whitee.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Center(child: UserAvatar(photoUrl: photoUrl, radius: avatarRadius)),
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            HoroscopeText(horoscope: horoscope),
          ],
        ),
      ),
    );
  }
}

class GreetingWidget extends StatelessWidget {
  final String userName;

  const GreetingWidget({
    Key? key,
    required this.userName,
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
        // 'Good evening $userName',
        // 'Good evening Anusha', // TODO remove placeholder for landing page
        'comet.',
        style: TextStyle(
          fontFamily: 'Playwrite_HU', fontSize: 30, color: yelloww,
          fontWeight:
              FontWeight.bold, // Uncomment if you decide to make the text bold
        ),
      ),
    );
  }
}

class UserAvatar extends StatelessWidget {
  final String photoUrl;
  final double radius;

  const UserAvatar({
    Key? key,
    required this.photoUrl,
    required this.radius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundImage: NetworkImage(photoUrl),
      backgroundColor:
          Colors.transparent, // Optional: handle default/fallback colors
    );
  }
}

// class HoroscopeText extends StatelessWidget {
//   final String horoscope;

//   const HoroscopeText({
//     Key? key,
//     required this.horoscope,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       alignment: Alignment.center,
//       height:
//           MediaQuery.of(context).size.height * 0.1, // 10% of the screen height
//       child: Padding(
//         padding: const EdgeInsets.symmetric(
//             horizontal: 20.0), // Horizontal padding of 20.0 units on each side
//         child: Text(
//           horoscope, // Uses the passed horoscope text
//           style: TextStyle(
//             fontFamily: 'Lora',
//             fontSize: MediaQuery.of(context).size.width *
//                 0.055, // Proportional font size
//             fontWeight: FontWeight.w600,
//           ),
//           textAlign: TextAlign.center,
//         ),
//       ),
//     );
//   }
// }

class HoroscopeText extends StatelessWidget {
  final String horoscope;

  const HoroscopeText({Key? key, required this.horoscope}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        horoscope,
        style: TextStyle(
            fontFamily: 'Lora',
            // fontFamily: 'Geist'
            // fontFamily: 'space',
            // fontFamily: 'Manrope',
            // fontFamily: 'Helvetica',
            fontSize: MediaQuery.of(context).size.width *
                0.055, // Proportional font size
            fontWeight: FontWeight.w200,
            letterSpacing: 1,
            color: Color(0xFFFEFFFE)),
        textAlign: TextAlign.center,
        overflow: TextOverflow.visible,
        maxLines: null, // Allows for unlimited lines
      ),
    );
  }
}
