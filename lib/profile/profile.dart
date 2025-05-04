import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../discussion/post_model.dart';
import '../discussion/discuss.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  File? _image;
  String? _base64Image;
  final picker = ImagePicker();
  final user = FirebaseAuth.instance.currentUser;
  int selectedTabIndex = 0;
  bool _isSortedAscending = true;

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

  @override
  void dispose() {
    super.dispose();
    _contactController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _emailController.dispose();
  }

  Future<void> _loadUserProfile() async {
    if (user != null) {
      _emailController.text = user!.email ?? '';
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        _nameController.text = data['name'] ?? '';
        _contactController.text = data['contact'] ?? '';
        _descriptionController.text = data['description'] ?? '';
        _base64Image = data['profileImage'];
      }

      DateTime? regDate = user!.metadata.creationTime;
      if (regDate != null) {
        createdDate = "${regDate.month}/${regDate.day}/${regDate.year}";
      }

      setState(() {});
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source, imageQuality: 50);
    if (pickedFile != null) {
      final bytes = await File(pickedFile.path).readAsBytes();
      _base64Image = base64Encode(bytes);
      setState(() {
        _image = File(pickedFile.path);
      });

      if (user != null) {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(user!.uid)
            .set({'profileImage': _base64Image}, SetOptions(merge: true));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile image updated successfully!")),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Change Profile Picture"),
        content: const Text("Select an image source."),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
              child: const Text("Camera")),
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
              child: const Text("Gallery")),
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _confirmRemoveImage();
              },
              child: const Text("Remove")),
        ],
      ),
    );
  }

  void _confirmRemoveImage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Remove Profile Picture"),
        content: const Text("Are you sure you want to remove your profile picture?"),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              setState(() {
                _image = null;
                _base64Image = null;
              });
              if (user != null) {
                await FirebaseFirestore.instance
                    .collection("users")
                    .doc(user!.uid)
                    .set({'profileImage': FieldValue.delete()}, SetOptions(merge: true));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Profile picture removed.")),
                );
              }
            },
            child: const Text("Remove"),
          ),
        ],
      ),
    );
  }

  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
      ),
    );
  }

  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("OK"))],
      ),
    );
  }

  Future<void> _saveProfile() async {
    String name = _nameController.text.trim();
    String contact = _contactController.text.trim();

    if (name.isEmpty || contact.isEmpty) {
      _showAlertDialog("Validation Error", "Name and Contact number are required.");
      return;
    }

    if (!RegExp(r'^\d{10,11}$').hasMatch(contact)) {
      _showAlertDialog("Validation Error", "Contact number must be 10 to 11 digits.");
      return;
    }

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("users")
        .where('name', isEqualTo: name)
        .get();

    if (querySnapshot.docs.isNotEmpty && querySnapshot.docs.first.id != user!.uid) {
      _showAlertDialog("Validation Error", "The name is already taken.");
      return;
    }

    if (user != null) {
      await FirebaseFirestore.instance.collection("users").doc(user!.uid).set({
        'name': name,
        'contact': contact,
        'description': _descriptionController.text.trim(),
      }, SetOptions(merge: true));

      await _loadUserProfile();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully!")),
      );
    }
  }

  void _showConfirmationDialog(String title, String message, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Cancel")),
          ElevatedButton(onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          }, child: const Text("Confirm")),
        ],
      ),
    );
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Signed out successfully.")));
  }

  Future<void> _deleteAccount() async {
    try {
      await user!.delete();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Account deleted successfully.")));
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to delete account.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider profileImage;
    if (_image != null) {
      profileImage = FileImage(_image!);
    } else if (_base64Image != null && _base64Image!.isNotEmpty) {
      try {
        profileImage = MemoryImage(base64Decode(_base64Image!));
      } catch (e) {
        profileImage = const AssetImage("assets/images/profile_picture.jpg");
      }
    } else {
      profileImage = const AssetImage("assets/images/profile_picture.jpg");
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: _showEditDialog),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: (_image == null && _base64Image == null) ? null : profileImage,
                      child: (_image == null && _base64Image == null)
                          ? const Icon(Icons.person, size: 40)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _showImageSourceDialog,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blueAccent,
                          ),
                          padding: const EdgeInsets.all(5),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    _nameController.text.isNotEmpty ? _nameController.text : 'Guest',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ProfileTab(
                  icon: Icons.person,
                  label: 'Profile',
                  selected: selectedTabIndex == 0,
                  onTap: () => setState(() => selectedTabIndex = 0),
                ),
                _ProfileTab(
                  icon: Icons.edit,
                  label: 'Contribution',
                  selected: selectedTabIndex == 1,
                  onTap: () => setState(() => selectedTabIndex = 1),
                ),
                _ProfileTab(
                  icon: Icons.bookmark,
                  label: 'Bookmark',
                  selected: selectedTabIndex == 2,
                  onTap: () => setState(() => selectedTabIndex = 2),
                ),
                _ProfileTab(
                  icon: Icons.inbox,
                  label: 'Inbox',
                  selected: selectedTabIndex == 3,
                  onTap: () => setState(() => selectedTabIndex = 3),
                ),
                _ProfileTab(
                  icon: Icons.thumb_up,
                  label: 'Likes',
                  selected: selectedTabIndex == 4,
                  onTap: () => setState(() => selectedTabIndex = 4),
                ),
              ],
            ),
            const Divider(thickness: 1, height: 32),
            const SizedBox(height: 20),


            if (selectedTabIndex == 0) ...[
              ProfileTabContent(
                label: 'Email',
                content: _emailController.text,
              ),
              ProfileTabContent(
                label: 'Phone',
                content: _contactController.text,
              ),
              ProfileTabContent(
                label: 'Description',
                content: _descriptionController.text.isEmpty
                    ? 'No description provided'
                    : _descriptionController.text,
              ),
              ProfileTabContent(
                label: 'Member Since',
                content: createdDate,
              ),
              SizedBox(height: 20),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Center(
                    child: ElevatedButton(
                      onPressed: () => _showConfirmationDialog(
                        "Sign Out",
                        "Are you sure you want to SIGN OUT?",
                            () {
                          FirebaseAuth.instance.signOut().then((_) => Navigator.of(context).pop());
                        },
                      ),
                      child: const Text("Sign Out"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Center(
                child: ElevatedButton(
                  onPressed: () => _showConfirmationDialog(
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
                  ),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text("Delete Account", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
            if (selectedTabIndex == 1)
              SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(Icons.access_time),
                          onPressed: () {
                            setState(() {
                              _isSortedAscending = !_isSortedAscending;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(_isSortedAscending
                                      ? 'Sorted by Oldest First'
                                      : 'Sorted by Newest First'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            });
                          },
                        ),
                      ],
                    ),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('posts')
                          .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(child: CircularProgressIndicator());
                        }

                        final posts = snapshot.data!.docs
                            .map((doc) => PostModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
                            .toList();

                        posts.sort((a, b) => _isSortedAscending
                            ? a.timestamp.compareTo(b.timestamp)
                            : b.timestamp.compareTo(a.timestamp));

                        if (posts.isEmpty) {
                          return const Center(child: Text('You haven’t made any contributions.'));
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: posts.length,
                          itemBuilder: (context, index) {
                            final post = posts[index];
                            final double goal = post.toMap()['donationGoal'] is num
                                ? (post.toMap()['donationGoal'] as num).toDouble()
                                : 0.0;
                            final double amount = post.donationAmount;
                            final double percentage = goal > 0
                                ? (amount / goal * 100).clamp(0.0, 100.0)
                                : 0.0;

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => Discussion(post: post),
                                  ),
                                );
                              },
                              child: Card(
                                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Title: ${post.title}',
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Objective: ${post.objective}',
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Posted by ${post.username}',
                                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                                      ),
                                      Text(
                                        DateFormat('h:mm a, yyyy-MM-dd').format(post.timestamp),
                                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                                      ),
                                      const Divider(height: 20),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(Icons.thumb_up_alt_outlined, size: 18),
                                              const SizedBox(width: 4),
                                              Text('${post.likes} Likes'),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Row(
                                                children: [
                                                  const Icon(Icons.volunteer_activism, size: 18),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    goal > 0
                                                        ? 'RM ${amount.toStringAsFixed(2)} / RM ${goal.toStringAsFixed(2)}'
                                                        : 'RM ${amount.toStringAsFixed(2)}',
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              if (goal > 0)
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  children: [
                                                    SizedBox(
                                                      width: 140,
                                                      child: LinearProgressIndicator(
                                                        value: (amount / goal).clamp(0.0, 1.0),
                                                        backgroundColor: Colors.grey.shade300,
                                                        color: Colors.green,
                                                        minHeight: 6,
                                                        borderRadius: BorderRadius.circular(4),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      '${percentage.toStringAsFixed(0)}% funded',
                                                      style: const TextStyle(fontSize: 11),
                                                    ),
                                                  ],
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),


            if (selectedTabIndex == 2)
              SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(Icons.access_time),
                          onPressed: () {
                            setState(() {
                              _isSortedAscending = !_isSortedAscending;

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    _isSortedAscending
                                        ? 'Sorted by Oldest First'
                                        : 'Sorted by Newest First',
                                  ),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            });
                          },
                        ),

                      ],
                    ),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('posts')
                          .where('savedBy', arrayContains: FirebaseAuth.instance.currentUser!.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final posts = snapshot.data!.docs.map((doc) =>
                            PostModel.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList();

                        posts.sort((a, b) => _isSortedAscending
                            ? a.timestamp.compareTo(b.timestamp)
                            : b.timestamp.compareTo(a.timestamp));

                        if (posts.isEmpty) {
                          return const Center(child: Text('No bookmarked posts available.'));
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: posts.length,
                          itemBuilder: (context, index) {
                            final post = posts[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => Discussion(post: post)),
                                );
                              },
                              child: Card(
                                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Title: ${post.title}',
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Objective: ${post.objective}',
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 8),

                                      Text(
                                        'Posted by ${post.username}',
                                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                                      ),
                                      Text(
                                        'Date Time :  ${post.timestamp}',
                                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),

              ),

            if (selectedTabIndex == 3)
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Card(
                        margin: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome to MYTECH X! 🎉',
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Thank you for registering and being part of our community! Your support means everything, and we can’t wait for you to explore all the amazing features. If you ever need help, we’re here for you.',
                                style: TextStyle(fontSize: 16, color: Colors.black87),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Enjoy the journey, and happy exploring! 🚀',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),


            if (selectedTabIndex == 4)
              SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(Icons.access_time),
                          onPressed: () {
                            setState(() {
                              _isSortedAscending = !_isSortedAscending;

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    _isSortedAscending
                                        ? 'Sorted by Oldest First'
                                        : 'Sorted by Newest First',
                                  ),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            });
                          },
                        ),
                      ],
                    ),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('posts')
                          .where('likedBy', arrayContains: FirebaseAuth.instance.currentUser!.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final posts = snapshot.data!.docs.map((doc) =>
                            PostModel.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList();

                        posts.sort((a, b) => _isSortedAscending
                            ? a.timestamp.compareTo(b.timestamp)
                            : b.timestamp.compareTo(a.timestamp));

                        if (posts.isEmpty) {
                          return const Center(child: Text('No liked posts available.'));
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: posts.length,
                          itemBuilder: (context, index) {
                            final post = posts[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => Discussion(post: post)),
                                );
                              },
                              child: Card(
                                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Title: ${post.title}',
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Objective: ${post.objective}',
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Posted by ${post.username}',
                                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                                      ),
                                      Text(
                                        'Date Time: ${DateFormat('yyyy-MM-dd HH:mm').format(post.timestamp)}',
                                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),




          ],
          ),
        ),
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ProfileTab({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: selected ? Colors.blue : Colors.grey),
          Text(
            label,
            style: TextStyle(color: selected ? Colors.blue : Colors.grey),
          ),
        ],
      ),
    );
  }
}

class ProfileTabContent extends StatelessWidget {
  final String label;
  final String content;

  const ProfileTabContent({
    required this.label,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(content),
        ],
      ),
    );
  }
}
