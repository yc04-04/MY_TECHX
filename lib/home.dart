import 'dart:convert'; // Add this import for base64 decoding
import 'package:assignment_project/fund/fund.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'discussion/discussion_page.dart';
import 'profile/profile.dart';
import 'discussion/discuss.dart';
import 'fund/funding.dart';
import 'event/events.dart';
import 'help/helpline.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  User? user = FirebaseAuth.instance.currentUser;

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser?.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text("Welcome...");
            }
            if (!snapshot.hasData || snapshot.data == null) {
              return const Text("Welcome, Guest");
            }
            var userData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
            var name = userData['name'] ?? "Guest";
            return Text("Welcome, $name");
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Profile()),
                );
              },
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser?.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data == null) {
                    return const CircleAvatar(
                      radius: 20,
                      child: Icon(Icons.person, size: 20),
                    );
                  }
                  var userData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
                  var profileImage = userData['profileImage'];

                  // Handle the profile image logic
                  if (profileImage != null && profileImage.isNotEmpty) {
                    // Check if the profile image is a base64 string
                    try {
                      final decodedImage = base64Decode(profileImage);
                      return CircleAvatar(
                        radius: 20,
                        backgroundImage: MemoryImage(decodedImage),
                      );
                    } catch (e) {
                      // If not base64, treat it as a URL and load as a network image
                      return CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(profileImage),
                      );
                    }
                  } else {
                    // Default profile icon if no image
                    return const CircleAvatar(
                      radius: 20,
                      child: Icon(Icons.person, size: 20),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.deepPurple),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(FirebaseAuth.instance.currentUser?.uid)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData || snapshot.data == null) {
                            return const CircleAvatar(
                              radius: 30,
                              child: Icon(Icons.person, size: 30),
                            );
                          }
                          var userData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
                          var profileImage = userData['profileImage'];

                          // Handle the profile image logic for the drawer
                          if (profileImage != null && profileImage.isNotEmpty) {
                            try {
                              final decodedImage = base64Decode(profileImage);
                              return CircleAvatar(
                                radius: 30,
                                backgroundImage: MemoryImage(decodedImage),
                              );
                            } catch (e) {
                              return CircleAvatar(
                                radius: 30,
                                backgroundImage: NetworkImage(profileImage),
                              );
                            }
                          } else {
                            return const CircleAvatar(
                              radius: 30,
                              child: Icon(Icons.person, size: 30),
                            );
                          }
                        },
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(FirebaseAuth.instance.currentUser?.uid)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData || snapshot.data == null) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text("Guest", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                  Text("No email", style: TextStyle(color: Colors.white70, fontSize: 14)),
                                ],
                              );
                            }
                            var userData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
                            String name = userData['name'] ?? "Guest";
                            String email = FirebaseAuth.instance.currentUser?.email ?? "No email";
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                Text(email, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
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
                ],
              ),
            ),
            _buildDrawerItem(Icons.person, "Profile", 0),
            _buildDrawerItem(Icons.dashboard, "Dashboard", 1),
            _buildDrawerItem(Icons.forum, "Discussions & Forums", 2),
            _buildDrawerItem(Icons.monetization_on, "Fundings", 3),
            _buildDrawerItem(Icons.event, "Events", 4),
            _buildDrawerItem(Icons.phone_in_talk, "Helplines", 5),
            _buildDrawerItem(Icons.account_balance_wallet, "Funding", 6),
          ],
        ),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              "Dashboard",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildDashboardSection(
                  context,
                  "assets/images/forum.jpg",
                  "Discussions & Forums",
                  "Engage in meaningful conversations with peers and experts.",
                  const DiscussionsPage(),
                ),
                _buildDashboardSection(
                  context,
                  "assets/images/fund.jpg",
                  "Fundings",
                  "Explore funding opportunities and financial support.",
                  const Fund(),
                ),
                _buildDashboardSection(
                  context,
                  "assets/images/event.jpg",
                  "Events",
                  "Stay updated on upcoming events and networking opportunities.",
                  const EventsPage(),
                ),
                _buildDashboardSection(
                  context,
                  "assets/images/help.png",
                  "Helplines",
                  "Get assistance and support when you need it.",
                  const HelplinesPage(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, int index) {
    return ListTile(
      leading: index == 0
          ? StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return const CircleAvatar(
              radius: 20,
              child: Icon(Icons.person, size: 20),
            );
          }
          var userData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
          var profileImage = userData['profileImage'];

          // Handle the profile image logic
          if (profileImage != null && profileImage.isNotEmpty) {
            try {
              final decodedImage = base64Decode(profileImage);
              return CircleAvatar(
                radius: 20,
                backgroundImage: MemoryImage(decodedImage),
              );
            } catch (e) {
              return CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(profileImage),
              );
            }
          } else {
            return const CircleAvatar(
              radius: 20,
              child: Icon(Icons.person, size: 20),
            );
          }
        },
      )
          : Icon(icon, color: Colors.deepPurple),
      title: Text(title),
      selected: _selectedIndex == index,
      onTap: () {
        if (index == 0) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const Profile()));
        } else if (index == 2) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const DiscussionsPage()));
        } else if (index == 3) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const FundingsPage()));
        } else if (index == 4) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const EventsPage()));
        } else if (index == 5) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const HelplinesPage()));
        } else if (index == 6) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const Fund()));
        }else {
          setState(() {
            _selectedIndex = index;
          });
          Navigator.pop(context);
        }
      },
    );
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
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDashboardSection(
      BuildContext context, String imagePath, String title, String description, Widget page) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(vertical: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(imagePath, width: 80, height: 80, fit: BoxFit.cover),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(description, style: const TextStyle(fontSize: 14, color: Colors.black54)),
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
