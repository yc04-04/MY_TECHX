import 'package:flutter/material.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';



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
    if (_formKey.currentState!.validate()) {
      try {
        // await FirebaseFirestore.instance.collection('fundingEvents').add({
        //   'title': _titleCtrl.text.trim(),
        //   'description': _descCtrl.text.trim(),
        //   'imageUrl': _imgUrlCtrl.text.trim(),
        //   'raised': 0,
        //   'goal': int.parse(_goalCtrl.text.trim()),
        // });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Funding event added successfully!')),
        );

        Navigator.pop(context); // Go back to the previous page
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
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
