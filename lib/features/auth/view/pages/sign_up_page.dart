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
                    SocialFooterWidget(
                      text1: translate(context, 'has_account'),
                      text2: translate(context, 'signin_body'),
                      onPressed: () {
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
