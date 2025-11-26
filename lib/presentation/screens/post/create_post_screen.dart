import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../business_logic/app_bloc/app_bloc.dart';
import '../../../business_logic/app_bloc/app_event.dart';
import '../../../business_logic/app_bloc/app_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/file_helper.dart';
import '../../../core/constants/app_constants.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class CreatePostScreen extends StatefulWidget {
  final VoidCallback? onPostCreated;
  
  const CreatePostScreen({super.key, this.onPostCreated});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _imagePicker = ImagePicker();
  final _captionController = TextEditingController();
  final _locationController = TextEditingController();
  final _tagsController = TextEditingController();
  List<File> _selectedMedia = [];
  String _selectedPostType = AppConstants.postTypeImage;
  
  // Track previous upload state
  bool _wasUploading = false;

  @override
  void dispose() {
    _captionController.dispose();
    _locationController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _pickMedia(ImageSource source, bool isVideo) async {
    try {
      if (isVideo) {
        final video = await _imagePicker.pickVideo(source: source);
        if (video != null) {
          final file = File(video.path);
          if (FileHelper.validateVideoSize(file)) {
            setState(() {
              _selectedMedia.add(file);
              _selectedPostType = AppConstants.postTypeVideo;
            });
          } else {
            _showError('Video size exceeds limit (100MB)');
          }
        }
      } else {
        final images = await _imagePicker.pickMultiImage();
        if (images.isNotEmpty) {
          for (var image in images) {
            if (_selectedMedia.length < AppConstants.maxImagesPerPost) {
              final file = File(image.path);
              if (FileHelper.validateImageSize(file)) {
                setState(() {
                  _selectedMedia.add(file);
                  if (_selectedPostType != AppConstants.postTypeVideo) {
                    _selectedPostType = AppConstants.postTypeImage;
                  }
                });
              }
            }
          }
        }
      }
    } catch (e) {
      _showError('Error picking media: $e');
    }
  }

  void _removeMedia(int index) {
    setState(() {
      _selectedMedia.removeAt(index);
    });
  }

  void _handleCreatePost() {
    if (_selectedMedia.isEmpty) {
      _showError('Please select at least one media file');
      return;
    }

    if (_selectedPostType == 'short' && _selectedMedia.length > 1) {
      _showError('Shorts can only have one video');
      return;
    }

    if (_selectedPostType == AppConstants.postTypeVideo && _selectedMedia.length > 1) {
      _showError('Video posts can only have one video');
      return;
    }

    final tags = _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();

    final caption = _captionController.text.isNotEmpty
        ? _captionController.text
        : 'Untitled Post';

    final location = _locationController.text.isNotEmpty
        ? _locationController.text
        : null;

    print('Creating post with type: $_selectedPostType, media count: ${_selectedMedia.length}');

    context.read<AppBloc>().add(
      CreatePost(
        mediaFiles: _selectedMedia,
        caption: caption,
        location: location,
        tags: tags,
        postType: _selectedPostType,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _pickShort() async {
    try {
      final video = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(seconds: 60),
      );

      if (video != null) {
        final file = File(video.path);
        if (FileHelper.validateVideoSize(file)) {
          setState(() {
            _selectedMedia = [file];
            _selectedPostType = 'short';
          });
        } else {
          _showError('Video size exceeds limit (100MB)');
        }
      }
    } catch (e) {
      _showError('Error picking short: $e');
    }
  }

  // Method to clear form after successful upload
  void _clearForm() {
    setState(() {
      _selectedMedia.clear();
      _captionController.clear();
      _locationController.clear();
      _tagsController.clear();
      _selectedPostType = AppConstants.postTypeImage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        centerTitle: true,
      ),
      body: BlocConsumer<AppBloc, AppState>(
        listener: (context, state) {
          // Detect when upload completes (was uploading, now not uploading)
          if (_wasUploading && !state.isUploading) {
            if (state.uploadError != null) {
              // Show error
              _showError(state.uploadError!);
            } else if (state.uploadProgress == 1.0) {
              // Upload successful
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Post created successfully!'),
                  backgroundColor: AppColors.success,
                  duration: Duration(seconds: 2),
                ),
              );

              // Reload user posts
              final currentUser = state.currentUser;
              if (currentUser != null) {
                context.read<AppBloc>().add(
                  LoadUserPosts(currentUser.id, refresh: true),
                );
              }

              // Reload feed to show the new post
              context.read<AppBloc>().add(LoadFeed(refresh: true));

              // Clear the form
              _clearForm();

              // Navigate back to home using callback
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted) {
                  widget.onPostCreated?.call();
                }
              });
            }
          }

          // Update previous upload state
          _wasUploading = state.isUploading;
        },
        builder: (context, state) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Media Selection
                  if (_selectedMedia.isEmpty)
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.border,
                          style: BorderStyle.solid,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: AppColors.background,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.image_outlined,
                            size: 48,
                            color: AppColors.textHint,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Select Media',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomButton(
                                text: 'Photos',
                                onPressed: state.isUploading
                                    ? null
                                    : () => _pickMedia(ImageSource.gallery, false),
                                width: 100,
                                height: 40,
                              ),
                              const SizedBox(width: 12),
                              CustomButton(
                                text: 'Videos',
                                onPressed: state.isUploading
                                    ? null
                                    : () => _pickMedia(ImageSource.gallery, true),
                                width: 100,
                                height: 40,
                              ),
                              const SizedBox(width: 12),
                              CustomButton(
                                text: 'Shorts',
                                onPressed: state.isUploading
                                    ? null
                                    : () => _pickShort(),
                                width: 100,
                                height: 40,
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selected Media (${_selectedMedia.length})',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 120,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _selectedMedia.length + 1,
                            itemBuilder: (context, index) {
                              if (index == _selectedMedia.length) {
                                if (_selectedMedia.length <
                                        AppConstants.maxImagesPerPost &&
                                    !state.isUploading) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: GestureDetector(
                                      onTap: () => _pickMedia(
                                        ImageSource.gallery,
                                        _selectedPostType ==
                                            AppConstants.postTypeVideo,
                                      ),
                                      child: Container(
                                        width: 100,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: AppColors.border,
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.add),
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              }

                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Stack(
                                  children: [
                                    Container(
                                      width: 100,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: AppColors.shimmerBase,
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          _selectedMedia[index],
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    if (!state.isUploading)
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: GestureDetector(
                                          onTap: () => _removeMedia(index),
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              color: AppColors.error,
                                              shape: BoxShape.circle,
                                            ),
                                            padding: const EdgeInsets.all(4),
                                            child: const Icon(
                                              Icons.close,
                                              size: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 24),
                  // Caption
                  CustomTextField(
                    controller: _captionController,
                    label: 'Caption',
                    hint: 'Write a caption...',
                    maxLines: 4,
                    maxLength: AppConstants.maxCaptionLength,
                    enabled: !state.isUploading,
                  ),
                  const SizedBox(height: 16),
                  // Location
                  CustomTextField(
                    controller: _locationController,
                    label: 'Location',
                    hint: 'Where was this taken?',
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    enabled: !state.isUploading,
                  ),
                  const SizedBox(height: 16),
                  // Tags
                  CustomTextField(
                    controller: _tagsController,
                    label: 'Tags',
                    hint: 'Add tags (comma separated)',
                    prefixIcon: const Icon(Icons.local_offer_outlined),
                    enabled: !state.isUploading,
                  ),
                  const SizedBox(height: 24),
                  // Upload Progress & Button
                  Column(
                    children: [
                      if (state.isUploading)
                        Column(
                          children: [
                            LinearProgressIndicator(
                              value: state.uploadProgress,
                              minHeight: 4,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${(state.uploadProgress * 100).toStringAsFixed(0)}%',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      CustomButton(
                        text: state.isUploading ? 'Uploading...' : 'Share Post',
                        onPressed: state.isUploading ? null : _handleCreatePost,
                        isLoading: state.isUploading,
                        width: double.infinity,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}