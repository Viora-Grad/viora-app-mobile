import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
import 'package:viora_app/features/auth/representation/widgets/register_submit_button.dart';

const double _formTopSpacingRatio06 = 0.06;
const double _formTopSpacingMin20 = 20.0;
const double _formTopSpacingMax72 = 72.0;
const double _fontText17 = 17.0;
const double _spacing24 = 24.0;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late final RegisterBloc _registerBloc;
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _userNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  Gender _selectedGender = Gender.male;
  DateTime? _selectedDateOfBirth;

  String? _oauthProviderKey;

  bool get _isOAuthRegistration => _oauthProviderKey != null;

  void _clearPasswordControllers() {
    _passwordController.clear();
  }

  @override
  void initState() {
    super.initState();
    _registerBloc = sl<RegisterBloc>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final extra = GoRouterState.of(context).extra;
      if (extra is Map<String, dynamic>) {
        final providerKey = extra['oauth_providerKey'] as String?;
        if (providerKey != null && providerKey.isNotEmpty) {
          setState(() {
            _oauthProviderKey = providerKey;
          });
          _firstNameController.text =
              extra['oauth_firstName'] as String? ?? '';
          _lastNameController.text =
              extra['oauth_lastName'] as String? ?? '';
          _emailController.text =
              extra['oauth_email'] as String? ?? '';
        }
      }
    });
  }

  @override
  void dispose() {
    _clearPasswordControllers();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _userNameController.dispose();
    _phoneNumberController.dispose();
    _registerBloc.close();
    super.dispose();
  }

  void _onRegisterPressed(BuildContext context) {
    if (context.read<RegisterBloc>().state.isLoading) {
      return;
    }

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      final invalidFields = RegisterValidators.collectInvalidFields(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text,
        password: _isOAuthRegistration ? null : _passwordController.text,
        dateOfBirth: _selectedDateOfBirth,
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

    if (_selectedDateOfBirth == null) {
      AppSnackBar.show(
        context,
        'Please select your date of birth',
        type: AppSnackBarType.error,
      );
      return;
    }

    final userName = _userNameController.text.trim();
    final phoneNumber = _phoneNumberController.text.trim();

    if (_isOAuthRegistration) {
      context.read<RegisterBloc>().add(
        OAuthRegisterSubmitted(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: _emailController.text.trim(),
          gender: _selectedGender,
          dateOfBirth: _selectedDateOfBirth!,
          providerKey: _oauthProviderKey!,
          userName: userName.isNotEmpty ? userName : null,
          phoneNumber: phoneNumber.isNotEmpty ? phoneNumber : null,
        ),
      );
    } else {
      context.read<RegisterBloc>().add(
        RegisterSubmitted(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          gender: _selectedGender,
          dateOfBirth: _selectedDateOfBirth!,
          userName: userName.isNotEmpty ? userName : null,
          phoneNumber: phoneNumber.isNotEmpty ? phoneNumber : null,
        ),
      );
    }
  }

  void _onRegisterStateChanged(BuildContext context, RegisterState state) {
    if (!mounted) return;

    if (state.status == RegisterStatus.success) {
      context.read<RegisterBloc>().add(const RegisterReset());
      context.go(AppRoutes.home);
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
            body: SizedBox.expand(
              child: RegisterLayoutShell(
                formKey: _formKey,
                formTopSpacing: formTopSpacing,
                footer: const RegisterLoginPlaceholder(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    RegisterFormFields(
                      firstNameController: _firstNameController,
                      lastNameController: _lastNameController,
                      emailController: _emailController,
                      passwordController: _passwordController,
                      userNameController: _userNameController,
                      phoneNumberController: _phoneNumberController,
                      selectedGender: _selectedGender,
                      selectedDateOfBirth: _selectedDateOfBirth,
                      isSubmitting: isSubmitting,
                      hidePasswordField: _isOAuthRegistration,
                      inputTextStyle: Theme.of(context).textTheme.bodyLarge
                          ?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: _fontText17,
                          ),
                      firstNameValidator: RegisterValidators.validateFirstName,
                      lastNameValidator: RegisterValidators.validateLastName,
                      emailValidator: RegisterValidators.validateEmail,
                      passwordValidator: _isOAuthRegistration
                          ? null
                          : RegisterValidators.validatePassword,
                      userNameValidator: RegisterValidators.validateUserName,
                      phoneNumberValidator: RegisterValidators.validatePhoneNumber,
                      onGenderChanged: (value) {
                        setState(() {
                          _selectedGender = value;
                        });
                      },
                      onDateOfBirthChanged: (value) {
                        setState(() {
                          _selectedDateOfBirth = value;
                        });
                      },
                    ),
                    const SizedBox(height: _spacing24),
                    RegisterSubmitButton(
                      isSubmitting: isSubmitting,
                      onPressed: () => _onRegisterPressed(context),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
