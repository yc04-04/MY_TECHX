import 'package:flutter/material.dart';

import 'addFunding.dart';

void main() {
  runApp(const FundingsPage());
}

class FundingsPage extends StatelessWidget {
  const FundingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Funding(title: 'Funding');
  }
}

class Funding extends StatefulWidget {
  const Funding({super.key, required this.title});
  final String title;

  @override
  State<Funding> createState() => _FundingState();
}

class _FundingState extends State<Funding> {
  List<Map<String, dynamic>> fundingEvents = [
    {
      'title': 'School Supplies for Kids',
      'description': 'Help provide school bags and books to underprivileged children.',
      'imageUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTEmwnh4yzIaPNypWWdU2_sgj4fzJt4Zp91UA&s',
      'raised': 350,
      'goal': 1000,
    },
    {
      'title': 'Community Clean-up',
      'description': 'Join us in cleaning up the local park and planting trees.',
      'imageUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTP0TF8oC6BMshRg7NqN2ETqjOYVyHvqQEiLw&s',
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

  void _showDonateDialog(BuildContext context, int index) {
    final _donationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Donation Amount'),
        content: TextField(
          controller: _donationController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'Amount (e.g., 50)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = int.tryParse(_donationController.text.trim());
              if (amount != null && amount > 0) {
                _donateToEvent(index, amount);
                Navigator.pop(context);
              }
            },
            child: const Text('Donate'),
          ),
        ],
      ),
    );
  }

  void _donateToEvent(int index, int amount) {
    setState(() {
      fundingEvents[index]['raised'] += amount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 10,
            childAspectRatio: 1,
          ),
          itemCount: fundingEvents.length,
          itemBuilder: (context, index) {
            final event = fundingEvents[index];
            final progress = (event['raised'] / event['goal']).clamp(0.0, 1.0);

            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: event['imageUrl'] == null || event['imageUrl'].isEmpty
                        ? Container(
                      height: 100,
                      width: double.infinity,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                    )
                        : Image.network(
                      event['imageUrl'],
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 100,
                          width: double.infinity,
                          color: Colors.grey.shade300,
                          child: const Text(
                              'No image found :/',
                            textAlign: TextAlign.center ,
                          ),
                        );
                      },
                    ),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event['title'],
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          event['description'],
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
                          'Raised: \$${event['raised']} of \$${event['goal']}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              _showDonateDialog(context, index);
                            },
                            child: const Text('Donate'),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: ElevatedButton(
        onPressed: (){
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddFunding(title: 'Add Funding'),
            ),
          ).then((newFunding) {
            if (newFunding != null) {
              setState(() {
                fundingEvents.add(newFunding);
              });
            }
          });

        },
        child: Text('Add Funding'),
      ),
    );
  }
}
