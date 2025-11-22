import 'package:flutter/material.dart';
import 'package:travel_diary_mob_app/presentation/screens/shorts/widgets/short_video_view.dart';

class ShortsScreen extends StatefulWidget {
  const ShortsScreen({super.key});

  @override
  State<ShortsScreen> createState() => _ShortsScreenState();
}

class _ShortsScreenState extends State<ShortsScreen> {
  final PageController _pageController = PageController();

  final List<String> videoUrls = [
    "https://samplelib.com/lib/preview/mp4/sample-5s.mp4",
    "https://samplelib.com/lib/preview/mp4/sample-10s.mp4",
    "https://samplelib.com/lib/preview/mp4/sample-15s.mp4",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: videoUrls.length,
        itemBuilder: (context, i) {
          return ShortVideoView(
            videoUrl: videoUrls[i],
            username: "traveller_$i",
            title: "Exploring Nature Scene $i",
          );
        },
      ),
    );
  }
}
