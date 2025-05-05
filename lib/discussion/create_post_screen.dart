import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _titleController = TextEditingController();
  final _objectiveController = TextEditingController();
  final _detailsController = TextEditingController();
  final _donationGoalController = TextEditingController();

  bool isUploading = false;

  final List<String> businessCategories = [
    'Technology',
    'Retail',
    'Food & Beverage',
    'Healthcare',
    'Education',
    'Finance',
    'Entertainment',
    'Others'
  ];
  final List<String> targetMarkets = [
    'Youth / Students',
    'Working Professionals',
    'Elderly',
    'Families',
    'Businesses',
    'Global Market',
    'Local Community'
  ];

  String? selectedCategory;
  String? selectedTargetMarket;





  void _submitPost() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final title = _titleController.text.trim();
    final objective = _objectiveController.text.trim();
    final details = _detailsController.text.trim();
    final donationGoalText = _donationGoalController.text.trim();
    final donationGoal = double.tryParse(donationGoalText);

    if (title.isEmpty ||
        objective.isEmpty ||
        details.isEmpty ||
        donationGoal == null ||
        donationGoal <= 0 ||
        selectedCategory == null ||
        selectedTargetMarket == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields correctly.')),
      );
      return;
    }

    setState(() => isUploading = true);

    @override
    void dispose() {
      _titleController.dispose();
      _objectiveController.dispose();
      _detailsController.dispose();
      _donationGoalController.dispose();
      super.dispose();
    }

    final post = {
      'title': title,
      'objective': objective,
      'details': details,
      'username': user.email ?? 'User',
      'userId': user.uid,
      'timestamp': Timestamp.now(),
      'likes': 0,
      'donationGoal': donationGoal,
      'donationAmount': 0.0,
      'savedBy': [],
      'likedBy': [],
      'businessCategory': selectedCategory,
      'targetMarket': selectedTargetMarket,
    };

    await FirebaseFirestore.instance.collection('posts').add(post);

    setState(() => isUploading = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Post')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _objectiveController,
              decoration: const InputDecoration(labelText: 'Objective'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _detailsController,
              decoration: const InputDecoration(labelText: 'Business Description'),
              maxLines: 5,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _donationGoalController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              decoration: const InputDecoration(labelText: 'Donation Goal (e.g. 100.00)'),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: const InputDecoration(labelText: 'Business Category'),
              items: businessCategories.map((cat) {
                return DropdownMenuItem(value: cat, child: Text(cat));
              }).toList(),
              onChanged: (val) => setState(() => selectedCategory = val),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedTargetMarket,
              decoration: const InputDecoration(labelText: 'Target Market'),
              items: targetMarkets.map((market) {
                return DropdownMenuItem(value: market, child: Text(market));
              }).toList(),
              onChanged: (val) => setState(() => selectedTargetMarket = val),
            ),
            const SizedBox(height: 20),
            isUploading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _submitPost,
              child: const Text('Post'),
            ),
          ],
        ),
      ),
    );
  }
}