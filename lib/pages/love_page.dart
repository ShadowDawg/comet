import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test1/backend/firebase_tools.dart';
import 'package:test1/colors.dart';
import 'package:test1/pages/chat_page.dart';
import 'package:test1/pages/love_page_widgets.dart';
import 'package:test1/providers/user_data_provider.dart';
import '../models/user_and_astro_data.dart'; // Ensur your UserModel correctly

class LovePage extends StatelessWidget {
  const LovePage({Key? key}) : super(key: key);

  void _startChatting(BuildContext context, UserAndAstroData userData) {
    // update matchApproved and take to chat page.

    // Update locally first
    final userDataProvider =
        Provider.of<UserDataProvider>(context, listen: false);
    userDataProvider.updateUserData((currentData) => currentData.copyWith(
        astroData: currentData.astroData.copyWith(matchApproved: true)));

    // Then call the function to update on the server
    backendFirebaseUpdateMatchApproved(userData.user.uid, true);
    print("Updated firebase");

    // Navigate to ChatPage
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(userData: userData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userDataProvider = Provider.of<UserDataProvider>(context);
    final userData = userDataProvider.userData;

    if (userData == null) {
      return const Scaffold(
        backgroundColor: bgcolor,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (userData.astroData.matchUid.isNotEmpty &&
        userData.astroData.matchApproved) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(userData: userData),
          ),
        );
      });
    }

    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Love'),
      // ),
      backgroundColor: bgcolor,
      body: buildContentBasedOnUser(context, userData),
    );
  }

  Widget buildContentBasedOnUser(
      BuildContext context, UserAndAstroData userData) {
    if (userData.astroData.matchUid.isEmpty) {
      return const SafeArea(
        child: Column(
          children: [
            GreetingWidgetLove(),
            MatchmakingInfoWidget(),
          ],
        ),
      );
    } else if (!userData.astroData.matchApproved) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return SafeArea(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const GreetingWidgetLove(),
                      Padding(
                        // padding: const EdgeInsets.all(16.0),
                        padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
                        child: Text(
                          "The stars have aligned✨",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            // fontSize: 24,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: whitee,
                            // fontFamily: 'Playwrite_HU',
                            fontFamily: 'Manrope',
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          //color: yelloww,
                          margin: const EdgeInsets.all(8),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              FutureBuilder<UserAndAstroData>(
                                future: backendFirebaseGetUserAndAstroData(
                                    userData.astroData.matchUid),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return const Text(
                                        "Error loading match details");
                                  } else if (snapshot.hasData) {
                                    UserAndAstroData matchUser = snapshot.data!;
                                    return MatchCard(
                                      userData: userData,
                                      matchUser: matchUser,
                                      onStartChatting: () =>
                                          _startChatting(context, userData),
                                    );
                                  } else {
                                    return const Text(
                                        "No match data available");
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    } else {
      return Container(); // Placeholder for redirection logic
    }
  }

  // Additional match making stuff to add
  // calculateCompatibility(String zodiacSign, String zodiacSign2) {}

  // String getZodiacTraits(String zodiacSign) {
  //   return "funny";
  // }

  // String getRelationshipPotential(String zodiacSign, String zodiacSign2) {
  //   return "funny";
  // }
}

class MatchCard extends StatelessWidget {
  final UserAndAstroData userData;
  final UserAndAstroData matchUser;
  final VoidCallback onStartChatting;

  const MatchCard({
    Key? key,
    required this.userData,
    required this.matchUser,
    required this.onStartChatting,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      color: yelloww,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // _buildZodiacPictures(context),
            // const SizedBox(height: 16),
            _buildMatchInfo(context),
            const SizedBox(height: 24),
            // _buildCompatibilityInfo(context),
            // const SizedBox(height: 16),
            // _buildPersonalityTraits(context),
            // const SizedBox(height: 24),
            _buildConversationStarters(context),
            const SizedBox(height: 24),
            _buildStartChattingButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildZodiacPictures(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/icons/${userData.astroData.planetSigns["sun"]}-icon.png',
          width: 60,
          height: 60,
        ),
        const SizedBox(width: 16),
        Icon(Icons.favorite, color: Theme.of(context).primaryColor, size: 40),
        const SizedBox(width: 16),
        Image.asset(
          'assets/icons/${matchUser.astroData.planetSigns["sun"]}-icon.png',
          width: 60,
          height: 60,
        ),
      ],
    );
  }

  Widget _buildMatchInfo(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUserInfo(context, userData),
        Container(
          height: 150,
          width: 1,
          color: Colors.grey,
        ),
        _buildUserInfo(context, matchUser),
      ],
    );
  }

  Widget _buildUserInfo(BuildContext context, UserAndAstroData user) {
    return Expanded(
      child: Column(
        children: [
          CircleAvatar(
            radius: MediaQuery.of(context).size.width * 0.1,
            backgroundImage: NetworkImage(user.user.photoUrl),
          ),
          const SizedBox(height: 8),
          Text(
            user.user.name,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          Text(
            "@${user.user.handle}",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).hintColor,
                ),
            textAlign: TextAlign.center,
          ),
          Text(
            "${user.astroData.planetSigns["sun"]}",
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          Text(
            user.user.placeOfBirth,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCompatibilityInfo(BuildContext context) {
    return Text(
      getCompatibilityOneLiner(userData.astroData.planetSigns["sun"],
          matchUser.astroData.planetSigns["sun"]),
      style: Theme.of(context).textTheme.bodyMedium,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildPersonalityTraits(BuildContext context) {
    return Column(
      children: getPersonalityTraits(matchUser.astroData.planetSigns["sun"])
          .map(
            (trait) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                "• $trait",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildConversationStarters(BuildContext context) {
    return Column(
      children: [
        Text(
          "Talk about",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        ...getConversationStarters(matchUser.astroData.planetSigns["sun"])
            .take(3)
            .map(
              (starter) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  "• $starter",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
      ],
    );
  }

  Widget _buildStartChattingButton(BuildContext context) {
    return ElevatedButton(
      onPressed: onStartChatting,
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: Text('Start chatting...', style: TextStyle(fontSize: 18)),
      ),
    );
  }

  String getCompatibilityOneLiner(String userSign, String matchSign) {
    return "Your $userSign energy beautifully complements their $matchSign nature!";
  }

  List<String> getPersonalityTraits(String sign) {
    switch (sign.toLowerCase()) {
      case 'aries':
        return ['Energetic', 'Courageous', 'Confident'];
      case 'taurus':
        return ['Reliable', 'Patient', 'Determined'];
      default:
        return ['Mysterious', 'Unique', 'Intriguing'];
    }
  }

  List<String> getConversationStarters(String sign) {
    switch (sign.toLowerCase()) {
      case 'aries':
        return [
          "What's the most adventurous thing you've done recently?",
          "If you could compete in any sport, what would it be?",
          "What's a goal you're currently working towards?"
        ];
      case 'taurus':
        return [
          "What's your favorite way to relax after a long day?",
          "If you could master any craft or art form, what would it be?",
          "What's the best meal you've ever had?"
        ];
      default:
        return ["Books", "Food", "Football"];
    }
  }
}
