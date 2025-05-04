import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'faq.dart';

class HelplinesPage extends StatelessWidget {
  const HelplinesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Helpline'),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSection(
              title: 'Socials',
              contentWidgets: [
                _linkText('Instagram/Threads/BlueSky: ', '@MYTECH_X',
                    'https://instagram.com/MYTECH_X'),
                _linkText(
                    'Facebook: ', 'MYTECH X', 'https://facebook.com/MYTECHX'),
                _linkText('REDnote: ', 'MYTECH X', 'https://rednote.com/MYTECHX'),
              ],
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: 'Community Helpline',
              contentWidgets: [],
              actions: [
                _contactTile(
                  icon: Icons.phone,
                  label: '011-555 6677',
                  onTap: () => _launchPhone('+60115556677', context),
                ),
                _contactTile(
                  icon: Icons.email,
                  label: 'commhelp@mytech.org.my',
                  onTap: () => _launchEmail('commhelp@mytech.org.my', context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: 'Developer Helpline',
              contentWidgets: [],
              actions: [
                _contactTile(
                  icon: Icons.email,
                  label: 'devsupport@mytech.org.my',
                  onTap: () =>
                      _launchEmail('devsupport@mytech.org.my', context),
                ),
              ],
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const FAQPage()),
                    );
                  },
                  icon: const Icon(Icons.help_outline),
                  label: const Text('View FAQ'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    List<Widget>? contentWidgets,
    List<Widget>? actions,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (contentWidgets != null &&
                contentWidgets.isNotEmpty) ...contentWidgets,
            if (actions != null && actions.isNotEmpty) ...actions,
          ],
        ),
      ),
    );
  }

  Widget _contactTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(
        label,
        style: const TextStyle(color: Colors.blue, fontSize: 16),
      ),
      onTap: onTap,
    );
  }

  Widget _linkText(String text, String name, String url) {
    return InkWell(
      onTap: () async {
        final Uri uri = Uri.parse(url);
        if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
          // Show a message if the URL cannot be launched
          throw 'Could not launch $url';
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text.rich(
          TextSpan(
            text: '$text ', // This part is non-clickable (e.g., "Facebook")
            style: const TextStyle(
              color: Colors.black, // Make this part regular text color
              fontSize: 16,
            ),
            children: [
              TextSpan(
                text: name, // This part is clickable (e.g., "MYTECH X")
                style: const TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


// Utilities
  Future<void> _launchPhone(String number, BuildContext context) async {
    final Uri uri = Uri(scheme: 'tel', path: number);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // Show an error message if the phone link cannot be launched
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $uri')),
      );
    }
  }

  Future<void> _launchEmail(String email, BuildContext context) async {
    final Uri uri = Uri(scheme: 'mailto', path: email);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $uri')),
      );
    }
  }
}
