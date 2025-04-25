import 'package:assignment_project/faq.dart';
import 'package:flutter/material.dart';

class HelplinesPage extends StatelessWidget {
  const HelplinesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Helpline'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Ensures text is left-aligned
          children: [
            const Text(
              'Socials:\n'
                  'Instagram/Threads/BlueSky:\n'
                  '@MYTECH_X\n'
                  'Facebook: MYTECH X\n'
                  'REDnote: MYTECH X\n\n'
                  'Community Support:\n'
                  '011-555 6677\n'
                  'commhelp@mytech.org.my\n\n'
                  'Developer Helpline:\n'
                  'devsupport@mytech.org.my',
            ),
            const Spacer(), // Pushes the button to the bottom of the screen
            Center( // Ensures the button is horizontally centered
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FAQPage()),
                  );
                },
                child: const Text('FAQ'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
