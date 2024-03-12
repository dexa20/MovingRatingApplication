import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart' as Path;
import '/authentication_screens/login_screen.dart'; // Ensure this path is correct
import 'package:flutter/foundation.dart' show kIsWeb;

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;
  String _errorMessage = '';
  bool _isNewPasswordVisible = false;
  bool _isOldPasswordVisible = false;
  String? _profileImageUrl; // Changed to String to hold URL

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();
    if (doc.exists && doc.data()!['profilePicture'] != null) {
      setState(() {
        _profileImageUrl = doc.data()!['profilePicture'];
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final fileName = Path.basename(pickedFile.path);
      final refPath = 'profile_pictures/${user!.uid}/$fileName';
      firebase_storage.UploadTask uploadTask;

      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        uploadTask = firebase_storage.FirebaseStorage.instance
            .ref(refPath)
            .putData(bytes,
                firebase_storage.SettableMetadata(contentType: 'image/jpeg'));
      } else {
        File file = File(pickedFile.path);
        uploadTask = firebase_storage.FirebaseStorage.instance
            .ref(refPath)
            .putFile(file);
      }

      try {
        final snapshot = await uploadTask.whenComplete(() {});
        final downloadUrl = await snapshot.ref.getDownloadURL();
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .set({
          'profilePicture': downloadUrl,
        }, SetOptions(merge: true));
        setState(() {
          _profileImageUrl = downloadUrl;
        });
      } catch (e) {
        print(e);
      }
    }
  }

  Future<void> _removeProfileImage() async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({
        'profilePicture': FieldValue.delete(),
      });
      setState(() {
        _profileImageUrl = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to remove profile picture. Please try again.'),
        ),
      );
    }
  }

  Future<void> _changePassword() async {
    String oldPassword = _oldPasswordController.text.trim();
    String newPassword = _newPasswordController.text.trim();
    if (newPassword.isEmpty || newPassword.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Password must be at least 6 characters long'),
      ));
      return;
    }

    try {
      AuthCredential credential = EmailAuthProvider.credential(
          email: user!.email!, password: oldPassword);
      await user!.reauthenticateWithCredential(credential);
      await user!.updatePassword(newPassword);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Password updated successfully'),
      ));
    } catch (e) {
      setState(() {
        _errorMessage =
            'Failed to update password. Please check your old password and try again.';
      });
    }
  }

  void _logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('rememberMe', false);
    await _auth.signOut();
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Profile',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: _profileImageUrl != null
                    ? NetworkImage(_profileImageUrl!)
                    : null,
                backgroundColor: Colors.grey.shade800,
                child: _profileImageUrl == null
                    ? Icon(Icons.person, size: 60, color: Colors.white)
                    : null,
              ),
            ),
            TextButton(
              onPressed: _removeProfileImage,
              child: Text('Remove Profile Image',
                  style: TextStyle(color: Colors.red, fontSize: 14)),
            ),
            TextButton(
              onPressed: _pickImage,
              child: Text('Change Profile Image',
                  style: TextStyle(color: Colors.green, fontSize: 14)),
            ),
            SizedBox(height: 20),

            Center(
              child: Text(
                'Email: ${user?.email ?? 'No email available'}',
                style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _oldPasswordController,
              decoration: InputDecoration(
                hintText: 'Old Password',
                hintStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isOldPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Theme.of(context).primaryColorDark,
                  ),
                  onPressed: () {
                    setState(() {
                      _isOldPasswordVisible = !_isOldPasswordVisible;
                    });
                  },
                ),
              ),
              obscureText: !_isOldPasswordVisible,
            ),
            SizedBox(height: 20),
            TextField(
              controller: _newPasswordController,
              decoration: InputDecoration(
                hintText: 'New Password',
                hintStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isNewPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Theme.of(context).primaryColorDark,
                  ),
                  onPressed: () {
                    setState(() {
                      _isNewPasswordVisible = !_isNewPasswordVisible;
                    });
                  },
                ),
              ),
              obscureText: !_isNewPasswordVisible,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text(
                'Change Password',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Background color
                padding: EdgeInsets.symmetric(vertical: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onPressed: _changePassword,
            ),
            SizedBox(height: 20),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text(
                  _errorMessage,
                  style:
                      TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ElevatedButton(
              child: Text(
                'Logout',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Background color
                padding: EdgeInsets.symmetric(vertical: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onPressed: _logout,
            )
            // The rest of your Widget tree remains unchanged
          ],
        ),
      ),
    );
  }
}
