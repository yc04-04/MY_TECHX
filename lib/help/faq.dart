import 'package:flutter/material.dart';

class FAQPage extends StatefulWidget {
  const FAQPage({super.key});

  @override
  _FAQPageState createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage> {
  final List<Map<String, String>> faqList = const [
    {
      'question': 'What is MYTECH X about?',
      'answer':
      'MYTECH X is a centralized platforms for innovators to share ideas and collaborate together. It provides bridging between government initiatives, academic research and industry needs.'
    },
    {
      'question': 'What can we do on MYTECH X?',
      'answer':
      'MYTECH X serves as a space for startups, researchers and investors to connect together, providing forum functionality to discuss and share ideas together with other collaborator. It also provides a database of funding opportunities, mentorship programs and research grants. In MYTECH X, you can also present your prototypes for potential partnerships and investment.',
    },
    {
      'question': 'What kind of idea can I share on MYTECH X?',
      'answer':
      'Any ideas involving technology are allowed on our platforms. This is a place to share innovative ideas, so feel free to post any of them.'
    },
    {
      'question': 'Is there specific guidelines on this platform regarding contents?',
      'answer':
      'MYTECH X is strictly a friendly platforms for discussing ideas with other investors and collaborators. As such, no explicit materials are to be posted on the platforms, nor any off-topic contents to be posted on our platform (e.g. content that are not related to technological ideas).\n\n'

          'While engaging in discussions with other users on the platform, it is important to discuss in a non-toxic and aggressive tone to prevent conflicts on out platform.\n\n'

          'MYTECH X also strictly forbids any scam funding events. Any of these events found will be removed off our platforms and investigation will be carried out against perpetrators.\n\n'

          'Repeated offense of explicit materials and aggression towards other users can get you banned. Offense of scam fundings will result in immediate account termination.\n\n'
    },
    {
      'question': 'I found some violating contents on the platform. What can I do?',
      'answer':
      'Reach out to use via emails provided in the Helpline section of our platforms. While filing a report, remember to attach a screenshots as evidence.\n'

          'MYTECH X does not tolerate false report, therefore it is important that you do not abuse this service, else your account can get removed off the platforms.'
    },
    {
      'question': 'I want to post an event with an image. How can I get the image URL?',
      'answer':
      'Assuming the image source already comes from other website, you can right click and select "Open image in a new tab" which redirects you to the image preview page. Copy the link and paste it in.'
    },
    {
      'question': 'The event image preview shows "Invalid Image URL". What can I do?',
      'answer':
      'These error message occur if the original source of the image does not allow public sharing of their images. You can refer to other public image sharing domain and copy the link instead.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FAQ',),
        backgroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: faqList.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ExpansionTile(
              title: Text(
                faqList[index]['question']!,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              children: [
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                  child: Text(
                    faqList[index]['answer']!,
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
