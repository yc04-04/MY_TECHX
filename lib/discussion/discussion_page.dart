import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'post_model.dart';
import 'create_post_screen.dart';
import 'discuss.dart';

class DiscussionsPage extends StatefulWidget {
  const DiscussionsPage({super.key});

  @override
  _DiscussionsPageState createState() => _DiscussionsPageState();
}

class _DiscussionsPageState extends State<DiscussionsPage> {
  String filter = 'latest';

  Stream<QuerySnapshot> getPostsStream() {
    return FirebaseFirestore.instance
        .collection('posts')
        .orderBy(filter == 'latest' ? 'timestamp' : 'likes', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Forum'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (val) => setState(() => filter = val),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'latest', child: Text('Latest')),
              PopupMenuItem(value: 'likes', child: Text('Most Liked')),
            ],
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getPostsStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final posts = snapshot.data!.docs.map((doc) =>
              PostModel.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList();

          if (posts.isEmpty) return const Center(child: Text('No posts available.'));

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              final double goal = post.toMap()['donationGoal'] is num
                  ? (post.toMap()['donationGoal'] as num).toDouble()
                  : 0.0;
              final double amount = post.donationAmount;
              final double percentage = goal > 0 ? (amount / goal * 100).clamp(0.0, 100.0) : 0.0;

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
                                      Text('${percentage.toStringAsFixed(0)}% funded', style: const TextStyle(fontSize: 11)),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreatePostScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}



