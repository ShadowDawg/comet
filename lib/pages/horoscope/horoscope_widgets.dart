import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:comet/colors.dart';

String capitalizeEveryWord(String text) {
  if (text.isEmpty) return text;

  return text.split(' ').map((word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join(' ');
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
    String capitalizedName = capitalizeEveryWord(userName);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: bgcolor,
      child: Padding(
        // padding: const EdgeInsets.all(16.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '${_getGreeting()}, $capitalizedName',
              style: const TextStyle(
                fontSize: 20,
                fontFamily: 'Playwrite_HU',
                color: offwhite,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _getTodayInfo(),
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'Manrope',
                color: greyy,
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
          color: offwhite,
        ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.visible,
        maxLines: null, // Allows for unlimited lines
      ),
    );
  }
}
