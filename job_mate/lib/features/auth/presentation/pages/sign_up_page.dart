import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:job_mate/features/auth/presentation/bloc/auth_bloc.dart';

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
        const SnackBar(content: Text("Please enter your email first")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            context.go('/cv-analysis');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
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
                      const Text(
                        "JOBMATE",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Your AI Career Buddy",
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  const Text(
                    "Welcome to JobMate",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Create your account to start your career journey",
                    style: TextStyle(color: Colors.black54),
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
                            const Text(
                              "Sign Up",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),

                            TextFormField(
                              controller: _firstNameController,
                              decoration: const InputDecoration(
                                labelText: "First Name",
                                hintText: "Enter your first name",
                                border: OutlineInputBorder(),
                              ),
                              validator:
                                  (val) =>
                                      val == null || val.isEmpty
                                          ? "Required"
                                          : null,
                            ),
                            const SizedBox(height: 16),

                            TextFormField(
                              controller: _lastNameController,
                              decoration: const InputDecoration(
                                labelText: "Last Name",
                                hintText: "Enter your last name",
                                border: OutlineInputBorder(),
                              ),
                              validator:
                                  (val) =>
                                      val == null || val.isEmpty
                                          ? "Required"
                                          : null,
                            ),
                            const SizedBox(height: 16),

                            TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: "Email Address",
                                hintText: "Enter your email",
                                border: OutlineInputBorder(),
                              ),
                              validator:
                                  (val) =>
                                      val == null || val.isEmpty
                                          ? "Required"
                                          : null,
                            ),
                            const SizedBox(height: 16),

                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: "Password",
                                hintText: "Create a password",
                                border: OutlineInputBorder(),
                              ),
                              validator:
                                  (val) =>
                                      val == null || val.isEmpty
                                          ? "Required"
                                          : null,
                            ),
                            const SizedBox(height: 16),

                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: "Confirm Password",
                                hintText: "Confirm your password",
                                border: OutlineInputBorder(),
                              ),
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return "Required";
                                }
                                if (val != _passwordController.text) {
                                  return "Passwords do not match";
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
                                    decoration: const InputDecoration(
                                      labelText: "One Time Password",
                                      hintText: "#OTP Code",
                                      border: OutlineInputBorder(),
                                    ),
                                    validator:
                                        (val) =>
                                            val == null || val.isEmpty
                                                ? "Required"
                                                : null,
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
                                  child: const Text(
                                    "Send Code",
                                    style: TextStyle(color: Colors.white),
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
                                child:
                                    isLoading
                                        ? const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                        : const Text(
                                          "Sign up",
                                          style: TextStyle(color: Colors.white),
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
                      const Text("Already have an account? "),
                      GestureDetector(
                        onTap: () => context.go('/login'),
                        child: const Text(
                          "Sign in",
                          style: TextStyle(
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
