// === edit_post_screen.dart ===

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'post_model.dart';

class EditPostScreen extends StatefulWidget {
  final PostModel post;

  const EditPostScreen({super.key, required this.post});

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  late TextEditingController _titleController;
  late TextEditingController _objectiveController;
  late TextEditingController _detailsController;
  late String _businessCategory;
  late String _targetMarket;
  Uint8List? _imageBytes;
  XFile? _newImageFile;

  final List<String> _categories = [
    'Technology',
    'Retail',
    'Food & Beverage',
    'Healthcare',
    'Education',
    'Finance',
    'Entertainment',
    'Others'
  ];

  final List<String> _markets = [
    'Youth / Students',
    'Working Professionals',
    'Elderly',
    'Families',
    'Businesses',
    'Global Market',
    'Local Community'
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.post.title);
    _objectiveController = TextEditingController(text: widget.post.objective);
    _detailsController = TextEditingController(text: widget.post.details);
    _businessCategory = widget.post.toMap()['businessCategory'] ?? 'Others';
    _targetMarket = widget.post.toMap()['targetMarket'] ?? 'Local Community';
  }

  Future<void> _pickNewImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _newImageFile = picked;
      });
    }
  }

  Future<String> _uploadNewImage(XFile image) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('post_images')
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
    final uploadTask = await ref.putData(await image.readAsBytes());
    return await uploadTask.ref.getDownloadURL();
  }

  void updatePost() async {
    final postRef = FirebaseFirestore.instance.collection('posts').doc(widget.post.id);

    String? updatedImageUrl = widget.post.imageUrl;
    if (_newImageFile != null) {
      try {
        updatedImageUrl = await _uploadNewImage(_newImageFile!);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image upload failed. Please try again.')),
        );
        return;
      }
    }

    await postRef.update({
      'title': _titleController.text.trim(),
      'objective': _objectiveController.text.trim(),
      'details': _detailsController.text.trim(),
      'imageUrl': updatedImageUrl,
      'businessCategory': _businessCategory,
      'targetMarket': _targetMarket,
      'timestamp': Timestamp.now(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Post updated successfully')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Post')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _objectiveController,
              decoration: const InputDecoration(labelText: 'Objective'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _detailsController,
              maxLines: 5,
              decoration: const InputDecoration(labelText: 'Details'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _businessCategory,
              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (val) => setState(() => _businessCategory = val!),
              decoration: const InputDecoration(labelText: 'Business Category'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _targetMarket,
              items: _markets.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
              onChanged: (val) => setState(() => _targetMarket = val!),
              decoration: const InputDecoration(labelText: 'Target Market'),
            ),
            const SizedBox(height: 12),
            _imageBytes != null
                ? Image.memory(_imageBytes!, height: 150)
                : (widget.post.imageUrl.isNotEmpty
                ? Image.network(widget.post.imageUrl, height: 150)
                : const Text('No image')),
            ElevatedButton.icon(
              onPressed: _pickNewImage,
              icon: const Icon(Icons.image),
              label: const Text('Change Image'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: updatePost,
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
