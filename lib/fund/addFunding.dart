import 'package:flutter/material.dart';

class AddFunding extends StatefulWidget {
  const AddFunding({super.key, required this.title});

  final String title;

  @override
  State<AddFunding> createState() => _AddFundingState();
}

class _AddFundingState extends State<AddFunding> {
  final _formKey = GlobalKey<FormState>();
  final _descCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _imgUrlCtrl = TextEditingController();
  final _goalCtrl = TextEditingController();

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

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final newFunding = {
        'title': _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'imageUrl': _imgUrlCtrl.text.trim(),
        'raised': 0,
        'goal': int.parse(_goalCtrl.text.trim()),
      };

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Funding event added successfully!')),
      );

      Navigator.pop(context, newFunding); // Pass back the new event
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
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a description'
                    : null,
              ),
              TextFormField(
                controller: _imgUrlCtrl,
                decoration: const InputDecoration(labelText: 'Image URL'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter an image URL'
                    : null,
              ),
              TextFormField(
                controller: _goalCtrl,
                decoration: const InputDecoration(labelText: 'Donation Goal'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a donation goal';
                  } else if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Please enter a valid goal';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Submit Funding'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
