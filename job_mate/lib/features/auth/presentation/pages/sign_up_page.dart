import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:job_mate/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _onSignupPressed() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        RegisterEvent(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          _otpController.text.trim(),
        ),
      );
    }
  }

  void _onRequestOtp() {
    if (_emailController.text.isNotEmpty) {
      context.read<AuthBloc>().add(
        RequestOtpEvent(_emailController.text.trim()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.pleaseEnterEmailFirst)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          print('State changed to: $state');
          if (state is AuthSuccess) {
            if (state.type == 'register') {
              context.go('/login'); // Navigate to login after successful registration
            } else if (state.type == 'login') {
              context.go('/cv-analysis'); // Navigate to CV analysis after successful login
            }
          }
          if (state is AuthError) { // Separate check for AuthError
            print('Showing error: ${state.message}'); // Debug log
            final errorMessage = state.message.contains('500')
                ? l10n.registrationFailedServer
                : state.message.contains('400')
                    ? l10n.registrationFailedInvalid
                    : l10n.registrationFailedUnexpected;
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Column(
                    children: [
                      Image.asset('assets/logo.png', height: 100),
                      const SizedBox(height: 8),
                      Text(
                        l10n.appTitle,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.yourAiCareerBuddy,
                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text(
                    l10n.welcomeToJobmate,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.createAccountToStart,
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.register,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _firstNameController,
                              decoration: InputDecoration(
                                labelText: l10n.firstName,
                                hintText: l10n.enterYourFirstName,
                                border: const OutlineInputBorder(),
                              ),
                              validator: (val) => val == null || val.isEmpty ? l10n.required : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _lastNameController,
                              decoration: InputDecoration(
                                labelText: l10n.lastName,
                                hintText: l10n.enterYourLastName,
                                border: const OutlineInputBorder(),
                              ),
                              validator: (val) => val == null || val.isEmpty ? l10n.required : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: l10n.emailAddress,
                                hintText: l10n.enterYourEmail,
                                border: const OutlineInputBorder(),
                              ),
                              validator: (val) => val == null || val.isEmpty ? l10n.required : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: l10n.password,
                                hintText: l10n.createPassword,
                                border: const OutlineInputBorder(),
                              ),
                              validator: (val) {
                                if (val == null || val.isEmpty) return l10n.required;
                                if (val.length < 8) return l10n.passwordMinLength;
                                if (!val.contains(RegExp(r'[A-Z]'))) return l10n.passwordUppercase;
                                if (!val.contains(RegExp(r'[0-9]'))) return l10n.passwordNumber;
                                if (!val.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) return l10n.passwordSpecialChar;
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: l10n.confirmPassword,
                                hintText: l10n.confirmYourPassword,
                                border: const OutlineInputBorder(),
                              ),
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return l10n.required;
                                }
                                if (val != _passwordController.text) {
                                  return l10n.passwordsDoNotMatch;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _otpController,
                                    decoration: InputDecoration(
                                      labelText: l10n.oneTimePassword,
                                      hintText: l10n.otpCode,
                                      border: const OutlineInputBorder(),
                                    ),
                                    validator: (val) => val == null || val.isEmpty ? l10n.required : null,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: isLoading ? null : _onRequestOtp,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 18,
                                    ),
                                  ),
                                  child: Text(
                                    l10n.sendCode,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : _onSignupPressed,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                ),
                                child: isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : Text(
                                        l10n.signUp,
                                        style: const TextStyle(color: Colors.white),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("${l10n.alreadyHaveAccount} "),
                      GestureDetector(
                        onTap: () => context.go('/login'),
                        child: Text(
                          l10n.signIn,
                          style: const TextStyle(
                            color: Colors.teal,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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