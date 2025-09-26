import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'add.dart';

void main() {
  runApp(const Fund());
}

class Fund extends StatelessWidget {
  const Fund({super.key});

  @override
  Widget build(BuildContext context) {
    return const Funding(title: 'Funding');
  }
}
class Funding extends StatefulWidget {
  const Funding({super.key, required this.title});
  final String title;

  @override
  State<Funding> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Funding> {
  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore.collection('fundingEvents').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No funding events found.'));
          }

          final docs = snapshot.data!.docs;

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // make it 2 for better layout
                crossAxisSpacing: 8,
                mainAxisSpacing: 10,
                childAspectRatio: 0.8,
              ),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final doc = docs[index];
                final data = doc.data() as Map<String, dynamic>;

                return FundingCard(
                  docId: doc.id,
                  title: data['title'] ?? '',
                  description: data['description'] ?? '',
                  imageUrl: data['imageUrl'] ?? 'https://via.placeholder.com/150',
                  raised: data['raised'] ?? 0,
                  goal: data['goal'] ?? 1,
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: IconButton(
    onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddFund(title: 'Add Fundings')),
        );
      },
     icon: const Icon(Icons.add),
    ),
    );
  }
}

class FundingCard extends StatelessWidget {
  final String docId;
  final String title;
  final String description;
  final String imageUrl;
  final int raised;
  final int goal;

  const FundingCard({
    required this.docId,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.raised,
    required this.goal,
    super.key,
  });

  Future<void> _showDonateDialog(BuildContext context) async {
    final _amountController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Donate to $title'),
        content: TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'Enter amount'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final entered = _amountController.text.trim();
              final amount = int.tryParse(entered);
              if (amount == null || amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid amount.')),
                );
                return;
              }

              try {
                final docRef = FirebaseFirestore.instance.collection('fundingEvents').doc(docId);

                await FirebaseFirestore.instance.runTransaction((transaction) async {
                  final snapshot = await transaction.get(docRef);
                  final currentRaised = snapshot['raised'] ?? 0;
                  transaction.update(docRef, {
                    'raised': currentRaised + amount,
                  });
                });

                Navigator.pop(context); // close dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Thank you for donating \$${amount}!')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Donation failed: $e')),
                );
              }
            },
            child: const Text('Donate'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = (raised / goal).clamp(0.0, 1.0);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              imageUrl,
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 100,
                  width: double.infinity,
                  color: Colors.blueAccent,
                  child: const Text(
                    'No image found :/',
                    textAlign: TextAlign.center ,
                  ),
                );
              },
            ),
          ),
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
                const SizedBox(height: 4),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                ),
                const SizedBox(height: 4),
                Text(
                  'Raised: \$${raised} of \$${goal}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _showDonateDialog(context),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text('Donate'),
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
