import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:smart_prep/core/snackbar_getx_controller.dart';
import 'package:smart_prep/core/utils.dart';
import 'package:smart_prep/core/widgets/custom_loader.dart';
import 'package:smart_prep/features/auth/model/user_info_model.dart';
import 'package:smart_prep/features/auth/repositories/auth_local_repository.dart';
import 'package:smart_prep/features/auth/view/widgets/form_header_widget.dart';
import 'package:smart_prep/features/auth/view/widgets/signin_controller_widget.dart';
import 'package:smart_prep/features/auth/view/widgets/social_footer_widget.dart';
import 'package:smart_prep/features/auth/viewmodel/auth_view_model.dart';

class SignInPage extends ConsumerWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(
      authViewModelProvider.select((val) => val?.isLoading == true),
    );

    ref.listen(authViewModelProvider, (_, next) {
      next?.when(
        data: (data) {
          debugPrint('----------- in the signin page');
          SnackbarGetxController.successSnackBar(
            title: translate(context, 'success'),
            message: translate(context, 'signed_in'),
          );
          // save user info first time when log in anonymously
          final userInfo = UserInfoModel(
            userId: data.userDetails!.uid,
            accountType: 'user',
            createdAt: DateTime.now(),
            lastLoginAt: DateTime.now(),
            email: data.userDetails?.email! ?? '',
            name: data.username,
            phoneNumber: data.userDetails!.phoneNumber ?? '',
            languagePreference: 'en',
            profileImageUrl: '',
          );
          ref.watch(authLocalRepositoryProvider).saveUserInfo(userInfo);

          // fetch user info online if available
          final onlineUserInfo = ref.watch(
            GetUserInfoOnlineProvider(data.userDetails!.uid),
          );
          onlineUserInfo.whenData((info) {
            ref
                .read(authLocalRepositoryProvider)
                .saveUserInfo(info.copyWith(lastLoginAt: DateTime.now()));
          });
          // Navigator.pushNamedAndRemoveUntil(context, 'dashboard', (_) => false);
          // Get.offNamedUntil('/dashboard', (_) => false);
          Get.offAllNamed('/dashboard');
        },
        error: (error, st) {
          SnackbarGetxController.errorSnackBar(
            title: translate(context, 'failure'),
            message: error.toString(),
          );
        },
        loading: () => CustomLoader(),
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
                      title: translate(context, 'signin_title'),
                      crossAxisAlignment: CrossAxisAlignment.center,
                      textAlign: TextAlign.center,
                    ),
                    const SigninControllerWidget(),
                    const SizedBox(height: 10),
                    // const FormDividerWidget(),
                    SocialFooterWidget(
                      text1: translate(context, 'no_account'),
                      text2: translate(context, 'signup_body'),
                      onPressed: () {
                        // Navigator.pushReplacementNamed(context, 'SignupPage');
                        /* Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignUpPage(),
                          ),
                        ); */
                        Get.offNamed('/signup');
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

/* import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:smart_prep/core/constants/text_strings.dart';
import 'package:smart_prep/core/snackbar_getx_controller.dart';
import 'package:smart_prep/features/auth/view/pages/sign_up_page.dart';

class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key});

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        if (mounted) {
          // Navigator.pop(context);
          Get.offAllNamed('dashboard');
          SnackbarGetxController.successSnackBar(
            title: 'Success',
            message: 'Signed in successfully',
          );
          /* ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Logged in successfully', style: TextStyle(fontFamily: tFont)),
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
        title: const Text('Sign In', style: TextStyle(fontFamily: tFont)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                      onPressed: _login,
                      child: const Text(
                        'Login',
                        style: TextStyle(fontFamily: tFont),
                      ),
                    ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const SignUpPage()),
                  );
                },
                child: const Text(
                  "Don't have an account? Register",
                  style: TextStyle(fontFamily: tFont),
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
