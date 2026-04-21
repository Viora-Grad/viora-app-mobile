import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:viora_app/core/widgets/app_snackbar.dart';
import 'package:viora_app/core/enums/gender.dart';
import 'package:viora_app/core/di/service_locator.dart';
import 'package:viora_app/core/routes/app_router.dart';
import 'package:viora_app/features/auth/representation/blocs/register_bloc.dart';
import 'package:viora_app/features/auth/representation/blocs/register_events.dart';
import 'package:viora_app/features/auth/representation/blocs/register_states.dart';
import 'package:viora_app/features/auth/representation/validators/register_validators.dart';
import 'package:viora_app/features/auth/representation/widgets/register_form_fields.dart';
import 'package:viora_app/features/auth/representation/widgets/register_layout_shell.dart';
import 'package:viora_app/features/auth/representation/widgets/register_login_placeholder.dart';
import 'package:viora_app/features/auth/representation/widgets/register_profile_picture_section.dart';
import 'package:viora_app/features/auth/representation/widgets/register_submit_button.dart';

const int _imageQuality75 = 75;
const double _formTopSpacingRatio06 = 0.06;
const double _formTopSpacingMin20 = 20.0;
const double _formTopSpacingMax72 = 72.0;
const double _fontText17 = 17.0;
const double _spacing16 = 16.0;
const double _spacing24 = 24.0;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late final RegisterBloc _registerBloc;
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _ageController = TextEditingController();
  final _imagePicker = ImagePicker();

  Gender _selectedGender = Gender.male;
  XFile? _selectedProfileImage;

  // This method to securly clear passwords from memory
  void _clearPasswordControllers() {
    _passwordController.clear();
  }

  @override
  void initState() {
    super.initState();
    _registerBloc = sl<RegisterBloc>();
  }

  @override
  void dispose() {
    _clearPasswordControllers();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneNumberController.dispose();
    _ageController.dispose();
    _registerBloc.close();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: _imageQuality75,
      );

      if (pickedFile == null) {
        return;
      }

      if (!mounted) {
        return;
      }

      // Check if the file exists and is accessible
      final file = File(pickedFile.path);
      final exists = await file.exists();
      if (!exists) {
        AppSnackBar.show(
          context,
          'Cannot access this image. Please choose one stored on your device.',
          type: AppSnackBarType.error,
        );
        return;
      }

      // Optionally, copy to temp directory for consistent access
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) {
        AppSnackBar.show(
          context,
          'Cannot access this image. Please choose one stored on your device.',
          type: AppSnackBarType.error,
        );
        return;
      }

      final temporaryDirectory = await getTemporaryDirectory();
      final sanitizedName = pickedFile.name.isEmpty
          ? 'profile_image.jpg'
          : pickedFile.name;
      final temporaryFile = File(
        '${temporaryDirectory.path}/register_${DateTime.now().millisecondsSinceEpoch}_$sanitizedName',
      );
      await temporaryFile.writeAsBytes(bytes, flush: true);

      setState(() {
        _selectedProfileImage = XFile(
          temporaryFile.path,
          name: sanitizedName,
          mimeType: pickedFile.mimeType,
        );
      });
    } on MissingPluginException {
      if (!mounted) {
        return;
      }
      AppSnackBar.show(
        context,
        'Image picker not initialized. Please restart the app.',
        type: AppSnackBarType.error,
      );
    } on PlatformException catch (exception) {
      if (!mounted) {
        return;
      }
      if (exception.code == 'no_valid_image_uri') {
        AppSnackBar.show(
          context,
          'Cannot find the selected image. Please pick an image saved locally on this device.',
          type: AppSnackBarType.error,
        );
        return;
      }
      final message = exception.message ?? 'Failed to pick image.';
      AppSnackBar.show(context, message, type: AppSnackBarType.error);
    } catch (_) {
      if (!mounted) {
        return;
      }
      AppSnackBar.show(
        context,
        'Failed to pick image. Please try again.',
        type: AppSnackBarType.error,
      );
    }
  }

  void _onRegisterPressed(BuildContext context) {
    if (context.read<RegisterBloc>().state.isLoading) {
      return;
    }

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      final invalidFields = RegisterValidators.collectInvalidFields(
        username: _usernameController.text,
        email: _emailController.text,
        phoneNumber: _phoneNumberController.text,
        password: _passwordController.text,
        age: _ageController.text,
      );
      if (invalidFields.isNotEmpty) {
        AppSnackBar.show(
          context,
          RegisterValidators.buildValidationSummary(invalidFields),
          type: AppSnackBarType.error,
        );
      }
      return;
    }

    final parsedAge = int.parse(_ageController.text.trim());

    context.read<RegisterBloc>().add(
      RegisterSubmitted(
        userName: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        phoneNumber: _phoneNumberController.text.trim(),
        gender: _selectedGender,
        age: parsedAge,
        profilePicturePath: _selectedProfileImage?.path,
      ),
    );
  }

  void _onRegisterStateChanged(BuildContext context, RegisterState state) {
    if (!mounted) {
      return;
    }

    if (state.status == RegisterStatus.success) {
      final user = state.user;
      AppSnackBar.show(
        context,
        'Registered successfully',
        type: AppSnackBarType.success,
      );
      if (user != null) {
        context.push(
          AppRoutes.registerSuccess,
          extra: {
            'userName': user.userName,
            'email': user.email,
            'gender': user.gender.name,
            'age': user.age,
            'hasProfilePicture': _selectedProfileImage != null,
          },
        );
      }
      context.read<RegisterBloc>().add(const RegisterReset());
      return;
    }

    if (state.status == RegisterStatus.failure && state.hasErrors) {
      final message = state.errorMessages.map((error) => '• $error').join('\n');
      AppSnackBar.show(context, message, type: AppSnackBarType.error);
      context.read<RegisterBloc>().add(const RegisterReset());
    }
  }

  @override
  Widget build(BuildContext context) {
    final formTopSpacing =
        (MediaQuery.sizeOf(context).height * _formTopSpacingRatio06).clamp(
          _formTopSpacingMin20,
          _formTopSpacingMax72,
        );

    return BlocProvider.value(
      value: _registerBloc,
      child: BlocConsumer<RegisterBloc, RegisterState>(
        listener: _onRegisterStateChanged,
        builder: (context, state) {
          final isSubmitting = state.isLoading;

          return Scaffold(
            body: RegisterLayoutShell(
              formKey: _formKey,
              formTopSpacing: formTopSpacing,
              footer: const RegisterLoginPlaceholder(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  RegisterFormFields(
                    usernameController: _usernameController,
                    emailController: _emailController,
                    phoneNumberController: _phoneNumberController,
                    passwordController: _passwordController,
                    ageController: _ageController,
                    selectedGender: _selectedGender,
                    isSubmitting: isSubmitting,
                    inputTextStyle: Theme.of(context).textTheme.bodyLarge
                        ?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: _fontText17,
                        ),
                    usernameValidator: RegisterValidators.validateUsername,
                    emailValidator: RegisterValidators.validateEmail,
                    phoneNumberValidator:
                        RegisterValidators.validatePhoneNumber,
                    passwordValidator: RegisterValidators.validatePassword,
                    ageValidator: RegisterValidators.validateAge,
                    onGenderChanged: (value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                  ),
                  const SizedBox(height: _spacing16),
                  RegisterProfilePictureSection(
                    isSubmitting: isSubmitting,
                    onPickImage: _pickProfileImage,
                    selectedProfileImage: _selectedProfileImage,
                  ),
                  const SizedBox(height: _spacing24),
                  RegisterSubmitButton(
                    isSubmitting: isSubmitting,
                    onPressed: () => _onRegisterPressed(context),
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
