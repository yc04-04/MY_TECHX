import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';


class AddFunding extends StatefulWidget {
  const AddFunding({super.key, required this.title});

  final String title;

  @override
  State<AddFunding> createState() => _InsertFundingState();
}

class _InsertFundingState extends State<AddFunding> {
  final _formKey = GlobalKey<FormState>();
  final _descCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _imgUrlCtrl = TextEditingController();
  final _goalCtrl = TextEditingController();

  Future<void> _submitForm() async {
        await FirebaseFirestore.instance.collection('fundingEvents').add({
          final title: _titleCtrl.text.trim(),
          final desc: _descCtrl.text.trim(),
          final imgUrl: _imgUrlCtrl.text.trim(),
          double raised: 0,
          final goal: int.parse(_goalCtrl.text.trim()),
        };

    if (title.isEmpty)
        {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Add a Title!')),
          );
          return;
        }

    if (desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Add description!')),
      );
      return;
    }

    if (imgUrl.isEmpty) {
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

        if(goal.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Add a goal!')),
      );
      return;
    }
        setState(() {
          _isLoading = true;
        });

        try {
          final user = auth.currentUser;
          if (user != null) {
            await firestore.collection("fund").add({
              "title": title,
              "desc": desc, // can be empty string
              "imgUrl": imgUrl,
              "goal": goal,
              "raised": raised,
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Funding event posted successfully!')),
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
  void dispose(){
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _imgUrlCtrl.dispose();
    _goalCtrl.dispose();
    super.dispose();
  }

  @override
  void _clearAll(){
    _titleCtrl.clear();
    _descCtrl.clear();
    _imgUrlCtrl.clear();
    _goalCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Add Funding Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
            child: ListView(
              children: [
                TextFormField(
                  controller: _titleCtrl,
                  decoration: InputDecoration(
                    labelText: 'Title'
                  ),
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Please enter a title' : null,
                ),
                TextFormField(
                  controller: _descCtrl,
                  decoration: InputDecoration(
                      labelText: 'Description'
                  ),
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Please put a description' : null,
                ),
                TextFormField(
                  controller: _imgUrlCtrl,
                  decoration: InputDecoration(
                      labelText: 'Image URL'
                  ),
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Please enter an image URL' : null,
                ),
                TextFormField(
                  controller: _goalCtrl,
                  decoration: InputDecoration(
                      labelText: 'Donation Goal'
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value){
                    if (value == null || value.isEmpty){
                      return 'PLease enter a Dono goal';
                    }else if (int.tryParse(value)! <= 0){
                      return 'Please enter a valid goal';
                    } else {
                      return null;
                    }
                  },
                ),
                SizedBox(height: 20,),
                ElevatedButton(
                    onPressed: (){
                      _submitForm;
                      _clearAll;},
                    child: Text('Submit Funding'))
              ],
            )
        ),
      ),
    );
  }
}
