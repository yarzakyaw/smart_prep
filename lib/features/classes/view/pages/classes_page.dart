import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:smart_prep/core/providers/current_user_notifier.dart';
import 'package:smart_prep/core/snackbar_getx_controller.dart';
import 'package:smart_prep/core/utils.dart';
import 'package:smart_prep/features/auth/model/user_info_model.dart';
import 'package:smart_prep/features/auth/viewmodel/auth_view_model.dart';
import 'package:smart_prep/features/classes/models/class_model.dart';
import 'package:smart_prep/features/classes/view/widget/pro_feature_gate_widget.dart';
import 'package:smart_prep/features/home/repositories/home_remote_repository.dart';
import 'package:url_launcher/url_launcher.dart';

class ClassesPage extends ConsumerWidget {
  const ClassesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserNotifierProvider);

    if (currentUser == null || currentUser.userDetails == null) {
      return Scaffold(
        appBar: AppBar(title: Text(translate(context, 'classes_title'))),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return FutureBuilder<bool>(
      future: isOffline(),
      builder: (context, offlineSnapshot) {
        if (offlineSnapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: Text(translate(context, 'classes_title'))),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (offlineSnapshot.data == true) {
          return Scaffold(
            appBar: AppBar(title: Text(translate(context, 'classes_title'))),
            body: Center(
              child: Text(
                translate(context, 'connect_to_view_classes'),
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return FutureBuilder<UserInfoModel?>(
          future: ref.read(
            getUserInfoOnlineProvider(currentUser.userDetails!.uid).future,
          ),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                appBar: AppBar(
                  title: Text(translate(context, 'classes_title')),
                ),
                body: const Center(child: CircularProgressIndicator()),
              );
            }

            final userInfo = userSnapshot.data;
            final isTeacher = userInfo?.accountType == 'teacher';

            return Scaffold(
              appBar: AppBar(
                title: Text(translate(context, 'classes_title')),
                actions: [
                  if (isTeacher)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          final user = ref.read(currentUserNotifierProvider);
                          if (user != null) {
                            final url =
                                'https://teacher.smartprep.com/dashboard';
                            if (await canLaunchUrl(Uri.parse(url))) {
                              await launchUrl(
                                Uri.parse(url),
                                mode: LaunchMode.externalApplication,
                              );
                            } else {
                              SnackbarGetxController.errorSnackBar(
                                title: translate(context, 'error'),
                                message: translate(
                                  context,
                                  'error_redirecting_teacher_dashboard',
                                ),
                              );
                            }
                          } else {
                            Get.toNamed('/signin');
                          }
                        },
                        child: Text(translate(context, 'manage_classes')),
                      ),
                    ),
                ],
              ),
              body: ProFeatureGateWidget(
                featureName: 'classes',
                child: FutureBuilder<List<ClassModel>>(
                  future: ref.read(homeRemoteRepositoryProvider).getClasses(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      debugPrint('Firestore Error: ${snapshot.error}');
                      return Center(
                        child: Text(
                          '${translate(context, 'error')}: ${snapshot.error}',
                        ),
                      );
                    }
                    final classes = snapshot.data ?? [];
                    if (classes.isEmpty) {
                      return Center(
                        child: Text(
                          translate(context, 'no_classes_available'),
                          style: TextStyle(fontSize: 16),
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: classes.length,
                      itemBuilder: (context, index) {
                        final classItem = classes[index];
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            title: Text(
                              classItem.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '${translate(context, 'subject')}: ${classItem.subject}\n${translate(context, 'teacher')}: ${classItem.teacherName}',
                            ),
                            onTap: () {
                              /* Navigator.pushNamed(
                                context,
                                '/class_details',
                                arguments: {'class': classItem},
                              ); */
                              Get.toNamed(
                                '/classes/class_details',
                                arguments: {'class': classItem},
                              );
                            },
                            trailing: ElevatedButton(
                              onPressed: () async {
                                try {
                                  await ref
                                      .read(homeRemoteRepositoryProvider)
                                      .submitClassJoinRequest(
                                        classId: classItem.id,
                                        userName: userInfo?.name ?? '',
                                        userEmail: userInfo?.email ?? '',
                                      );
                                  SnackbarGetxController.successSnackBar(
                                    title: translate(context, 'success'),
                                    message: translate(
                                      context,
                                      'join_request_submitted',
                                    ),
                                  );
                                } catch (e) {
                                  SnackbarGetxController.successSnackBar(
                                    title: translate(context, 'error'),
                                    message: translate(
                                      context,
                                      'failed_to_submit_join',
                                    ),
                                  );
                                }
                              },
                              child: Text(translate(context, 'join_request')),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/* class ClassesPage extends ConsumerWidget {
  const ClassesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserNotifierProvider);
    if (currentUser == null || currentUser.userDetails == null) {
      return Scaffold(
        appBar: AppBar(title: Text(translate(context, 'classes_title'))),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final onlineUserInfo = ref.watch(
      getUserInfoOnlineProvider(currentUser.userDetails!.uid),
    );

    return onlineUserInfo.when(
      data: (user) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Classes', style: TextStyle(fontFamily: tFont)),
            actions: [
              const SizedBox(height: 16),
              if (user.accountType == 'teacher')
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Teacher features coming soon!',
                          style: TextStyle(fontFamily: tFont),
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'Manage Classes',
                    style: TextStyle(fontFamily: tFont),
                  ),
                ),
            ],
          ),
          body: ProFeatureGateWidget(
            featureName: 'classes',
            child: const Center(
              child: Text(
                'Class participation feature coming soon!',
                style: TextStyle(fontFamily: tFont, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
      error: (error, st) {
        return Center(child: Text(error.toString()));
      },
      loading: () => const CustomLoader(),
    );
  }
} */
