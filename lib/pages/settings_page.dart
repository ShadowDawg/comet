import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';
import 'package:test1/backend/firebase_tools.dart';
import 'package:test1/colors.dart';
import 'package:test1/initializer_widget.dart';
import 'package:test1/pages/settings_edit_birth_place.dart';
import 'package:test1/providers/user_data_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  File? _image;
  final picker = ImagePicker();
  bool _isLoading = false;
  late DateTime _dateOfBirth;

  @override
  void initState() {
    super.initState();
    final userDataProvider =
        Provider.of<UserDataProvider>(context, listen: false);
    _dateOfBirth = DateTime.parse(userDataProvider.userData!.user.dateOfBirth);
  }

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future<String> uploadImage(File image) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference firebaseStorageRef =
        FirebaseStorage.instance.ref().child('profile_images/$fileName');
    UploadTask uploadTask = firebaseStorageRef.putFile(image);
    TaskSnapshot taskSnapshot = await uploadTask;
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> _updateField(String field, dynamic value) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userDataProvider =
          Provider.of<UserDataProvider>(context, listen: false);
      final userData = userDataProvider.userData!;

      // If updating dateOfBirth, convert DateTime to ISO string
      if (field == 'dateOfBirth' && value is DateTime) {
        value = value.toUtc().toIso8601String();
      }

      bool updateSuccess =
          await backendFirebaseUpdateUserField(userData.user.uid, field, value);

      if (updateSuccess) {
        // Update successful, update local state through the provider
        userDataProvider.updateUserData((currentData) {
          switch (field) {
            case 'handle':
              return currentData.copyWith(
                  user: currentData.user.copyWith(handle: value));
            case 'dateOfBirth':
              return currentData.copyWith(
                  user: currentData.user.copyWith(dateOfBirth: value));
            case 'placeOfBirth':
              return currentData.copyWith(
                  user: currentData.user.copyWith(placeOfBirth: value));
            case 'photoUrl':
              return currentData.copyWith(
                  user: currentData.user.copyWith(photoUrl: value));
            default:
              return currentData;
          }
        });

        if (field == 'dateOfBirth') {
          setState(() {
            _dateOfBirth = DateTime.parse(value);
          });
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$field updated successfully')),
          );
        }
      } else {
        throw Exception('Failed to update $field');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating $field: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showEditDialog(String field, String currentValue) {
    final controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $field'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: 'New $field'),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Save'),
            onPressed: () {
              // update only if value is changed
              if (controller.text != currentValue) {
                _updateField(field, controller.text);
              }
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void _showDateTimePicker(String field) {
    DateTime initialDateTime = _dateOfBirth;
    DateTime? tempDateTime;

    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 300,
        color: yelloww,
        child: Column(
          children: [
            Expanded(
              child: CupertinoTheme(
                data: const CupertinoThemeData(
                  textTheme: CupertinoTextThemeData(
                    dateTimePickerTextStyle: TextStyle(
                      color: bgcolor,
                      fontSize: 20,
                      fontFamily: 'Manrope',
                    ),
                  ),
                ),
                child: CupertinoDatePicker(
                  mode: field == 'birthDate'
                      ? CupertinoDatePickerMode.date
                      : CupertinoDatePickerMode.time,
                  initialDateTime: initialDateTime,
                  maximumDate: DateTime.now(),
                  minimumYear: 1900,
                  maximumYear: DateTime.now().year,
                  onDateTimeChanged: (newDateTime) {
                    tempDateTime = field == 'birthDate'
                        ? DateTime(
                            newDateTime.year,
                            newDateTime.month,
                            newDateTime.day,
                            _dateOfBirth.hour,
                            _dateOfBirth.minute,
                          )
                        : DateTime(
                            _dateOfBirth.year,
                            _dateOfBirth.month,
                            _dateOfBirth.day,
                            newDateTime.hour,
                            newDateTime.minute,
                          );
                  },
                ),
              ),
            ),
            CupertinoButton(
              child: const Text(
                'Confirm',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                if (tempDateTime != null && tempDateTime != _dateOfBirth) {
                  setState(() {
                    _dateOfBirth = tempDateTime!;
                  });
                  _updateField('dateOfBirth', _dateOfBirth);
                }
                Navigator.of(context).pop();
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSettingRow(String field, String value, {VoidCallback? onTap}) {
    return ListTile(
      title: Text(
        field,
        style: const TextStyle(
          color: offwhite,
        ),
      ),
      subtitle: Text(value),
      trailing: onTap != null
          ? const Icon(
              Icons.edit,
              color: offwhite,
            )
          : null,
      onTap: field == 'Birth Place' ? () => _editBirthplace(value) : onTap,
      tileColor: tile_color,
      textColor: yelloww,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  void _editBirthplace(String currentBirthplace) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EditBirthplacePage(currentBirthplace: currentBirthplace),
      ),
    );

    if (result != null) {
      // Update the birthplace in your state or database
      setState(() {
        // Assuming you have a variable to store the birthplace
        _updateField("placeOfBirth", result);
      });
    }
  }

  Widget _buildNonEditableRow(String field, String value) {
    return ListTile(
      title: Text(
        field,
        style: const TextStyle(
          color: offwhite,
        ),
      ),
      subtitle: Text(value),
      tileColor: tile_color,
      textColor: yelloww,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Future<void> _logout() async {
    bool confirmLogout = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Logout'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmLogout == true) {
      try {
        // Show loading indicator
        // showDialog(
        //   context: context,
        //   barrierDismissible: false,
        //   builder: (BuildContext context) {
        //     return const Center(child: CircularProgressIndicator());
        //   },
        // );

        // Log out of auth first
        await FirebaseAuth.instance.signOut();

        // clear user data in provider and Navigate to InitializerWidget
        if (mounted) {
          await Provider.of<UserDataProvider>(context, listen: false)
              .clearUserData();
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (context) => const InitializerWidget()),
              (Route<dynamic> route) => false,
            );
          }
        }
      } catch (e) {
        // Handle any errors
        print('Error during logout: $e');
        // Show error message to user
      } finally {
        // Dismiss loading indicator if it's still showing
        if (mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      }
    }
  }

  Future<void> _deleteAccount() async {
    final userDataProvider =
        Provider.of<UserDataProvider>(context, listen: false);
    final userData = userDataProvider.userData;

    if (userData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User data not available')),
      );
      return;
    }

    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text(
              'This action is permanent and cannot be undone. Are you sure you want to delete your account?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      try {
        await backendFirebaseDeleteUserAccount(userData.user.uid);
        await FirebaseAuth.instance.currentUser?.delete();
        await FirebaseAuth.instance.signOut();

        // Clear the user data from the provider
        userDataProvider.clearUserData();
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const InitializerWidget()),
            (Route<dynamic> route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting account: $e')),
          );
        }
      }
    }
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
    return Scaffold(
      backgroundColor: bgcolor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Settings.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontFamily: "Playwrite_HU",
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: offwhite),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: bgcolor))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        await getImage();
                        if (_image != null) {
                          _updateField('photoUrl', null);
                        }
                      },
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: _image != null
                            ? FileImage(_image!)
                            : (userData.user.photoUrl.isNotEmpty
                                ? NetworkImage(userData.user.photoUrl)
                                : null) as ImageProvider?,
                        child:
                            (_image == null && (userData.user.photoUrl.isEmpty))
                                ? Icon(Icons.camera_alt,
                                    size: 50, color: Colors.grey[800])
                                : null,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Non-editable fields
                    _buildNonEditableRow('Name', userData.user.name),
                    const SizedBox(
                      height: 5,
                    ),
                    _buildNonEditableRow('Gender', userData.user.gender),
                    const SizedBox(
                      height: 5,
                    ),
                    _buildNonEditableRow(
                        'Phone', userData.user.phoneNumber.toString()),
                    const Divider(),
                    // Editable fields
                    _buildSettingRow(
                      'Username',
                      "@${userData.user.handle}",
                      onTap: () =>
                          _showEditDialog('handle', userData.user.handle),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    _buildSettingRow(
                      'Birth Date',
                      DateFormat('yyyy-MM-dd').format(_dateOfBirth),
                      onTap: () => _showDateTimePicker('birthDate'),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    _buildSettingRow(
                      'Birth Time',
                      DateFormat('HH:mm').format(_dateOfBirth),
                      onTap: () => _showDateTimePicker('birthTime'),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    _buildSettingRow(
                      'Birth Place',
                      userData.user.placeOfBirth,
                      onTap: () => _showEditDialog(
                          'placeOfBirth', userData.user.placeOfBirth),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Logout :(',
                        style: TextStyle(
                          color: bgcolor,
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _deleteAccount,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'DELETE ACCOUNT :(((',
                        style: TextStyle(
                          color: bgcolor,
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
