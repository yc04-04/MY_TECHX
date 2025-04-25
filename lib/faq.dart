import 'package:flutter/material.dart';

class FAQPage extends StatelessWidget {
  const FAQPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FAQ'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Text('Frequently Asked Question Section:\n'
                '1. What is MYTECH X about?\n'
                'Answer: MYTECH X is a centralized platforms for innovators to share ideas and collaborate together. It provides bridging between government initiatives, academic research and industry needs.\n\n'
                '2. What can we do on MYTECH X?\n'
                'Answer: MYTECH X serves as a space for startups, researchers and investors to connect together, providing forum functionality to discuss and share ideas together with other collaborator. It also provides a database of funding opportunities, mentorship programs and research grants. In MYTECH X, you can also present your prototypes for potential partnerships and investment.\n\n'
                '3. What kind of idea can I share on MYTECH X?\n'
                'Answer: Any ideas involving technology are allowed on our platforms. This is a place to share innovative ideas, so feel free to post any of them.\n\n'
                '4. Is there specific guidelines on this platforms regarding contents?\n'
                'Answer: MYTECH X is strictly a friendly platforms for discussing ideas with other investors and collaborators. As such, no explicit materials are to be posted on the platforms, nor any off-topic contents to be posted on our platform (e.g. content that are not related to technological ideas).\n'
                'While engaging in discussions with other users on the platform, it is important to discuss in a non-toxic and aggressive tone to prevent conflicts on out platform.\n'
                'MYTECH X also strictly forbids any scam funding events. Any of these events found will be removed off our platforms and investigation will be carried out against perpetrators.\n'
                'Repeated offense of explicit materials and aggression towards other users can get you banned. Offense of scam fundings will result in immediate account termination.\n\n'
                '5. I found some violating contents on the platforms. What can I do?'
                'Answer: Reach out to use via emails provided in the Helpline section of our platforms. While filing a report, remember to attach a screenshots as evidence.\n'
                'MYTECH X does not tolerate false report, therefore it is important that you do not abuse this service, else your account can get removed off the platforms.')
          ],
        ),
      ),
    );
  }
}
