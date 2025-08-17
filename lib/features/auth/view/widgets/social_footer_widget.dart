import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_prep/features/auth/view/widgets/clickable_richtext_widget.dart';
// import 'package:smart_prep/core/snackbar_getx_controller.dart';
// import 'package:smart_prep/features/auth/viewmodel/auth_veiw_model.dart';

class SocialFooterWidget extends ConsumerWidget {
  final String text1, text2;
  final VoidCallback onPressed;

  const SocialFooterWidget({
    super.key,
    required this.text1,
    required this.text2,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    /* final authViewModel = ref.watch(authViewModelProvider.notifier);
    final isLoading = ref.watch(
      authViewModelProvider.select((val) => val?.isLoading == true),
    );
    ref.listen(authViewModelProvider, (_, next) {
      next?.when(
        data: (data) {
          SnackbarGetxController.successSnackBar(
            title: translate(context, 'success'),
            message: translate(context, 'signed_in'),
          );
          Navigator.pushNamedAndRemoveUntil(context, 'dashboard', (_) => false);
        },
        error: (error, st) {
          SnackbarGetxController.errorSnackBar(
            title: translate(context, 'failure'),
            message: error.toString(),
          );
        },
        loading: () {},
      );
    }); */
    return Column(
      children: [
        /* const SizedBox(height: 10),
        SocialButtonWidget(
          image: iGoogleLogo,
          foreground: AppPallete.googleForegroundColor,
          background: AppPallete.googleBgColor,
          text: 'Connect with Google',
          isLoading: isLoading,
          onPressed: () {
            authViewModel.signInWithGoogle();
          },
        ),
        const SizedBox(height: 10),
        SocialButtonWidget(
          image: iFacebookLogo,
          foreground: AppPallete.whiteColor,
          background: AppPallete.facebookForegroundColor,
          text: 'Connect with Facebook',
          isLoading: false,
          onPressed: () {},
        ),
        const SizedBox(height: 15), */
        ClickableRichtextWidget(
          text1: text1,
          text2: text2,
          onPressed: onPressed,
        ),
      ],
    );
  }
}
