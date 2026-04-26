import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viora_app/core/di/service_locator.dart';
import 'package:viora_app/core/widgets/app_snackbar.dart';
import 'package:viora_app/features/auth/representation/blocs/login_bloc.dart';
import 'package:viora_app/features/auth/representation/blocs/login_events.dart';
import 'package:viora_app/features/auth/representation/blocs/login_states.dart';
import 'package:viora_app/features/auth/representation/validators/login_validators.dart';
import 'package:viora_app/features/auth/representation/widgets/login_form_fields.dart';
import 'package:viora_app/features/auth/representation/widgets/login_layout_shell.dart';
import 'package:viora_app/features/auth/representation/widgets/login_register_placeholder.dart';
import 'package:viora_app/features/auth/representation/widgets/login_submit_button.dart';

const double _formTopSpacingRatio06 = 0.06;
const double _formTopSpacingMin20 = 20.0;
const double _formTopSpacingMax72 = 72.0;
const double _fontText17 = 17.0;
const double _spacing24 = 24.0;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final LoginBloc _loginBloc;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _clearPasswordControllers() {
    _passwordController.clear();
  }

  @override
  void initState() {
    super.initState();
    _loginBloc = sl<LoginBloc>();
  }

  @override
  void dispose() {
    _clearPasswordControllers();
    _emailController.dispose();
    _passwordController.dispose();
    _loginBloc.close();
    super.dispose();
  }

  void _onLoginPressed(BuildContext context) {
    if (context.read<LoginBloc>().state.isLoading) {
      return;
    }

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      final invalidFields = LoginValidators.collectInvalidFields(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (invalidFields.isNotEmpty) {
        AppSnackBar.show(
          context,
          LoginValidators.buildValidationSummary(invalidFields),
          type: AppSnackBarType.error,
        );
      }
      return;
    }

    context.read<LoginBloc>().add(
      LoginSubmitted(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      ),
    );
  }

  void _onLoginStateChanged(BuildContext context, LoginState state) {
    if (!mounted) {
      return;
    }

    if (state.status == LoginStatus.success) {
      AppSnackBar.show(
        context,
        'Logged in successfully',
        type: AppSnackBarType.success,
      );
      context.read<LoginBloc>().add(const LoginReset());
      return;
    }

    if (state.status == LoginStatus.failure && state.hasErrors) {
      final message = state.errorMessages.map((error) => '• $error').join('\n');
      AppSnackBar.show(context, message, type: AppSnackBarType.error);
      context.read<LoginBloc>().add(const LoginReset());
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
      value: _loginBloc,
      child: BlocConsumer<LoginBloc, LoginState>(
        listener: _onLoginStateChanged,
        builder: (context, state) {
          final isSubmitting = state.isLoading;

          return Scaffold(
            body: SizedBox.expand(
              child: LoginLayoutShell(
                formKey: _formKey,
                formTopSpacing: formTopSpacing,
                footer: const LoginRegisterPlaceholder(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LoginFormFields(
                      emailController: _emailController,
                      passwordController: _passwordController,
                      isSubmitting: isSubmitting,
                      inputTextStyle: Theme.of(context).textTheme.bodyLarge
                          ?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: _fontText17,
                          ),
                      emailValidator: LoginValidators.validateEmail,
                      passwordValidator: LoginValidators.validatePassword,
                    ),
                    const SizedBox(height: _spacing24),
                    LoginSubmitButton(
                      isSubmitting: isSubmitting,
                      onPressed: () => _onLoginPressed(context),
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
