// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// ElevatedButton(
// onPressed: (){
// Navigator.push(
// context,
// MaterialPageRoute(
// builder: (context) => Fundings(),)
// );
// },
// child: const Text('Event Button'))
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'addFunding.dart'

class FundingsPage extends StatelessWidget {
  const FundingsPage({super.key});

// This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Funding',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const Funding(title: 'Funding'),

    );
  }
}

//create state
class Funding extends StatefulWidget {
  const Funding({super.key, required this.title});

  final String title;

  @override
  State<Funding> createState() => _MyHomePageState();
}

//Funding item class
class FundingCard extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;
  final int raised;
  final int goal;

  const FundingCard({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.raised,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (raised / goal).clamp(0.0, 1.0);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              imageUrl,
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8),

                // Progress Bar
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
                SizedBox(height: 4),

                // Raised / Goal Text
                Text(
                  'Raised: \$${raised} of \$${goal}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),

                SizedBox(height: 8),
                // Donate Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _showDonateDialog;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Donate clicked on $title')),
                      );
                    },
                    child: Text('Donate'),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MyHomePageState extends State<Funding> {

  List<Map<String, dynamic>> fundingEvents = [
    {
      'title': 'School Supplies for Kids',
      'description': 'Help provide school bags and books to underprivileged children.',
      'imageUrl': 'https://via.placeholder.com/150',
      'raised': 350,
      'goal': 1000,
    },
    {
      'title': 'Community Clean-up',
      'description': 'Join us in cleaning up the local park and planting trees.',
      'imageUrl': 'https://via.placeholder.com/150',
      'raised': 600,
      'goal': 1500,
    },
    {
      'title': 'Medical Aid for Families',
      'description': 'Support families who need urgent medical assistance.',
      'imageUrl': 'https://via.placeholder.com/150',
      'raised': 1200,
      'goal': 2000,
    },
    {
      'title': 'Animal Shelter Renovation',
      'description': 'Help us renovate the local animal shelter and provide better facilities.',
      'imageUrl': 'https://via.placeholder.com/150',
      'raised': 800,
      'goal': 1800,
    },
    {
      'title': 'Food Drive',
      'description': 'Donate to our food drive to feed homeless individuals.',
      'imageUrl': 'https://via.placeholder.com/150',
      'raised': 500,
      'goal': 1000,
    },
    {
      'title': 'Scholarship Fund',
      'description': 'Support scholarships for students in need.',
      'imageUrl': 'https://via.placeholder.com/150',
      'raised': 900,
      'goal': 2500,
    },
  ];

  void _showDonateDialog(BuildContext context, Function(int) onDonate) {
    final _donationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enter Donation Amount'),
        content: TextField(
          controller: _donationController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(hintText: 'Amount (e.g., 50)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = int.tryParse(_donationController.text.trim());
              if (amount != null && amount > 0) {
                onDonate(amount);
                Navigator.pop(context);
              } else {
                // Optionally show an error
              }
            },
            child: Text('Donate'),
          ),
        ],
      ),
    );
  }

  void _donateToEvent(int index, int amount) {
    setState(() {
      fundingEvents[index]['raised'] += amount;
    });

    FirebaseFirestore.instance
        .collection('fundingEvents')
        .doc(fundingEvents[index][id])  // make sure you store the document ID!
        .update({'raised': fundingEvents[index]['raised']});
  }

  @override
  //display
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        leading: IconButton(
            onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AddFunding(title: '',)),
              );
            },
            icon: const Icon(Icons.add)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddFunding(title: 'Add Fundings'),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore.collection("events").orderBy('timestamp', descending: true).snapshots(),
    builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
    return const Center(child: CircularProgressIndicator());
    } else if (snapshot.hasError) {
    return const Center(child: Text('Something went wrong.'));
    } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
    return const Center(child: Text('No events posted.'));
    }

    final fund = snapshot.data!.docs;
    const Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8, // horizontal space
            mainAxisSpacing: 10, // vertical space
            childAspectRatio: 1,
          ),
          itemCount: fundingEvents.length,
          itemBuilder: (context, index) {
            final fund = fundingEvents[index];
            return FundingCard(
              title: event['title'],
              description: event['description'],
              imageUrl: event['imageUrl'],
              raised: event['raised'],
              goal: event['goal'],
            );

          },
        ),

      ),

      floatingActionButton: ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text('back'),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
