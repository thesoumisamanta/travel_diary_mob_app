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
  const CreatePostScreen({Key? key}) : super(key: key);

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

  @override
  void dispose() {
    _captionController.dispose();
    _locationController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _pickMedia(ImageSource source, bool isVideo) async {
    try {
      final permission = isVideo
          ? await FileHelper.requestCameraPermission()
          : await FileHelper.requestStoragePermission();

      if (!permission) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permission denied')),
        );
        return;
      }

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

    final tags = _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();

    context.read<AppBloc>().add(
          CreatePost(
            mediaFiles: _selectedMedia,
            caption: _captionController.text.isNotEmpty
                ? _captionController.text
                : null,
            location: _locationController.text.isNotEmpty
                ? _locationController.text
                : null,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        centerTitle: true,
      ),
      body: BlocListener<AppBloc, AppState>(
        listener: (context, state) {
          if (state.uploadError != null) {
            _showError(state.uploadError!);
          } else if (!state.isUploading && state.uploadProgress == 1.0) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Post created successfully!'),
                backgroundColor: AppColors.success,
              ),
            );
            _captionController.clear();
            _locationController.clear();
            _tagsController.clear();
            setState(() {
              _selectedMedia.clear();
            });
          }
        },
        child: SingleChildScrollView(
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
                              onPressed: () => _pickMedia(ImageSource.gallery, false),
                              width: 120,
                              height: 40,
                            ),
                            const SizedBox(width: 12),
                            CustomButton(
                              text: 'Videos',
                              onPressed: () => _pickMedia(ImageSource.gallery, true),
                              width: 120,
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
                                  AppConstants.maxImagesPerPost) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: GestureDetector(
                                    onTap: () => _pickMedia(
                                        ImageSource.gallery,
                                        _selectedPostType ==
                                            AppConstants.postTypeVideo),
                                    child: Container(
                                      width: 100,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: AppColors.border,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(8),
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
                                      borderRadius:
                                          BorderRadius.circular(8),
                                      color: AppColors.shimmerBase,
                                    ),
                                    child: ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(8),
                                      child: Image.file(
                                        _selectedMedia[index],
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () {
                                        _removeMedia(index);
                                      },
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
                ),
                const SizedBox(height: 16),
                // Location
                CustomTextField(
                  controller: _locationController,
                  label: 'Location',
                  hint: 'Where was this taken?',
                  prefixIcon: const Icon(Icons.location_on_outlined),
                ),
                const SizedBox(height: 16),
                // Tags
                CustomTextField(
                  controller: _tagsController,
                  label: 'Tags',
                  hint: 'Add tags (comma separated)',
                  prefixIcon: const Icon(Icons.local_offer_outlined),
                ),
                const SizedBox(height: 24),
                BlocBuilder<AppBloc, AppState>(
                  builder: (context, state) {
                    return Column(
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
                          onPressed: _handleCreatePost,
                          isLoading: state.isUploading,
                          width: double.infinity,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}