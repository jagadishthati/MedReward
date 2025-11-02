import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medreward/providers/app_providers.dart';
import 'package:medreward/screens/home_screen.dart';
import 'package:medreward/services/auth_service.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  String? _selectedGender;

  bool _isPhoneSignup = false;
  bool _passwordsMatch = true;
  bool _passwordTouched = false;
  bool _confirmPasswordTouched = false;
  bool _isLoading = false;
  bool _otpSent = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validatePasswords);
    _confirmPasswordController.addListener(_validatePasswords);
  }

  void _validatePasswords() {
    if (_confirmPasswordController.text.isEmpty) {
      setState(() {
        _passwordsMatch = true;
      });
      return;
    }

    setState(() {
      _passwordsMatch =
          _passwordController.text == _confirmPasswordController.text;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Future<void> _sendOtp() async {
    if (_phoneNumberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter phone number')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final AuthService authService = AuthService();
    final otp = await authService.sendOtp(_phoneNumberController.text);

    setState(() {
      _isLoading = false;
    });

    if (otp != null) {
      setState(() {
        _otpSent = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OTP sent successfully! Code: $otp')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send OTP')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneNumberController.dispose();
    _otpController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  String _convertDateFormat(String dateStr) {
    try {
      final parts = dateStr.split('/');
      if (parts.length == 3) {
        final day = parts[0].padLeft(2, '0');
        final month = parts[1].padLeft(2, '0');
        final year = parts[2];
        return '$year-$month-$day';
      }
    } catch (e) {
      print('Date conversion error: $e');
    }
    return dateStr;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Join MedReward!',
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
                textAlign: TextAlign.center,
              )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 100.ms)
                  .slideY(begin: 0.2, end: 0),
              const SizedBox(height: 8.0),
              Text(
                'Create your account to get started',
                style: textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 200.ms)
                  .slideY(begin: 0.2, end: 0),
              const SizedBox(height: 48.0),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                  prefixIcon: const Icon(Icons.person_outline),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 12.0),
                ),
                keyboardType: TextInputType.name,
              )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 300.ms)
                  .slideY(begin: 0.2, end: 0),
              const SizedBox(height: 16.0),
              TextField(
                controller: _dobController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Date of Birth',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                  prefixIcon: const Icon(Icons.calendar_today_outlined),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 12.0),
                ),
                onTap: () => _selectDate(context),
              )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 400.ms)
                  .slideY(begin: 0.2, end: 0),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: InputDecoration(
                  labelText: 'Gender',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                  prefixIcon: const Icon(Icons.transgender_outlined),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 12.0),
                ),
                items: const <String>['Male', 'Female', 'Other']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedGender = newValue;
                  });
                },
              )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 500.ms)
                  .slideY(begin: 0.2, end: 0),
              const SizedBox(height: 16.0),
              if (!_isPhoneSignup) ...[
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0)),
                    prefixIcon: const Icon(Icons.email_outlined),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 12.0),
                  ),
                  keyboardType: TextInputType.emailAddress,
                )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 600.ms)
                    .slideY(begin: 0.2, end: 0),
                const SizedBox(height: 16.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      onChanged: (value) {
                        setState(() {
                          _passwordTouched = true;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0)),
                        prefixIcon: const Icon(Icons.lock_outline),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 12.0),
                      ),
                    ),
                    if (_passwordTouched && _passwordController.text.length < 6)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                        child: Text(
                          'Password must be at least 6 characters',
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 12.0,
                          ),
                        ),
                      ),
                  ],
                )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 700.ms)
                    .slideY(begin: 0.2, end: 0),
                const SizedBox(height: 16.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      onChanged: (value) {
                        setState(() {
                          _confirmPasswordTouched = true;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(
                              color: !_passwordsMatch && _confirmPasswordTouched
                                  ? Colors.red
                                  : Colors.grey,
                            )),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(
                              color: !_passwordsMatch && _confirmPasswordTouched
                                  ? Colors.red
                                  : Colors.grey.shade400,
                            )),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(
                              color: !_passwordsMatch && _confirmPasswordTouched
                                  ? Colors.red
                                  : Theme.of(context).primaryColor,
                              width: 2.0,
                            )),
                        prefixIcon: Icon(
                          Icons.lock_reset_outlined,
                          color: !_passwordsMatch && _confirmPasswordTouched
                              ? Colors.red
                              : null,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 12.0),
                      ),
                    ),
                    if (!_passwordsMatch && _confirmPasswordTouched)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                        child: Text(
                          'Passwords do not match',
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 12.0,
                          ),
                        ),
                      ),
                  ],
                )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 800.ms)
                    .slideY(begin: 0.2, end: 0),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _phoneNumberController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0)),
                          prefixIcon: const Icon(Icons.phone_outlined),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 12.0),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _sendOtp,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(_otpSent ? 'Resend' : 'Send OTP'),
                    ),
                  ],
                )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 600.ms)
                    .slideY(begin: 0.2, end: 0),
                const SizedBox(height: 16.0),
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'OTP',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0)),
                    prefixIcon: const Icon(Icons.sms_outlined),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 12.0),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 700.ms)
                    .slideY(begin: 0.2, end: 0),
              ],
              const SizedBox(height: 32.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  textStyle: textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                onPressed: _isLoading
                    ? null
                    : () async {
                        // Validation
                        if (_nameController.text.isEmpty ||
                            _dobController.text.isEmpty ||
                            _selectedGender == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Please fill all required fields')),
                          );
                          return;
                        }

                        if (!_isPhoneSignup) {
                          if (_emailController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Please enter email')),
                            );
                            return;
                          }

                          if (_passwordController.text.length < 6) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Password must be at least 6 characters')),
                            );
                            return;
                          }

                          if (!_passwordsMatch) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Passwords do not match')),
                            );
                            return;
                          }
                        } else {
                          if (_phoneNumberController.text.isEmpty ||
                              _otpController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Please enter phone and OTP')),
                            );
                            return;
                          }
                        }

                        setState(() {
                          _isLoading = true;
                        });

                        final AuthService authService = AuthService();
                        bool signedUp = false;

                        if (!_isPhoneSignup) {
                          signedUp = await authService.signup(
                            _emailController.text,
                            _passwordController.text,
                            _nameController.text,
                            _dobController.text,
                            _selectedGender,
                          );
                        } else {
                          signedUp = await authService.signupWithPhoneNumber(
                            _phoneNumberController.text,
                            _otpController.text,
                            _nameController.text,
                            _dobController.text,
                            _selectedGender,
                          );
                        }

                        setState(() {
                          _isLoading = false;
                        });

                        if (signedUp) {
                          // Store user data after successful signup
                          final AuthService authService = AuthService();

                          // Get the user data to store
                          Map<String, dynamic>? userData;

                          if (!_isPhoneSignup) {
                            // For email signup, we need to fetch the user
                            userData = await authService.login(
                              _emailController.text,
                              _passwordController.text,
                            );
                          } else {
                            // For phone signup, you might want to fetch by phone
                            // For now, we'll construct basic data
                            userData = {
                              'full_name': _nameController.text,
                              'date_of_birth':
                                  _convertDateFormat(_dobController.text),
                              'gender': _selectedGender,
                              'phone_number': _phoneNumberController.text,
                              'auth_method': 'phone',
                            };
                          }

                          if (userData != null) {
                            // Store user in provider
                            ref.read(userProvider.notifier).setUser(userData);
                          }

                          ref.read(authProvider.notifier).login();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Account created successfully!')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Signup failed')),
                          );
                        }
                      },
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        _isPhoneSignup ? 'Verify OTP and Sign Up' : 'Sign Up'),
              )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 900.ms)
                  .slideY(begin: 0.2, end: 0),
              const SizedBox(height: 16.0),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isPhoneSignup = !_isPhoneSignup;
                    _otpSent = false;
                  });
                },
                child: Text(
                  _isPhoneSignup
                      ? 'Sign Up with Email/Password'
                      : 'Sign Up with Phone Number',
                  style: textTheme.labelLarge
                      ?.copyWith(color: Theme.of(context).primaryColor),
                ),
              )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 1000.ms)
                  .slideY(begin: 0.2, end: 0),
              const SizedBox(height: 8.0),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Already have an account? Login',
                    style: textTheme.labelLarge
                        ?.copyWith(color: Colors.grey[600])),
              )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 1100.ms)
                  .slideY(begin: 0.2, end: 0),
            ],
          ),
        ),
      ),
    );
  }
}
