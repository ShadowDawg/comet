import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test1/colors.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({Key? key}) : super(key: key);

  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  List<Contact> contacts = [];
  List<String> friendsOnApp = [];
  bool isLoading = false;
  bool hasContactPermission = false;

  @override
  void initState() {
    super.initState();
    _checkContactPermission();
  }

  Future<void> _checkContactPermission() async {
    final status = await Permission.contacts.status;
    if (mounted) {
      setState(() {
        hasContactPermission = status.isGranted;
      });
    }
    if (status.isGranted) {
      _getContacts();
    }
  }

  Future<void> _requestContactsPermission() async {
    final status = await Permission.contacts.request();
    if (status.isGranted && mounted) {
      setState(() {
        hasContactPermission = true;
      });
      _getContacts();
    } else {
      // Handle permission denied
      print('Contacts permission denied');
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
      await _checkFriendsOnApp();
    } catch (e) {
      print('Error fetching contacts: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _checkFriendsOnApp() async {
    final phoneNumbers =
        contacts.map((contact) => contact.phones?.first.value ?? '').toList();

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
                      color: Color(0xFFC0C0BE),
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
      body: hasContactPermission
          ? _buildFriendsList()
          : _buildPermissionRequest(),
    );
  }

  Widget _buildPermissionRequest() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'See who your friends match with and how they\'re feeling .',
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
              foregroundColor: bgcolor,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              textStyle: const TextStyle(fontSize: 18),
            ),
            child: const Text(
              'Add contact list',
              style: TextStyle(
                fontFamily: 'Manrope',
                color: bgcolor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendsList() {
    return isLoading
        ? const Center(child: CircularProgressIndicator(color: yelloww))
        : friendsOnApp.isEmpty
            ? const Center(
                child: Text(
                  'No cosmic connections found yet',
                  style: TextStyle(color: yelloww),
                ),
              )
            : ListView.builder(
                itemCount: friendsOnApp.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      friendsOnApp[index],
                      style: const TextStyle(color: yelloww),
                    ),
                    // Add more friend details or actions here
                  );
                },
              );
  }
}
