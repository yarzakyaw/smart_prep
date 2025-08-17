import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:smart_prep/core/providers/current_user_notifier.dart';
import 'package:smart_prep/core/snackbar_getx_controller.dart';
import 'package:smart_prep/core/utils.dart';
import 'package:smart_prep/features/auth/model/user_info_model.dart';
import 'package:smart_prep/features/auth/viewmodel/auth_view_model.dart';
import 'package:smart_prep/features/classes/view/widget/pro_feature_gate_widget.dart';
import 'package:smart_prep/features/market/repositories/market_remote_repository.dart';
import 'package:url_launcher/url_launcher.dart';

class MarketPage extends ConsumerStatefulWidget {
  const MarketPage({super.key});

  @override
  ConsumerState createState() => _MarketPageState();
}

class _MarketPageState extends ConsumerState {
  String? _subjectFilter;
  String? _difficultyFilter;
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserNotifierProvider);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text(translate(context, 'marketplace_title'))),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return FutureBuilder<bool>(
      future: isOffline(),
      builder: (context, offlineSnapshot) {
        if (offlineSnapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text(translate(context, 'marketplace_title')),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (offlineSnapshot.data == true) {
          return Scaffold(
            appBar: AppBar(
              title: Text(translate(context, 'marketplace_title')),
            ),
            body: Center(
              child: Text(
                translate(context, 'connect_to_view_marketplace'),
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return FutureBuilder<UserInfoModel?>(
          future: ref.read(
            getUserInfoOnlineProvider(user.userDetails!.uid).future,
          ),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                appBar: AppBar(
                  title: Text(translate(context, 'marketplace_title')),
                ),
                body: const Center(child: CircularProgressIndicator()),
              );
            }

            final userInfo = userSnapshot.data;
            final isTeacher = userInfo?.accountType == 'teacher';

            final questionSetsStream = ref
                .watch(marketRemoteRepositoryProvider)
                .getQuestionSetsFromMarket(
                  subject: _subjectFilter,
                  difficulty: _difficultyFilter,
                  status: 'approved',
                );

            return Scaffold(
              appBar: AppBar(
                title: Text(translate(context, 'marketplace_title')),
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
                featureName: 'marketplace',
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: const InputDecoration(
                                labelText: 'Search',
                              ),
                              onChanged: (value) => setState(() {}),
                            ),
                          ),
                          const SizedBox(width: 8),
                          DropdownButton(
                            hint: const Text('Subject'),
                            value: _subjectFilter,
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text('All'),
                              ),
                              const DropdownMenuItem(
                                value: 'Mathematics',
                                child: Text('Mathematics'),
                              ),
                              const DropdownMenuItem(
                                value: 'Physics',
                                child: Text('Physics'),
                              ),
                              // Add more subjects
                            ],
                            onChanged: (value) =>
                                setState(() => _subjectFilter = value),
                          ),
                          const SizedBox(width: 8),
                          DropdownButton(
                            hint: const Text('Difficulty'),
                            value: _difficultyFilter,
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text('All'),
                              ),
                              const DropdownMenuItem(
                                value: 'easy',
                                child: Text('Easy'),
                              ),
                              const DropdownMenuItem(
                                value: 'medium',
                                child: Text('Medium'),
                              ),
                              const DropdownMenuItem(
                                value: 'hard',
                                child: Text('Hard'),
                              ),
                            ],
                            onChanged: (value) =>
                                setState(() => _difficultyFilter = value),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: StreamBuilder(
                        stream: questionSetsStream,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (snapshot.hasError) {
                            debugPrint('Firestore Error: ${snapshot.error}');
                            return Center(
                              child: Text('Error: ${snapshot.error}'),
                            );
                          }
                          final sets = snapshot.data ?? [];
                          final filteredSets = _searchController.text.isEmpty
                              ? sets
                              : sets
                                    .where(
                                      (set) =>
                                          set.title.toLowerCase().contains(
                                            _searchController.text
                                                .toLowerCase(),
                                          ) ||
                                          set.tags.any(
                                            (tag) => tag.toLowerCase().contains(
                                              _searchController.text
                                                  .toLowerCase(),
                                            ),
                                          ),
                                    )
                                    .toList();

                          if (filteredSets.isEmpty) {
                            return const Center(
                              child: Text(
                                'No question sets found.',
                                style: TextStyle(fontSize: 16),
                              ),
                            );
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.all(16.0),
                            itemCount: filteredSets.length,
                            itemBuilder: (context, index) {
                              final set = filteredSets[index];
                              return Card(
                                elevation: 4,
                                child: ListTile(
                                  title: Text(
                                    set.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Subject: ${set.subject}\nDifficulty: ${set.difficulty}\nPrice: \$${set.points}\nCreator: ${set.creatorName}',
                                  ),
                                  trailing: ElevatedButton(
                                    onPressed: () async {
                                      try {
                                        await ref
                                            .read(
                                              marketRemoteRepositoryProvider,
                                            )
                                            .purchaseQuestionSetFromMarket(
                                              set.id,
                                              set.points,
                                              userInfo!.userId,
                                            );
                                        Get.snackbar(
                                          'Success',
                                          'Question set purchased!',
                                          snackPosition: SnackPosition.BOTTOM,
                                          titleText: const Text('Success'),
                                          messageText: const Text(''),
                                        );
                                      } catch (e) {
                                        Get.snackbar(
                                          'Error',
                                          'Purchase failed: $e',
                                          snackPosition: SnackPosition.BOTTOM,
                                          titleText: const Text('Error'),
                                          messageText: const Text(''),
                                        );
                                      }
                                    },
                                    child: const Text('Buy'),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
