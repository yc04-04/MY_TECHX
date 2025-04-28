import 'package:assignment_project/faq.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
          crossAxisAlignment: CrossAxisAlignment.start,
          // Ensures text is left-aligned
          children: [
            const Text(
              'Socials:\n'
                  'Instagram/Threads/BlueSky: @MYTECH_X\n'
                  'Facebook: MYTECH X\n'
                  'REDnote: MYTECH X\n\n'
                  'Community Helpline: '
            ),
            GestureDetector(
              onTap: () => _launchPhone(),
              child: Text(
                '011-555 6677',
                style: TextStyle(color: Colors.blue, fontSize: 18),
              ),
            ),
            GestureDetector(
              onTap: () => _launchEmail(),
              child: Text(
                'commhelp@mytech.org.my',
                style: TextStyle(color: Colors.blue, fontSize: 18),
              ),
            ),
            const Text(
                '\nDeveloper Helpline:'
            ),
            GestureDetector(
              onTap: () => _launchEmail(),
              child: Text(
                'devsupport@mytech.org.my',
                style: TextStyle(color: Colors.blue, fontSize: 18),
              ),
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

Future<void> _launchPhone() async {
  final phoneUrl = 'tel:+60115556677'; // Replace with the phone number
  if (await canLaunch(phoneUrl)) {
    await launch(phoneUrl);
  } else {
    throw 'Could not launch $phoneUrl';
  }
}

Future<void> _launchEmail() async {
  final emailUrl = 'mailto:example@example.com'; // Replace with the email address
  if (await canLaunch(emailUrl)) {
    await launch(emailUrl);
  } else {
    throw 'Could not launch $emailUrl';
  }
}
