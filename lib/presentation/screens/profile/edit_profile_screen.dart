import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../business_logic/app_bloc/app_bloc.dart';
import '../../../business_logic/app_bloc/app_event.dart';
import '../../../business_logic/app_bloc/app_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/file_helper.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _fullNameController;
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  late TextEditingController _websiteController;
  late TextEditingController _locationController;
  final _imagePicker = ImagePicker();
  File? _selectedProfilePicture;
  File? _selectedCoverPicture;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _usernameController = TextEditingController();
    _bioController = TextEditingController();
    _websiteController = TextEditingController();
    _locationController = TextEditingController();

    // Initialize with current user data
    final state = context.read<AppBloc>().state;
    if (state.currentUser != null) {
      _fullNameController.text = state.currentUser!.fullName;
      _usernameController.text = state.currentUser!.username;
      _bioController.text = state.currentUser!.bio ?? '';
      _websiteController.text = state.currentUser!.website ?? '';
      _locationController.text = state.currentUser!.location ?? '';
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _websiteController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickProfilePicture() async {
    try {
      final permission =
          await FileHelper.requestStoragePermission();
      if (!permission) return;

      final image =
          await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final file = File(image.path);
        if (FileHelper.validateImageSize(file)) {
          setState(() {
            _selectedProfilePicture = file;
          });
        } else {
          _showError('Image size exceeds limit');
        }
      }
    } catch (e) {
      _showError('Error picking image: $e');
    }
  }

  Future<void> _pickCoverPicture() async {
    try {
      final permission =
          await FileHelper.requestStoragePermission();
      if (!permission) return;

      final image =
          await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final file = File(image.path);
        if (FileHelper.validateImageSize(file)) {
          setState(() {
            _selectedCoverPicture = file;
          });
        } else {
          _showError('Image size exceeds limit');
        }
      }
    } catch (e) {
      _showError('Error picking image: $e');
    }
  }

  void _handleSaveProfile() {
    if (_formKey.currentState!.validate()) {
      final updateData = {
        'full_name': _fullNameController.text.trim(),
        'username': _usernameController.text.trim(),
        'bio': _bioController.text.trim(),
        'website': _websiteController.text.trim(),
        'location': _locationController.text.trim(),
      };

      context.read<AppBloc>().add(UpdateUserProfile(updateData));
    }
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
        title: const Text('Edit Profile'),
        centerTitle: true,
      ),
      body: BlocListener<AppBloc, AppState>(
        listener: (context, state) {
          if (state.userError != null) {
            _showError(state.userError!);
          } else if (!state.isLoadingUser &&
              state.currentUser != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile updated successfully'),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.pop(context);
          }
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Profile Picture
                  GestureDetector(
                    onTap: _pickProfilePicture,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: _selectedProfilePicture !=
                                  null
                              ? FileImage(_selectedProfilePicture!)
                              : context
                                          .read<AppBloc>()
                                          .state
                                          .currentUser
                                          ?.profilePicture !=
                                      null
                                  ? CachedNetworkImageProvider(
                                      context
                                          .read<AppBloc>()
                                          .state
                                          .currentUser!
                                          .profilePicture!)
                                  : null,
                          child: context
                                      .read<AppBloc>()
                                      .state
                                      .currentUser
                                      ?.profilePicture ==
                                  null
                              ? const Icon(
                                  Icons.person,
                                  size: 50,
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(8),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Cover Picture
                  GestureDetector(
                    onTap: _pickCoverPicture,
                    child: Stack(
                      children: [
                        Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(12),
                            color: AppColors.shimmerBase,
                          ),
                          child: _selectedCoverPicture !=
                                  null
                              ? Image.file(
                                  _selectedCoverPicture!,
                                  fit: BoxFit.cover,
                                )
                              : context
                                          .read<AppBloc>()
                                          .state
                                          .currentUser
                                          ?.coverPicture !=
                                      null
                                  ? CachedNetworkImage(
                                      imageUrl: context
                                          .read<AppBloc>()
                                          .state
                                          .currentUser!
                                          .coverPicture!,
                                      fit: BoxFit.cover,
                                    )
                                  : const Icon(
                                      Icons.image,
                                      size: 48,
                                    ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            padding:
                                const EdgeInsets.all(8),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Form Fields
                  CustomTextField(
                    controller: _fullNameController,
                    label: 'Full Name',
                    hint: 'Enter your full name',
                    prefixIcon: const Icon(Icons.person),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _usernameController,
                    label: 'Username',
                    hint: 'Choose a username',
                    enabled: false,
                    prefixIcon:
                        const Icon(Icons.account_circle_outlined),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _bioController,
                    label: 'Bio',
                    hint: 'Tell us about yourself',
                    maxLines: 3,
                    maxLength: 500,
                    prefixIcon: const Icon(Icons.description),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _websiteController,
                    label: 'Website',
                    hint: 'Your website URL',
                    prefixIcon: const Icon(Icons.link),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _locationController,
                    label: 'Location',
                    hint: 'Your location',
                    prefixIcon: const Icon(Icons.location_on),
                  ),
                  const SizedBox(height: 24),
                  BlocBuilder<AppBloc, AppState>(
                    builder: (context, state) {
                      return CustomButton(
                        text: 'Save Changes',
                        onPressed: _handleSaveProfile,
                        isLoading: state.isLoadingUser,
                        width: double.infinity,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}