import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:viora_app/core/enums/gender.dart';
import 'package:viora_app/core/di/service_locator.dart';
import 'package:viora_app/core/routes/app_router.dart';
import 'package:viora_app/features/Auth/representation/blocs/register_bloc.dart';
import 'package:viora_app/features/Auth/representation/blocs/register_events.dart';
import 'package:viora_app/features/Auth/representation/blocs/register_states.dart';
import 'package:viora_app/features/Auth/representation/widgets/register_form_fields.dart';
import 'package:viora_app/features/Auth/representation/widgets/register_layout_shell.dart';
import 'package:viora_app/features/Auth/representation/widgets/register_profile_picture_section.dart';
import 'package:viora_app/features/Auth/representation/widgets/register_submit_button.dart';

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
  bool _obscurePassword = true;
  XFile? _selectedProfileImage;

  @override
  void initState() {
    super.initState();
    _registerBloc = sl<RegisterBloc>();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneNumberController.dispose();
    _ageController.dispose();
    _registerBloc.close();
    super.dispose();
  }

  String? _requiredValidator(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  Future<void> _pickProfileImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 75,
      );

      if (pickedFile == null) {
        return;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _selectedProfileImage = pickedFile;
      });
    } on MissingPluginException {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Image picker not initialized. Please restart the app.',
          ),
        ),
      );
    } on PlatformException catch (exception) {
      if (!mounted) {
        return;
      }
      final message = exception.message ?? 'Failed to pick image.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to pick image. Please try again.'),
        ),
      );
    }
  }

  void _onRegisterPressed(BuildContext context) {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    final parsedAge = int.tryParse(_ageController.text.trim());
    if (parsedAge == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a valid age')));
      return;
    }

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Registered successfully')));
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

    if (state.status == RegisterStatus.failure && state.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
      context.read<RegisterBloc>().add(const RegisterReset());
    }
  }

  @override
  Widget build(BuildContext context) {
    final formTopSpacing = (MediaQuery.sizeOf(context).height * 0.11).clamp(
      48.0,
      120.0,
    );
    final inputTextStyle = Theme.of(
      context,
    ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, fontSize: 17);

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
                    obscurePassword: _obscurePassword,
                    isSubmitting: isSubmitting,
                    inputTextStyle: inputTextStyle,
                    requiredValidator: _requiredValidator,
                    onTogglePasswordVisibility: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    onGenderChanged: (value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  RegisterProfilePictureSection(
                    isSubmitting: isSubmitting,
                    onPickImage: _pickProfileImage,
                    selectedProfileImage: _selectedProfileImage,
                  ),
                  const SizedBox(height: 24),
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
