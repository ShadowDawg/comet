import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:test1/colors.dart';
import 'package:test1/models/user_and_astro_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:test1/pages/settings_page.dart';

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
