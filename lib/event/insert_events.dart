import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';

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
  bool _isLoading = false;

  String imageUrl = '';

  void _saveRecord() async {
    final eventText = _eventController.text.trim();
    final imageText = _imageUrlController.text.trim();

    if (eventText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter event details.')),
      );
      return;
    }

    // Validate image URL if provided
    if (imageText.isNotEmpty) {
      Uri? uri;
      try {
        uri = Uri.parse(imageText);
        if (!uri.hasScheme || !(uri.scheme == 'http' || uri.scheme == 'https')) {
          throw Exception();
        }
      } catch (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid image URL format.')),
        );
        return;
      }

      final ImageStream stream = Image.network(imageText).image.resolve(const ImageConfiguration());
      final completer = Completer<void>();
      final listener = ImageStreamListener(
            (info, _) => completer.complete(),
        onError: (error, _) => completer.completeError('Invalid or unreachable image URL.'),
      );

      stream.addListener(listener);
      try {
        await completer.future;
      } catch (e) {
        stream.removeListener(listener);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
        return;
      }
      stream.removeListener(listener);
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = auth.currentUser;
      if (user != null) {
        await firestore.collection("events").add({
          "event": eventText,
          "imageUrl": imageText, // can be empty string
          "uid": user.uid,
          "timestamp": FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event posted successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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