import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../business_logic/app_bloc/app_bloc.dart';
import '../../../business_logic/app_bloc/app_event.dart';
import '../../../business_logic/app_bloc/app_state.dart';
import '../../../data/models/post_model.dart';
import '../../widgets/loading_widget.dart';
import 'widgets/short_video_view.dart';

class ShortsScreen extends StatefulWidget {
  const ShortsScreen({super.key});

  @override
  State<ShortsScreen> createState() => _ShortsScreenState();
}

class _ShortsScreenState extends State<ShortsScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // Load initial shorts
    context.read<AppBloc>().add(LoadShorts(refresh: true));

    // Add listener for pagination
    _pageController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_pageController.position.pixels >=
        _pageController.position.maxScrollExtent * 0.8) {
      // Load more shorts when near the end
      context.read<AppBloc>().add(LoadShorts(refresh: false));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocBuilder<AppBloc, AppState>(
        builder: (context, state) {
          // Show loading indicator for initial load
          if (state.isLoadingShorts && state.shorts.isEmpty) {
            return const Center(
              child: LoadingWidget(),
            );
          }

          // Show error if no shorts available
          if (state.shorts.isEmpty && !state.isLoadingShorts) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.video_library_outlined,
                    size: 64,
                    color: Colors.white54,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No shorts available',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      context.read<AppBloc>().add(LoadShorts(refresh: true));
                    },
                    child: const Text('Refresh'),
                  ),
                ],
              ),
            );
          }

          // Display shorts in vertical PageView
          return PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: state.shorts.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemBuilder: (context, index) {
              final short = state.shorts[index];

              // Only render shorts (filter by type)
              if (short.type != PostType.short) {
                return const SizedBox.shrink();
              }

              // Simply pass the post, the widget handles everything
              return ShortVideoView(post: short);
            },
          );
        },
      ),
    );
  }
}