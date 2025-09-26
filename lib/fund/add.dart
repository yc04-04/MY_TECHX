import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class AddFund extends StatefulWidget {
  const AddFund({super.key, required this.title});

  final String title;

  @override
  State<AddFund> createState() => _InsertFundingState();
}

class _InsertFundingState extends State<AddFund> {
  final _formKey = GlobalKey<FormState>();
  final _descCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _imgUrlCtrl = TextEditingController();
  final _goalCtrl = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _imgUrlCtrl.dispose();
    _goalCtrl.dispose();
    super.dispose();
  }

  void _clearAll() {
    _titleCtrl.clear();
    _descCtrl.clear();
    _imgUrlCtrl.clear();
    _goalCtrl.clear();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final String title = _titleCtrl.text.trim();
    final String desc = _descCtrl.text.trim();
    final String imgUrl = _imgUrlCtrl.text.trim();
    final String goalText = _goalCtrl.text.trim();
    final int goal = int.tryParse(goalText) ?? 0;

    if (goal <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid goal amount.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('fundingEvents').add({
          'title': title,
          'description': desc,
          'imageUrl': imgUrl,
          'raised': 0,
          'goal': goal,
          'createdBy': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Funding event posted successfully!')),
        );

        _clearAll();
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in.')),
        );
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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Add Funding Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Please enter a title' : null,
              ),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Please enter a description' : null,
              ),
              TextFormField(
                controller: _imgUrlCtrl,
                decoration: const InputDecoration(labelText: 'Image URL (optional)'),
              ),
              TextFormField(
                controller: _goalCtrl,
                decoration: const InputDecoration(labelText: 'Donation Goal'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a donation goal';
                  }
                  final parsed = int.tryParse(value);
                  if (parsed == null || parsed <= 0) {
                    return 'Please enter a valid number greater than 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Submit Funding'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
