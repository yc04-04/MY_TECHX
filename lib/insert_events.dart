import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class InsertEvents extends StatefulWidget {
  const InsertEvents({super.key, required this.title});
  final String title;

  @override
  State<InsertEvents> createState() => _InsertEventsState();
}

class _InsertEventsState extends State<InsertEvents> {
  final _eventController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final firestore = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  String imageUrl = '';

  void _saveRecord() async {
    final user = auth.currentUser;
    if (user != null) {
      await firestore.collection("events").add({
        "event": _eventController.text.trim(),
        "imageUrl": _imageUrlController.text.trim(),
        "uid": user.uid,
        "timestamp": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event posted successfully!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Event Details Input Box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: TextFormField(
                controller: _eventController,
                decoration: const InputDecoration(
                  hintText: 'Enter event details...',
                  border: InputBorder.none,
                ),
                maxLines: 3,
              ),
            ),
            const SizedBox(height: 16),

            // Image URL Input
            TextField(
              controller: _imageUrlController,
              decoration: const InputDecoration(labelText: 'Image URL'),
              onChanged: (value) {
                setState(() {
                  imageUrl = value.trim();
                });
              },
            ),
            const SizedBox(height: 16),

            // Subtle Image Placeholder
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade400),
                color: Colors.grey.shade200,
              ),
              alignment: Alignment.center,
              child: imageUrl.isNotEmpty
                  ? Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Text('Invalid Image URL');
                },
              )
                  : const Text('Image preview will appear here',
                  style: TextStyle(color: Colors.grey)),
            ),
            const SizedBox(height: 24),

            // Post Event Button at the Bottom
            ElevatedButton(
              onPressed: _saveRecord,
              child: const Text('Post Event'),
            ),
          ],
        ),
      ),
    );
  }
}