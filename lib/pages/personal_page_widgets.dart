import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:test1/colors.dart';
import 'package:test1/models/user_and_astro_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:test1/pages/settings_page.dart';

class GreetingWidget extends StatelessWidget {
  final String userName;
  final UserAndAstroData userData;

  const GreetingWidget({
    Key? key,
    required this.userName,
    required this.userData,
  }) : super(key: key);

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.rightToLeft,
          child: const SettingsPage(),
        ),
      );
    } catch (e) {
      print('Error during logout: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to log out. Please try again.')),
      );
    }
  }

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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FittedBox(
                fit: BoxFit.contain,
                child: Text(
                  'you.',
                  style: TextStyle(
                    fontFamily: 'Playwrite_HU',
                    fontSize: fontSize,
                    color: yelloww,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.settings,
                  color: yelloww,
                  size: fontSize,
                ),
                onPressed: () => _logout(context),
              ),
            ],
          ),
        );
      },
    );
  }
}

class UserProfileHeader extends StatelessWidget {
  final UserAndAstroData userData;

  const UserProfileHeader({Key? key, required this.userData}) : super(key: key);

  Widget _buildSignRow(String iconPath, String sign) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          iconPath,
          width: 16,
          height: 16,
          color: yelloww,
          colorBlendMode: BlendMode.srcIn,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            sign,
            style: const TextStyle(color: Colors.white),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: darkGreyy,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(userData.user.photoUrl),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "@${userData.user.handle}",
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        _buildSignRow('assets/icons/sun-icon.png',
                            userData.astroData.planetSigns["sun"]),
                        _buildSignRow('assets/icons/moon-icon.png',
                            userData.astroData.planetSigns["moon"]),
                        _buildSignRow('assets/icons/ascendant-icon.png',
                            userData.astroData.planetSigns["ascendant"]),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
