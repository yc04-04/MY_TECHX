import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'post_model.dart';
import 'edit_post_screen.dart';

class Discussion extends StatefulWidget {
  final PostModel post;
  const Discussion({super.key, required this.post});

  @override
  State<Discussion> createState() => _DiscussionState();
}

class _DiscussionState extends State<Discussion> {
  final _commentController = TextEditingController();
  final Map<String, TextEditingController> _replyControllers = {};
  final Map<String, bool> _showReplyInput = {};
  bool isSaved = false;
  bool isAuthor = false;
  final uid = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    isSaved = widget.post.savedBy.contains(uid);
    isAuthor = widget.post.userId == uid;
  }

  void toggleLike(String postId, List likedBy) async {
    if (uid == null) return;
    final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);
    if (likedBy.contains(uid)) {
      await postRef.update({
        'likes': FieldValue.increment(-1),
        'likedBy': FieldValue.arrayRemove([uid]),
      });
    } else {
      await postRef.update({
        'likes': FieldValue.increment(1),
        'likedBy': FieldValue.arrayUnion([uid]),
      });
    }
  }

  void toggleSave() async {
    if (uid == null) return;
    final postRef = FirebaseFirestore.instance.collection('posts').doc(widget.post.id);
    setState(() => isSaved = !isSaved);
    await postRef.update({
      'savedBy': isSaved ? FieldValue.arrayUnion([uid]) : FieldValue.arrayRemove([uid]),
    });
  }

  void donate() async {
    final postRef = FirebaseFirestore.instance.collection('posts').doc(widget.post.id);
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Donate to this Post', style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          decoration: const InputDecoration(
            labelText: 'Amount (RM)',
            hintText: 'e.g. 10.00',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () async {
              final amountText = amountController.text.trim();
              final amount = double.tryParse(amountText);
              if (amount != null && (amount * 100).roundToDouble() == amount * 100 && amount > 0) {
                await postRef.update({
                  'donationAmount': FieldValue.increment(amount),
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Thank you for donating RM${amount.toStringAsFixed(2)}!')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Enter a valid amount (e.g. 10.00, 5.50)')),
                );
              }
            },
            child: const Text('Donate'),
          ),
        ],
      ),
    );
  }

  void submitReply(String commentId) async {
    final user = FirebaseAuth.instance.currentUser;
    final replyText = _replyControllers[commentId]?.text.trim() ?? '';
    if (user == null || replyText.isEmpty) return;

    await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.post.id)
        .collection('comments')
        .doc(commentId)
        .collection('replies')
        .add({
      'text': replyText,
      'uid': user.uid,
      'username': user.email ?? 'User',
      'timestamp': Timestamp.now(),
    });

    _replyControllers[commentId]?.clear();
    setState(() => _showReplyInput[commentId] = false);
  }

  void likeComment(String commentId) async {
    final ref = FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.post.id)
        .collection('comments')
        .doc(commentId);

    final snap = await ref.get();
    final likedBy = List<String>.from(snap['likedBy'] ?? []);

    if (likedBy.contains(uid)) {
      await ref.update({
        'likes': FieldValue.increment(-1),
        'likedBy': FieldValue.arrayRemove([uid]),
      });
    } else {
      await ref.update({
        'likes': FieldValue.increment(1),
        'likedBy': FieldValue.arrayUnion([uid]),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('posts').doc(widget.post.id).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final post = snapshot.data!.data() as Map<String, dynamic>;
        final likedBy = List<String>.from(post['likedBy'] ?? []);
        final timestamp = (post['timestamp'] as Timestamp).toDate();
        final donationAmount = (post['donationAmount'] ?? 0).toDouble();
        final donationGoal = (post['donationGoal'] ?? 0).toDouble();
        final progress = donationGoal > 0 ? (donationAmount / donationGoal).clamp(0.0, 1.0) : 0.0;

        return Scaffold(
          appBar: AppBar(
            title: Text(post['title'] ?? ''),
            actions: isAuthor
                ? [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditPostScreen(post: widget.post),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  await FirebaseFirestore.instance.collection('posts').doc(widget.post.id).delete();
                  Navigator.pop(context);
                },
              )
            ]
                : null,
          ),
          body: Column(
            children: [
              if ((post['imageUrl'] ?? '').isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(post['imageUrl'], fit: BoxFit.cover),
                ),
              Card(
                elevation: 3,
                margin: const EdgeInsets.all(10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Title: ${post['title']}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text("Objective: ${post['objective']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text(post['details'] ?? ''),
                      const SizedBox(height: 6),
                      if (post['businessCategory'] != null)
                        Text("Business Category: ${post['businessCategory']}", style: const TextStyle(color: Colors.teal)),
                      if (post['targetMarket'] != null)
                        Text("Target Market: ${post['targetMarket']}", style: const TextStyle(color: Colors.indigo)),
                      const SizedBox(height: 6),
                      Text('Posted at ${DateFormat('hh:mm a, MMM dd yyyy').format(timestamp)}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      const Divider(),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(likedBy.contains(uid) ? Icons.thumb_up : Icons.thumb_up_alt_outlined),
                            onPressed: () => toggleLike(widget.post.id, likedBy),
                          ),
                          Text('${post['likes']} Likes'),
                          IconButton(
                            icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border),
                            onPressed: toggleSave,
                          ),
                          ElevatedButton(
                            onPressed: donate,
                            child: const Text('Donate'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('RM ${donationAmount.toStringAsFixed(2)} / RM ${donationGoal.toStringAsFixed(2)} collected'),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey.shade300,
                        color: Colors.green,
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: const InputDecoration(hintText: 'Add a comment'),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () async {
                        final text = _commentController.text.trim();
                        if (text.isEmpty || uid == null) return;
                        await FirebaseFirestore.instance
                            .collection('posts')
                            .doc(widget.post.id)
                            .collection('comments')
                            .add({
                          'text': text,
                          'uid': uid,
                          'username': FirebaseAuth.instance.currentUser?.email ?? 'User',
                          'timestamp': Timestamp.now(),
                          'likes': 0,
                          'likedBy': [],
                        });
                        _commentController.clear();
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('posts')
                      .doc(widget.post.id)
                      .collection('comments')
                      .orderBy('timestamp')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                    final comments = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        final data = comment.data() as Map<String, dynamic>;
                        final cid = comment.id;
                        final isCommentAuthor = data['uid'] == uid;
                        _replyControllers[cid] ??= TextEditingController();
                        _showReplyInput[cid] ??= false;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              title: Text(data['username'] ?? 'User', style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(data['text']),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.thumb_up),
                                    onPressed: () async => likeComment(cid),
                                  ),
                                  Text('${data['likes'] ?? 0}'),
                                  if (isCommentAuthor)
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () async {
                                        await FirebaseFirestore.instance
                                            .collection('posts')
                                            .doc(widget.post.id)
                                            .collection('comments')
                                            .doc(cid)
                                            .delete();
                                      },
                                    ),
                                  IconButton(
                                    icon: const Icon(Icons.reply),
                                    onPressed: () => setState(() => _showReplyInput[cid] = !_showReplyInput[cid]!),
                                  )
                                ],
                              ),
                            ),
                            if (_showReplyInput[cid]!)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _replyControllers[cid],
                                        decoration: const InputDecoration(hintText: 'Reply...'),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.send),
                                      onPressed: () => submitReply(cid),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
