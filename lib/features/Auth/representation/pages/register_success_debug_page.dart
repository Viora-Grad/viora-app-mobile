import 'package:flutter/material.dart';

class RegisterSuccessDebugPage extends StatelessWidget {
  final Map<String, dynamic> submittedForm;

  const RegisterSuccessDebugPage({required this.submittedForm, super.key});

  String _readString(String key) {
    return submittedForm[key]?.toString() ?? '-';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Registration completed',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                Text('Username: ${_readString('userName')}'),
                Text('Email: ${_readString('email')}'),
                Text('Gender: ${_readString('gender')}'),
                Text('Age: ${_readString('age')}'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
