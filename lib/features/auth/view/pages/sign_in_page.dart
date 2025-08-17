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
                    SocialFooterWidget(
                      text1: translate(context, 'no_account'),
                      text2: translate(context, 'signup_body'),
                      onPressed: () {
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
