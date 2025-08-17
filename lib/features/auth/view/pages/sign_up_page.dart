import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:smart_prep/core/providers/progress_provider.dart';
import 'package:smart_prep/core/snackbar_getx_controller.dart';
import 'package:smart_prep/core/utils.dart';
import 'package:smart_prep/core/widgets/custom_loader.dart';
import 'package:smart_prep/features/auth/model/user_info_model.dart';
import 'package:smart_prep/features/auth/repositories/auth_local_repository.dart';
import 'package:smart_prep/features/auth/view/widgets/form_header_widget.dart';
import 'package:smart_prep/features/auth/view/widgets/signup_controller_widget.dart';
import 'package:smart_prep/features/auth/view/widgets/social_footer_widget.dart';
import 'package:smart_prep/features/auth/viewmodel/auth_view_model.dart';

class SignUpPage extends ConsumerWidget {
  final bool isAnonymousConversion;
  const SignUpPage({super.key, this.isAnonymousConversion = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(
      authViewModelProvider.select((val) => val?.isLoading == true),
    );

    ref.listen(authViewModelProvider, (_, next) {
      next?.when(
        data: (data) {
          SnackbarGetxController.successSnackBar(
            title: translate(context, 'success'),
            message: isAnonymousConversion
                ? translate(context, 'account_upgraded')
                : translate(context, 'account_created'),
          );
          final userInfo = UserInfoModel(
            userId: data.userDetails!.uid,
            accountType: 'user',
            createdAt: DateTime.now(),
            lastLoginAt: DateTime.now(),
            email: data.userDetails!.email!,
            name: data.username,
            phoneNumber: data.userDetails!.phoneNumber ?? '',
            languagePreference: 'en',
            profileImageUrl: '',
          );
          ref.watch(authLocalRepositoryProvider).saveUserInfo(userInfo);
          ref
              .read(progressProvider.notifier)
              .syncLocalProgressToFirestore(data.userDetails!.uid);
          // Navigator.pushNamedAndRemoveUntil(context, 'dashboard', (_) => false);
          Get.offAllNamed('/dashboard');
        },
        error: (error, st) {
          SnackbarGetxController.errorSnackBar(
            title: translate(context, 'failure'),
            message: error.toString(),
          );
        },
        loading: () {},
      );
    });

    return Scaffold(
      appBar: AppBar(),
      body: isLoading
          ? const CustomLoader()
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    FormHeaderWidget(
                      title: isAnonymousConversion
                          ? translate(context, 'upgrade_title')
                          : translate(context, 'signup_title'),
                      crossAxisAlignment: CrossAxisAlignment.center,
                      textAlign: TextAlign.center,
                    ),
                    SignupControllerWidget(
                      isAnonymousConversion: isAnonymousConversion,
                    ),
                    const SizedBox(height: 10),
                    // const FormDividerWidget(),
                    SocialFooterWidget(
                      text1: translate(context, 'has_account'),
                      text2: translate(context, 'signin_body'),
                      onPressed: () {
                        // Navigator.pushReplacementNamed(context, 'signin');
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => const SigninScreen(),
                        //   ),
                        // );
                        Get.offNamed('/signin');
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

/* import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_prep/core/constants/text_strings.dart';
import 'package:smart_prep/core/providers/auth_provider.dart';
import 'package:smart_prep/core/providers/progress_provider.dart';
import 'package:smart_prep/core/snackbar_getx_controller.dart';

class SignUpPage extends ConsumerStatefulWidget {
  final bool isAnonymousConversion;

  const SignUpPage({super.key, this.isAnonymousConversion = false});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      try {
        final authService = ref.read(authServiceProvider);
        final userId = ref.read(authStateProvider).value?.uid;
        if (widget.isAnonymousConversion && userId != null) {
          await authService.convertAnonymousToEmail(
            _emailController.text.trim(),
            _passwordController.text.trim(),
            name: _nameController.text.trim(),
          );
          await ref
              .read(progressProvider.notifier)
              .syncLocalProgressToFirestore(userId);
        } else {
          await authService.signUpWithEmail(
            _emailController.text.trim(),
            _passwordController.text.trim(),
            name: _nameController.text.trim(),
          );
        }
        if (mounted) {
          Navigator.pop(context);
          SnackbarGetxController.successSnackBar(
            title: 'Success',
            message: widget.isAnonymousConversion
                ? 'Account upgraded successfully'
                : 'Registered successfully',
          );
          /* ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.isAnonymousConversion
                    ? 'Account upgraded successfully'
                    : 'Registered successfully',
                style: const TextStyle(fontFamily: tFont),
              ),
            ),
          ); */
        }
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isAnonymousConversion ? 'Upgrade Account' : 'Register',
          style: const TextStyle(fontFamily: tFont),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name (Optional)',
                  hintText: 'Enter your name',
                  hintStyle: TextStyle(fontFamily: tFont),
                ),
                style: const TextStyle(fontFamily: tFont),
                validator: (value) => null, // Optional field
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  hintStyle: TextStyle(fontFamily: tFont),
                ),
                style: const TextStyle(fontFamily: tFont),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  hintStyle: TextStyle(fontFamily: tFont),
                ),
                style: const TextStyle(fontFamily: tFont),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontFamily: tFont),
                ),
              const SizedBox(height: 16),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _register,
                      child: Text(
                        widget.isAnonymousConversion
                            ? 'Upgrade Account'
                            : 'Register',
                        style: const TextStyle(fontFamily: tFont),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
 */
