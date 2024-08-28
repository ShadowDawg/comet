import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test1/backend/firebase_tools.dart';
import 'package:test1/colors.dart';
import 'package:test1/pages/chat_page.dart';
import 'package:test1/pages/love_page_widgets.dart';
import 'package:test1/providers/user_data_provider.dart';
import '../models/user_and_astro_data.dart'; // Ensur your UserModel correctly

class LovePage extends StatefulWidget {
  const LovePage({Key? key}) : super(key: key);

  @override
  _LovePageState createState() => _LovePageState();
}

class _LovePageState extends State<LovePage> {
  bool _isLoading = false;

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<UserDataProvider>(context, listen: false)
          .refreshUserData();
    } catch (e) {
      _showErrorDialog('Failed to refresh data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _startChatting(BuildContext context, UserAndAstroData userData) async {
    setState(() {
      _isLoading = true;
    });
    try {
      // Update locally first
      final userDataProvider =
          Provider.of<UserDataProvider>(context, listen: false);
      userDataProvider.updateUserData((currentData) => currentData.copyWith(
          astroData: currentData.astroData.copyWith(matchApproved: true)));

      // Then update on the server
      await backendFirebaseUpdateMatchApproved(userData.user.uid, true);

      // Navigate to ChatPage
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatPage(userData: userData),
        ),
      );
    } catch (e) {
      _showErrorDialog('Failed to start chatting: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgcolor,
      appBar: AppBar(
        toolbarHeight: kToolbarHeight + MediaQuery.of(context).padding.top,
        automaticallyImplyLeading: false,
        backgroundColor: bgcolor,
        flexibleSpace: SafeArea(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              // double height = constraints.maxHeight.isFinite
              //     ? constraints.maxHeight
              //     : MediaQuery.of(context).size.height * 0.1;
              double height = kToolbarHeight * 1.4;
              double fontSize = height * 0.4;

              return Container(
                height: height,
                padding: EdgeInsets.symmetric(
                  horizontal: constraints.maxWidth * 0.05,
                  vertical: height * 0.1,
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
                        color: yelloww, // Ensure this color is defined
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return Consumer<UserDataProvider>(
      builder: (context, userDataProvider, child) {
        if (userDataProvider.isLoading || _isLoading) {
          return LoadingWidget();
        }

        final userData = userDataProvider.userData;

        if (userData == null) {
          return _buildErrorWidget(
              'Unable to load user data. Please try again.');
        }

        if (userData.astroData.matchUid.isNotEmpty &&
            userData.astroData.matchApproved) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ChatPage(userData: userData),
              ),
            );
          });
          return Container(); // This will be replaced immediately
        }

        return _buildContentBasedOnUser(context, userData);
      },
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: CircularProgressIndicator(color: whitee),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: whitee),
          const SizedBox(height: 16),
          const Text(
            'Oops! Something went wrong.',
            style:
                TextStyle(color: whitee, fontSize: 18, fontFamily: 'Manrope'),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
                color: whitee, fontSize: 14, fontFamily: 'Manrope'),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _refreshData,
            style: ElevatedButton.styleFrom(backgroundColor: yelloww),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildContentBasedOnUser(
      BuildContext context, UserAndAstroData userData) {
    if (userData.astroData.matchUid.isEmpty) {
      print("hmm");
      return const SafeArea(
        child: Column(
          children: [
            //GreetingWidgetLove(),
            MatchmakingInfoWidget(),
          ],
        ),
      );
    } else if (!userData.astroData.matchApproved) {
      return _buildMatchFoundContent(context, userData);
    } else {
      return Container(); // This case should be handled earlier, but keeping it for safety
    }
  }

  Widget _buildMatchFoundContent(
      BuildContext context, UserAndAstroData userData) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top,
          ),
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(
                  "The stars have aligned✨",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    // fontWeight: FontWeight.bold,
                    color: offwhite,
                    fontFamily: 'Manrope',
                  ),
                ),
              ),
              FutureBuilder<UserAndAstroData>(
                future: backendFirebaseGetUserAndAstroData(
                    userData.astroData.matchUid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // return const CircularProgressIndicator(color: whitee);
                    return LoadingWidget();
                  } else if (snapshot.hasError) {
                    return Text(
                        "Error loading match details: ${snapshot.error}",
                        style: const TextStyle(color: whitee));
                  } else if (snapshot.hasData) {
                    UserAndAstroData matchUser = snapshot.data!;
                    return MatchCard(
                      userData: userData,
                      matchUser: matchUser,
                      onStartChatting: () => _startChatting(context, userData),
                    );
                  } else {
                    return const Text("No match data available",
                        style: TextStyle(color: whitee));
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoadingWidget extends StatefulWidget {
  @override
  _LoadingWidgetState createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget> {
  bool _showConnectivityWarning = false;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 5), () {
      setState(() {
        _showConnectivityWarning = true;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bgcolor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: whitee),
            const SizedBox(height: 20),
            Text(
              _showConnectivityWarning
                  ? "Yo check yo wifi"
                  : "Listening to the stars...",
              style: const TextStyle(
                color: whitee,
                fontSize: 18,
                fontFamily: 'Manrope',
              ),
            ),
          ],
        ),
      ),
    );
  }
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
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [yelloww, yelloww.withOpacity(0.7)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildZodiacPictures(context),
              const SizedBox(height: 24),
              _buildMatchInfo(context),
              const SizedBox(height: 24),
              _buildConversationStarters(context),
              const SizedBox(height: 24),
              _buildStartChattingButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildZodiacPictures(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildZodiacIcon(userData.astroData.planetSigns["sun"]!),
        const SizedBox(width: 16),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.8, end: 1.0),
          duration: const Duration(seconds: 1),
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: const Icon(
                Icons.favorite,
                color: yelloww,
                size: 48,
              ),
            );
          },
        ),
        const SizedBox(width: 16),
        _buildZodiacIcon(matchUser.astroData.planetSigns["sun"]!),
      ],
    );
  }

  Widget _buildZodiacIcon(String zodiacSign) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        // color: Colors.white,
        shape: BoxShape.circle,
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withOpacity(0.1),
        //     spreadRadius: 2,
        //     blurRadius: 5,
        //     offset: Offset(0, 3),
        //   ),
        // ],
      ),
      child: Image.asset(
        'assets/icons/$zodiacSign-icon.png',
        width: 60,
        height: 60,
      ),
    );
  }

  Widget _buildMatchInfo(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUserInfo(context, userData),
        Container(
          height: 180,
          width: 1,
          color: bgcolor.withOpacity(0.3),
        ),
        _buildUserInfo(context, matchUser),
      ],
    );
  }

  Widget _buildUserInfo(BuildContext context, UserAndAstroData user) {
    return Expanded(
      child: Column(
        children: [
          Hero(
            tag: 'avatar_${user.user.uid}',
            child: CircleAvatar(
              radius: MediaQuery.of(context).size.width * 0.12,
              backgroundColor: Colors.white,
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: user.user.photoUrl,
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  fit: BoxFit.cover,
                  width: MediaQuery.of(context).size.width * 0.24,
                  height: MediaQuery.of(context).size.width * 0.24,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            user.user.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: bgcolor,
              fontFamily: 'Manrope',
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            "@${user.user.handle}",
            style: TextStyle(
              fontSize: 14,
              color: bgcolor.withOpacity(0.7),
              fontFamily: 'Manrope',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: bgcolor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "${user.astroData.planetSigns["sun"]}",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: bgcolor,
                fontFamily: 'Manrope',
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Born in ${user.user.placeOfBirth}",
            style: TextStyle(
              fontSize: 12,
              color: bgcolor.withOpacity(0.8),
              fontFamily: 'Manrope',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildConversationStarters(BuildContext context) {
    // Implement your conversation starters here
    return Container();
  }

  Widget _buildStartChattingButton(BuildContext context) {
    return ElevatedButton(
      onPressed: onStartChatting,
      style: ElevatedButton.styleFrom(
        backgroundColor: bgcolor,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: const Text(
        'Start Chatting',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: yelloww,
          fontFamily: 'Manrope',
        ),
      ),
    );
  }
}
