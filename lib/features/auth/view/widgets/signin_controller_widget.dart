import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:smart_prep/core/utils.dart';
import 'package:smart_prep/core/widgets/custom_field_widget.dart';
import 'package:smart_prep/features/auth/view/widgets/auth_gradient_button_widget.dart';
import 'package:smart_prep/features/auth/viewmodel/auth_view_model.dart';

class SigninControllerWidget extends ConsumerStatefulWidget {
  const SigninControllerWidget({super.key});

  @override
  ConsumerState<SigninControllerWidget> createState() =>
      _SigninControllerWidgetState();
}

class _SigninControllerWidgetState
    extends ConsumerState<SigninControllerWidget> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  var showPassword = false;

  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return SizedBox(
      child: Form(
        key: formKey,
        child: Column(
          children: [
            const SizedBox(height: 15),
            CustomFieldWidget(
              hintText: translate(context, 'name'),
              controller: nameController,
              prefixIcon: const Icon(LineAwesomeIcons.user),
              validator: (value) {
                if (value!.trim().isEmpty) {
                  return translate(context, 'name_missing');
                }
                return null;
              },
            ),
            const SizedBox(height: 15),
            CustomFieldWidget(
              hintText: translate(context, 'email'),
              controller: emailController,
              prefixIcon: const Icon(LineAwesomeIcons.envelope),
              validator: (value) {
                if (value!.trim().isEmpty) {
                  return translate(context, 'email_missing');
                }
                return null;
              },
            ),
            const SizedBox(height: 15),
            CustomFieldWidget(
              hintText: translate(context, 'password'),
              controller: passwordController,
              isObscureText: !showPassword,
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: showPassword
                    ? const Icon(LineAwesomeIcons.eye)
                    : const Icon(LineAwesomeIcons.eye_slash),
                onPressed: () {
                  setState(() {
                    showPassword = !showPassword;
                  });
                },
              ),
              validator: (value) {
                return validatePassword(context, value);
              },
            ),
            const SizedBox(height: 20),
            AuthGradientButtonWidget(
              buttonText: translate(context, 'signin_body'),
              onTap: () async {
                if (formKey.currentState!.validate()) {
                  await ref
                      .read(authViewModelProvider.notifier)
                      .signinUser(
                        name: nameController.text.trim(),
                        email: emailController.text.trim(),
                        password: passwordController.text.trim(),
                      );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
