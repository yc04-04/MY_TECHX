import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ProfileTab({
    super.key,
    required this.icon,
    required this.label,
    this.selected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: selected ? Colors.blue : Colors.black),
          Text(label, style: TextStyle(color: selected ? Colors.blue : Colors.black)),
        ],
      ),
    );
  }
}

class _ProfileState extends State<Profile> {
  File? _image;
  String? _contactError;
  final picker = ImagePicker();
  final user = FirebaseAuth.instance.currentUser;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String createdDate = "";

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    if (user != null) {
      _emailController.text = user!.email ?? '';
      DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection("users").doc(user!.uid).get();

      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        _nameController.text = data['name'] ?? '';
        _contactController.text = data['contact'] ?? '';
        _descriptionController.text = data['description'] ?? '';
      }

      DateTime? regDate = user!.metadata.creationTime;
      if (regDate != null) {
        createdDate = "${regDate.month}/${regDate.day}/${regDate.year}";
      }

      setState(() {});
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Change Profile Picture"),
          content: const Text("Select an image source."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
              child: const Text("Camera"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
              child: const Text("Gallery"),
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Profile"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name')),
                TextField(
                  controller: _contactController,
                  decoration: const InputDecoration(labelText: 'Contact Number'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                TextField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'Description')),
                TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email'), enabled: false),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Cancel")),
            ElevatedButton(onPressed: _saveProfile, child: const Text("Save")),
          ],
        );
      },
    );
  }

  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _saveProfile() async {
    String name = _nameController.text.trim();
    String contact = _contactController.text.trim();

    // Validate name and contact
    if (name.isEmpty || contact.isEmpty) {
      _showAlertDialog("Validation Error", "Name and Contact number are required.");
      return;
    }

    // Validate phone number for 10 to 11 digits
    if (!RegExp(r'^\d{10,11}$').hasMatch(contact)) {
      _showAlertDialog("Validation Error", "Contact number must be 10 to 11 digits.");
      return;
    }

    // Proceed with saving profile if validation passes
    if (user != null) {
      await FirebaseFirestore.instance.collection("users").doc(user!.uid).set({
        'name': name,
        'contact': contact,
        'description': _descriptionController.text.trim(),
      }, SetOptions(merge: true));

      await _loadUserProfile(); // Refresh after save
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully!")),
      );
    }
  }




  void _showConfirmationDialog(String title, String message, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Cancel")),
            ElevatedButton(onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            }, child: const Text("Confirm")),
          ],
        );
      },
    );
  }

  Widget _buildProfileDetail(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text("$title: $value", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: _showEditDialog),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: _image != null
                        ? FileImage(_image!)
                        : const AssetImage("assets/images/profile_picture.jpg") as ImageProvider,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      _nameController.text,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.camera_alt, color: Colors.blue), onPressed: _showImageSourceDialog),
                ],
              ),
            ),

            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _ProfileTab(icon: Icons.person, label: 'Profile', selected: true, onTap: () {}),
                  _ProfileTab(icon: Icons.edit, label: 'Contribution', onTap: () {}),
                  _ProfileTab(icon: Icons.bookmark_border, label: 'Bookmark', onTap: () {}),
                  _ProfileTab(icon: Icons.mail_outline, label: 'Inbox', onTap: () {}),
                  _ProfileTab(icon: Icons.attach_money, label: 'Transaction', onTap: () {}),
                ],
              ),
            ),
            const Divider(thickness: 1, height: 32),

            _buildProfileDetail("Email", _emailController.text),
            _buildProfileDetail("Contact", _contactController.text),
            _buildProfileDetail("Description", _descriptionController.text),
            _buildProfileDetail("Account created on", createdDate),
            const SizedBox(height: 20),

            Center(
              child: ElevatedButton(
                onPressed: () {
                  _showConfirmationDialog(
                    "Sign Out",
                    "Are you sure you want to SIGN OUT?",
                        () {
                      FirebaseAuth.instance.signOut().then((_) => Navigator.of(context).pop());
                    },
                  );
                },
                child: const Text("Sign Out"),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _showConfirmationDialog(
                    "Delete Account",
                    "Are you sure you want to DELETE your account? This action cannot be undone.",
                        () async {
                      try {
                        await FirebaseFirestore.instance.collection("users").doc(user!.uid).delete();
                        await user!.delete();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Account deleted successfully!")),
                        );
                        Navigator.of(context).pop();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error deleting account: $e")),
                        );
                      }
                    },
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text("Delete Account", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
