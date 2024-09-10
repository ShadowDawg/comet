import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:comet/backend/firebase_tools.dart';
import 'package:comet/colors.dart';
import 'package:comet/models/friend_basic_data.dart';
import 'package:comet/models/user.dart';
import 'package:comet/providers/user_data_provider.dart';
import 'package:comet/providers/user_friends_data_provider.dart';

enum FriendsPageState {
  loading,
  noInternet,
  permissionNotGranted,
  permissionDenied,
  friendsList,
}

class FriendsPage extends StatefulWidget {
  const FriendsPage({Key? key}) : super(key: key);

  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  FriendsPageState _pageState = FriendsPageState.loading;

  bool _isCheckingConnectivity = false;
  bool _hasInternetConnection = true;

  List<Contact> contacts = [];
  List<String> friendsOnApp = [];
  bool isLoading = false;
  bool hasContactPermission = false;

  bool _hasCheckedPermissionBefore = false;

  @override
  void initState() {
    super.initState();
    // _checkConnectivity();
    // _checkPermissionStatus();
    _initializePageState();
  }

  Future<void> _initializePageState() async {
    try {
      print("Starting _initializePageState");
      await _checkConnectivity();
      if (!_hasInternetConnection) {
        print("No internet connection");
        _updatePageState(FriendsPageState.noInternet);
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      _hasCheckedPermissionBefore =
          prefs.getBool('hasCheckedPermission') ?? false;
      print("Has checked permission before: $_hasCheckedPermissionBefore");

      final permissionStatus = await Permission.contacts.status;
      print("Permission status: ${permissionStatus.isGranted}");

      if (permissionStatus.isGranted) {
        await _initializeFriendsData();
        _updatePageState(FriendsPageState.friendsList);
      } else if (_hasCheckedPermissionBefore) {
        _updatePageState(FriendsPageState.permissionDenied);
      } else {
        _updatePageState(FriendsPageState.permissionNotGranted);
      }
    } catch (e) {
      print("Error in _initializePageState: $e");
      _updatePageState(FriendsPageState.noInternet);
    }
  }

  void _updatePageState(FriendsPageState newState) {
    print("Updating page state to: $newState");
    if (mounted) {
      setState(() {
        _pageState = newState;
      });
    }
  }

  Future<void> _checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (mounted) {
      setState(() {
        _isCheckingConnectivity = false;
        _hasInternetConnection = connectivityResult != ConnectivityResult.none;
      });
    }
    if (_hasInternetConnection) {
      _checkContactPermission();
      _hasInternetConnection = true;
    }
  }

  Future<void> _refreshData() async {
    await _checkConnectivity();
    if (_hasInternetConnection && mounted) {
      if (hasContactPermission) {
        await _getContacts();
        await _updateFriendsOnApp();
      } else {
        await _checkContactPermission();
      }
    }
  }

  Future<void> _checkPermissionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _hasCheckedPermissionBefore =
        prefs.getBool('hasCheckedPermission') ?? false;

    final status = await Permission.contacts.status;
    setState(() {
      hasContactPermission = status.isGranted;
    });

    if (hasContactPermission) {
      _initializeFriendsData();
    }
  }

  Future<void> _checkContactPermission() async {
    final status = await Permission.contacts.status;
    if (mounted) {
      setState(() {
        hasContactPermission = status.isGranted;
      });
    }
    if (status.isGranted) {
      _initializeFriendsData();
    }
  }

  Future<void> _initializeFriendsData() async {
    try {
      final friendsProvider =
          Provider.of<FriendsDataProvider>(context, listen: false);

      if (friendsProvider.friends.isEmpty) {
        await _getContacts();
        await _updateFriendsOnApp();
      }
    } catch (e) {
      print("Error in _initializeFriendsData: $e");
      _updatePageState(FriendsPageState.noInternet);
    }
  }

  Future<void> _requestContactsPermission() async {
    if (mounted) {
      setState(() {
        _pageState = FriendsPageState.loading;
      });
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasCheckedPermission', true);

    final status = await Permission.contacts.request();
    if (status.isGranted) {
      await _initializeFriendsData();
      if (mounted) {
        setState(() => _pageState = FriendsPageState.friendsList);
      }
    } else {
      if (mounted) {
        setState(() => _pageState = FriendsPageState.permissionDenied);
      }
    }
  }

  Future<void> _recheckPermissionStatus() async {
    final status = await Permission.contacts.status;
    if (status.isGranted) {
      await _initializeFriendsData();
      setState(() => _pageState = FriendsPageState.friendsList);
    }
  }

  Future<void> _getContacts() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      contacts = await ContactsService.getContacts();
      print('Fetched ${contacts.length} contacts');
    } catch (e) {
      print('Error fetching contacts: $e');
      contacts = []; // Set contacts to an empty list if there's an error
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _updateFriendsOnApp() async {
    print("updating friends...");

    if (mounted) {
      final userDataProvider =
          Provider.of<UserDataProvider>(context, listen: false);
      final friendsProvider =
          Provider.of<FriendsDataProvider>(context, listen: false);

      final userUid = userDataProvider.userData?.uid;
      if (userUid == null) {
        print('User UID is null. Cannot fetch friends.');
        return;
      }

      final phoneNumbers = contacts
          .where(
              (contact) => contact.phones != null && contact.phones!.isNotEmpty)
          .map((contact) => contact.phones!.first.value ?? '')
          .where((phone) => phone.isNotEmpty)
          .map((phone) {
            phone = phone.replaceAll(RegExp(r'[\s\-()]+'), '');
            if (phone.startsWith('+91')) {
              phone = phone.substring(3);
            }
            if (RegExp(r'^\d+$').hasMatch(phone)) {
              return '+91$phone';
            } else {
              return '';
            }
          })
          .where((phone) => phone.isNotEmpty)
          .toList();

      print('Processed ${phoneNumbers.length} phone numbers');

      await friendsProvider.fetchFriends(userUid, phoneNumbers);
    }
  }

  Future<void> _checkFriendsOnApp() async {
    final phoneNumbers = contacts
        .map((contact) => contact.phones?.first.value ?? '')
        .map((phone) {
      // Remove all non-digit characters
      phone = phone.replaceAll(RegExp(r'\D'), '');

      // Add +91 prefix to all numbers, except those that are not valid phone numbers
      if (phone.isNotEmpty && phone.length >= 10) {
        return '+91$phone';
      } else {
        return phone; // Return original for invalid or empty strings
      }
    }).toList();

    print(phoneNumbers);

    // Query Firestore for users with matching phone numbers
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('users')
        .where('phoneNumber', whereIn: phoneNumbers)
        .get();
    if (mounted) {
      setState(() {
        friendsOnApp = result.docs.map((doc) => doc['name'] as String).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: kToolbarHeight + MediaQuery.of(context).padding.top,
        automaticallyImplyLeading: false,
        backgroundColor: bgcolor,
        flexibleSpace: SafeArea(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
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
                      color: yelloww,
                      width: 2.0,
                    ),
                  ),
                ),
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Text(
                      'friends.',
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
          ),
        ),
      ),
      backgroundColor: bgcolor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: RefreshIndicator(
            onRefresh: _refreshData,
            child: _buildBody(),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_pageState) {
      case FriendsPageState.loading:
        return _buildLoadingWidget();
      case FriendsPageState.noInternet:
        return _buildNoInternetWidget();
      case FriendsPageState.permissionNotGranted:
        return _buildPermissionRequest();
      case FriendsPageState.permissionDenied:
        return _buildManualPermissionInstructions();
      case FriendsPageState.friendsList:
        return _buildFriendsList();
    }
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildNoInternetWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('No internet connection'),
          ElevatedButton(
            onPressed: _checkConnectivity,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionRequest() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'See who your friends match with and how they\'re feeling.',
            style: TextStyle(
              color: yelloww,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Manrope',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          const Text(
            'Sync your contacts to add people you already know.',
            style: TextStyle(
              color: greyy,
              fontSize: 16,
              fontFamily: 'Manrope',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _requestContactsPermission,
            style: ElevatedButton.styleFrom(
              backgroundColor: yelloww,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              textStyle: const TextStyle(fontSize: 18),
            ),
            child: const Text(
              'Add contact list',
              style: TextStyle(
                fontFamily: 'Manrope',
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManualPermissionInstructions() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'See who your friends match with and how they\'re feeling.',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Manrope',
              color: yelloww,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          Text(
            'To add your friends, please enable contact permission in your device settings:',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Manrope',
              color: yelloww,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          Text(
            '1. Open device Settings\n'
            '2. Tap on Apps\n'
            '3. Find and tap on comet.\n'
            '4. Tap on Permissions\n'
            '5. Enable Contacts permission',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Manrope',
              color: yelloww,
            ),
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }

  Widget _buildFriendsList() {
    return Consumer<FriendsDataProvider>(
      builder: (context, friendsProvider, child) {
        if (friendsProvider.isLoading) {
          return const Center(child: CircularProgressIndicator(color: yelloww));
        } else if (friendsProvider.error != null) {
          return Center(
            child: Text(
              'Error: ${friendsProvider.error}',
              style: const TextStyle(color: yelloww),
            ),
          );
        } else if (friendsProvider.friends.isEmpty) {
          return const Center(
            child: Text(
              'None of your contacts are on comet (yet)',
              style: TextStyle(color: yelloww),
            ),
          );
        } else {
          return ListView.builder(
            itemCount: friendsProvider.friends.length,
            itemBuilder: (context, index) {
              FriendBasicData friend = friendsProvider.friends[index];
              return Container(
                margin:
                    const EdgeInsets.only(bottom: 8), // Add bottom margin here
                child: ListTile(
                  tileColor: darkGreyy,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  title: Text(
                    friend.name,
                    style: const TextStyle(
                      color: yelloww,
                      fontFamily: "Manrope",
                    ),
                  ),
                  subtitle: Text(
                    "@${friend.handle}",
                    style: const TextStyle(
                      color: greyy,
                      fontFamily: "Manrope",
                    ),
                  ),
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(friend.photoUrl),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, color: yelloww),
                    onPressed: () => _showFriendDetails(friend.uid),
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }

  Future<void> _showFriendDetails(String friendUid) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return Container(
              decoration: const BoxDecoration(
                color: darkGreyy,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: FutureBuilder<UserModel>(
                future: backendFirebaseGetUserData(friendUid),
                builder: (context, friendSnapshot) {
                  if (friendSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(color: yelloww));
                  } else if (friendSnapshot.hasError ||
                      !friendSnapshot.hasData) {
                    return Center(
                      child: Text(
                        friendSnapshot.hasError
                            ? 'Error loading friend data'
                            : 'No data available',
                        style: const TextStyle(color: yelloww),
                      ),
                    );
                  }

                  UserModel friend = friendSnapshot.data!;
                  return _buildFriendInfo(friend, controller);
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFriendInfo(UserModel friend, ScrollController controller) {
    return SingleChildScrollView(
      controller: controller,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 5,
              decoration: BoxDecoration(
                color: greyy,
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(friend.photoUrl),
            ),
            const SizedBox(height: 16),
            Text(
              friend.name,
              style: const TextStyle(
                color: yelloww,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Manrope',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              "@${friend.handle}",
              style: const TextStyle(
                color: greyy,
                fontSize: 18,
                fontFamily: 'Manrope',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            _buildPlanetSigns(friend),
            const SizedBox(height: 24),
            if (friend.astroData.matchUid.isNotEmpty)
              _buildMatchInfo(friend.astroData.matchUid, friend.name)
            else
              const Text(
                "Your friend hasn't been matched yet",
                style: TextStyle(
                    color: yelloww, fontSize: 16, fontFamily: 'Manrope'),
              ),
            const SizedBox(height: 16),
            // _buildDetailItem(
            //   Icons.favorite,
            //   "Friend's horoscope: ${friend.astroData.dailyHoroscope ?? 'N/A'}",
            // ),
            // _buildDetailItem(
            //   Icons.mood,
            //   "Current name: ${friend.name ?? 'N/A'}",
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchInfo(String matchUid, String friendName) {
    return FutureBuilder<UserModel>(
      future: backendFirebaseGetUserData(matchUid),
      builder: (context, matchSnapshot) {
        if (matchSnapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(color: yelloww);
        } else if (matchSnapshot.hasError || !matchSnapshot.hasData) {
          return const Text(
            'Unable to load match info',
            style: TextStyle(color: yelloww),
          );
        }

        UserModel match = matchSnapshot.data!;
        return Container(
          decoration: BoxDecoration(
            // gradient: LinearGradient(
            //   begin: Alignment.topLeft,
            //   end: Alignment.bottomRight,
            //   colors: [
            //     Colors.yellow.shade300,
            //     Colors.amber.shade700,
            //   ],
            // ),
            color: bgcolor,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "$friendName's match for the week",
                  style: const TextStyle(
                    color: yelloww,
                    fontFamily: "Playwrite_HU",
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(match.photoUrl),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            match.name,
                            style: const TextStyle(
                              color: yelloww,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Manrope",
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "@${match.handle}",
                            style: const TextStyle(
                              color: greyy,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlanetSigns(UserModel friend) {
    return Container(
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 40,
            child: _buildPlanetSignItem(
              'Sun',
              friend.astroData.planetSigns['sun'],
              'assets/icons/sun-icon.png',
            ),
          ),
          _buildPlanetSignItem(
            'Moon',
            friend.astroData.planetSigns['moon'],
            'assets/icons/moon-icon.png',
          ),
          Positioned(
            right: 40,
            child: _buildPlanetSignItem(
              'Ascendant',
              "capricorn",
              'assets/icons/ascendant-icon.png',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanetSignItem(String planet, String? sign, String iconPath) {
    return Column(
      children: [
        Image.asset(
          iconPath,
          width: 24,
          height: 24,
          color: yelloww,
        ),
        const SizedBox(height: 4),
        Text(
          sign ?? 'N/A',
          style: const TextStyle(
            color: yelloww,
            fontSize: 14,
            fontFamily: 'Manrope',
          ),
        ),
        Text(
          planet,
          style: const TextStyle(
            color: greyy,
            fontSize: 12,
            fontFamily: 'Manrope',
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: yelloww),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: yelloww,
                fontSize: 16,
                fontFamily: 'Manrope',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
