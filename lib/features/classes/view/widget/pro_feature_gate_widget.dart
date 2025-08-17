import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:smart_prep/core/constants/text_strings.dart';
import 'package:smart_prep/core/providers/current_user_notifier.dart';

class ProFeatureGateWidget extends ConsumerWidget {
  final Widget child;
  final String featureName;

  const ProFeatureGateWidget({
    super.key,
    required this.child,
    required this.featureName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserNotifierProvider);

    if (currentUser == null || currentUser.userDetails?.isAnonymous == true) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Please register or log in to access $featureName.',
              style: const TextStyle(fontFamily: tFont, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                /* Navigator.pushNamed(
                  context,
                  '/register',
                  arguments: {
                    'isAnonymousConversion':
                        currentUser?.userDetails?.isAnonymous ?? false,
                  },
                ); */
                Get.toNamed(
                  '/signup',
                  arguments: {
                    'isAnonymousConversion':
                        currentUser?.userDetails?.isAnonymous ?? false,
                  },
                );
              },
              child: const Text(
                'Register or Upgrade Account',
                style: TextStyle(fontFamily: tFont),
              ),
            ),
            if (currentUser != null &&
                currentUser.userDetails?.isAnonymous == true)
              TextButton(
                onPressed: () {
                  // Navigator.pushNamed(context, 'signin');
                  Get.toNamed('/signin');
                },
                child: const Text(
                  'Already have an account? Log in',
                  style: TextStyle(fontFamily: tFont),
                ),
              ),
          ],
        ),
      );
    }
    return child;
  }
}
