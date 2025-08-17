import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:smart_prep/core/constants/text_strings.dart';
import 'package:smart_prep/core/providers/current_user_notifier.dart';
import 'package:smart_prep/core/providers/progress_provider.dart';
import 'package:smart_prep/core/snackbar_getx_controller.dart';
import 'package:smart_prep/core/theme/app_pallete.dart';
import 'package:smart_prep/core/utils.dart';
import 'package:smart_prep/core/widgets/custom_button_widget.dart';
import 'package:smart_prep/core/widgets/custom_loader.dart';
import 'package:smart_prep/features/auth/model/user_info_model.dart';
import 'package:smart_prep/features/auth/viewmodel/auth_view_model.dart';
import 'package:smart_prep/features/home/repositories/home_remote_repository.dart';
import 'package:smart_prep/features/profile/view/widgets/image_icon_button_widget.dart';
import 'package:timeago/timeago.dart' as timeago;

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool _isEditing = false;
  late UserInfoModel? _editingData;

  @override
  void initState() {
    super.initState();
    final localUserInfo = ref
        .read(authViewModelProvider.notifier)
        .getUserInfo();
    if (localUserInfo != null) {
      _editingData = localUserInfo;
    }
  }

  Future<void> refreshProfile() async {
    if (await isOffline()) {
      SnackbarGetxController.successSnackBar(
        title: translate(context, 'success'),
        message: translate(context, 'showing_cached_profile'),
      );
    }
    try {
      await ref.read(authViewModelProvider.notifier).refreshUserInfo();
      SnackbarGetxController.successSnackBar(
        title: translate(context, 'success'),
        message: translate(context, 'profile_refreshed'),
      );
    } catch (e) {
      SnackbarGetxController.errorSnackBar(
        title: translate(context, 'error'),
        message: translate(context, 'failed_to_refresh_profile'),
      );
    }
  }

  void _updateLocalTempData({
    String? name,
    String? phoneNumber,
    String? language,
    String? profileImageUrl,
  }) {
    setState(() {
      _editingData = _editingData!.copyWith(
        name: name ?? _editingData!.name,
        phoneNumber: phoneNumber ?? _editingData!.phoneNumber,
        languagePreference: language ?? _editingData!.languagePreference,
        profileImageUrl: profileImageUrl ?? _editingData!.profileImageUrl,
      );
    });
  }

  void _saveProfileChanges() {
    // Save to Hive
    ref.read(authViewModelProvider.notifier).setUserInfo(_editingData!);

    SnackbarGetxController.successSnackBar(
      title: translate(context, 'success'),
      message: translate(context, 'profile_updated'),
    );

    setState(() => _isEditing = false);
  }

  Future<void> _saveAndSynceProfileChanges() async {
    // Save to Hive
    ref.read(authViewModelProvider.notifier).setUserInfo(_editingData!);

    // Sync to Firestore if online
    await ref
        .read(homeRemoteRepositoryProvider)
        .synceUserInfoOnline(
          selectedThumbnail: File(_editingData!.profileImageUrl),
          languagePreference: _editingData!.languagePreference,
          name: _editingData!.name,
          phoneNumber: _editingData!.phoneNumber,
        );

    SnackbarGetxController.successSnackBar(
      title: translate(context, 'success'),
      message: translate(context, 'profile_updated'),
    );

    setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserNotifierProvider);
    final localUserInfo = ref
        .watch(authViewModelProvider.notifier)
        .getUserInfo();

    // Protect against null user
    if (localUserInfo == null) {
      return Scaffold(
        appBar: AppBar(title: Text(translate(context, 'profile_title'))),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // If first load
    _editingData ??= localUserInfo;

    if (currentUser == null || currentUser.userDetails == null) {
      return buildOfflineProfilePage(context);
    }

    if (currentUser.userDetails!.isAnonymous) {
      return buildAnonymousProfilePage(context);
    }

    // return buildOnlineProfilePage(context);
    return buildOnlineProfilePage(context);
  }

  Widget buildOnlineProfilePage(BuildContext context) {
    final onlineUser = ref.watch(
      getUserInfoOnlineProvider(_editingData!.userId),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(translate(context, 'profile_title')),
        // backgroundColor: Colors.green,
        actions: [
          IconButton(
            onPressed: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text(translate(context, 'confirm')),
                  content: Text(translate(context, 'confirm_logout')),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(result: false),
                      child: Text(translate(context, 'cancel')),
                    ),
                    TextButton(
                      onPressed: () => Get.back(result: true),
                      child: Text(translate(context, 'logout')),
                    ),
                  ],
                ),
              );

              if (shouldLogout == true) {
                final didLogout = await ref
                    .read(authViewModelProvider.notifier)
                    .signoutUser();

                if (didLogout) {
                  SnackbarGetxController.successSnackBar(
                    title: translate(context, 'success'),
                    message: translate(context, 'signed_out'),
                  );
                  /* Navigator.pushNamedAndRemoveUntil(
                    context,
                    'dashboard',
                    (_) => false,
                  ); */
                } else {
                  SnackbarGetxController.errorSnackBar(
                    title: translate(context, 'failure'),
                    message: translate(context, 'logout_failed'),
                  );
                }
              }
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: onlineUser.when(
        data: (userOnlineInfo) {
          return RefreshIndicator(
            onRefresh: refreshProfile,
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Column(
                  children: [
                    SizedBox(height: 10),

                    /// -- IMAGE
                    _isEditing
                        ? ImageIconButtonWidget(
                            onImageSelected: (path) =>
                                _updateLocalTempData(profileImageUrl: path),
                          )
                        : _buildAvatar(_editingData!.profileImageUrl),
                    const SizedBox(height: 10),
                    // EMAIL
                    if (userOnlineInfo.email.isNotEmpty ||
                        userOnlineInfo.email != '')
                      Text(
                        userOnlineInfo.email,
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),

                    // ACCOUNT TYPE
                    if (userOnlineInfo.accountType == 'teacher')
                      Text(
                        translate(context, 'teacher'),
                        style: const TextStyle(fontSize: 16),
                      ),
                    const SizedBox(height: 10),

                    /// -- EDIT PROFILE BUTTON
                    CustomButtonWidget(
                      isFullWidth: false,
                      width: MediaQuery.of(context).size.width * 0.4,
                      text: translate(context, 'edit_profile'),
                      isEditing: _isEditing,
                      onPressed: () => setState(() {
                        _isEditing = !_isEditing;
                      }),
                    ),
                    const SizedBox(width: 10),

                    Divider(color: AppPallete.greyColor),

                    // NAME
                    _buildEditableField(
                      label: translate(context, 'name'),
                      icon: LineAwesomeIcons.user,
                      initialValue: userOnlineInfo.name,
                      onChanged: (v) => _updateLocalTempData(name: v),
                    ),
                    const SizedBox(height: 10),

                    // PHONE
                    _buildEditableField(
                      label: translate(context, 'phone'),
                      icon: LineAwesomeIcons.phone_alt_solid,
                      initialValue: userOnlineInfo.phoneNumber,
                      onChanged: (v) => _updateLocalTempData(phoneNumber: v),
                    ),

                    const SizedBox(height: 10),
                    _buildActionButtons(context, userOnlineInfo),
                    // LANGUAGE SELECTION
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        translate(context, 'language_settings'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildLanguageSelector(userOnlineInfo.languagePreference),
                    const SizedBox(height: 10),

                    /// -- Form Submit Button
                    if (_isEditing)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppPallete.amberColor,
                          ),
                          onPressed: () => _saveAndSynceProfileChanges(),
                          child: Text(
                            translate(context, 'confirm_sync_changes'),
                            style: Theme.of(context).textTheme.bodyLarge!.apply(
                              color: AppPallete.whiteColor,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 10),

                    /// -- Created Date and Delete Button
                    _buildFooter(userOnlineInfo),
                  ],
                ),
              ),
            ),
          );
        },
        error: (error, st) {
          return Center(child: Text(error.toString()));
        },
        loading: () => const CustomLoader(),
      ),
    );
  }

  Scaffold buildAnonymousProfilePage(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(translate(context, 'profile_title')),
        // backgroundColor: Colors.green,
        actions: [
          IconButton(
            onPressed: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text(translate(context, 'confirm')),
                  content: Text(translate(context, 'confirm_logout')),
                  actions: [
                    TextButton(
                      // onPressed: () => Navigator.pop(context, false),
                      onPressed: () => Get.back(result: false),
                      child: Text(translate(context, 'cancel')),
                    ),
                    TextButton(
                      onPressed: () => Get.back(result: true),
                      child: Text(translate(context, 'logout')),
                    ),
                  ],
                ),
              );

              if (shouldLogout == true) {
                final didLogout = await ref
                    .read(authViewModelProvider.notifier)
                    .signoutUser();

                if (didLogout) {
                  SnackbarGetxController.successSnackBar(
                    title: translate(context, 'success'),
                    message: translate(context, 'signed_out'),
                  );
                  /* Navigator.pushNamedAndRemoveUntil(
                    context,
                    'dashboard',
                    (_) => false,
                  ); */
                } else {
                  SnackbarGetxController.errorSnackBar(
                    title: translate(context, 'failure'),
                    message: translate(context, 'logout_failed'),
                  );
                }
              }
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: refreshProfile,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Column(
              children: [
                SizedBox(height: 10),

                /// -- IMAGE
                _isEditing
                    ? ImageIconButtonWidget(
                        onImageSelected: (path) =>
                            _updateLocalTempData(profileImageUrl: path),
                      )
                    : _buildAvatar(_editingData!.profileImageUrl),
                const SizedBox(height: 10),
                // EMAIL
                if (_editingData!.email.isNotEmpty || _editingData!.email != '')
                  Text(
                    _editingData!.email,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 10),

                /// -- BUTTON
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // EDIT BUTTON
                    CustomButtonWidget(
                      isFullWidth: false,
                      width: MediaQuery.of(context).size.width * 0.4,
                      text: translate(context, 'edit_profile'),
                      isEditing: _isEditing,
                      onPressed: () => setState(() {
                        _isEditing = !_isEditing;
                      }),
                    ),
                    const SizedBox(width: 10),

                    // UPGRADE BUTTON
                    ElevatedButton(
                      onPressed: () {
                        Get.toNamed(
                          '/signup',
                          arguments: {'isAnonymousConversion': true},
                        );
                      },
                      child: Text(
                        translate(context, 'upgrade_account'),
                        style: TextStyle(fontFamily: tFont),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
                Divider(color: AppPallete.greyColor),

                // NAME
                _buildEditableField(
                  label: translate(context, 'name'),
                  icon: LineAwesomeIcons.user,
                  initialValue: _editingData!.name,
                  onChanged: (v) => _updateLocalTempData(name: v),
                ),

                // PHONE
                _buildEditableField(
                  label: translate(context, 'phone'),
                  icon: LineAwesomeIcons.phone_alt_solid,
                  initialValue: _editingData!.phoneNumber,
                  onChanged: (v) => _updateLocalTempData(phoneNumber: v),
                ),
                const SizedBox(height: 10),
                // Language Selection
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    translate(context, 'language_settings'),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                _buildLanguageSelector(_editingData!.languagePreference),
                const SizedBox(height: 10),

                /// -- Form Submit Button
                if (_isEditing)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppPallete.amberColor,
                      ),
                      onPressed: () => _saveProfileChanges(),
                      child: Text(
                        translate(context, 'confirm_changes'),
                        style: Theme.of(context).textTheme.bodyLarge!.apply(
                          color: AppPallete.whiteColor,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 10),

                /// -- Created Date and Delete Button
                _buildFooter(_editingData!),
                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildOfflineProfilePage(BuildContext contex) {
    return Scaffold(
      appBar: AppBar(title: Text(translate(context, 'profile_title'))),
      body: RefreshIndicator(
        onRefresh: refreshProfile,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Column(
              children: [
                SizedBox(height: 10),

                /// -- IMAGE
                _isEditing
                    ? ImageIconButtonWidget(
                        onImageSelected: (path) =>
                            _updateLocalTempData(profileImageUrl: path),
                      )
                    : _buildAvatar(_editingData!.profileImageUrl),
                const SizedBox(height: 10),
                if (_editingData!.email.isNotEmpty || _editingData!.email != '')
                  Text(
                    _editingData!.email,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                if (_editingData!.accountType == 'teacher')
                  Text(
                    translate(context, 'teacher'),
                    style: const TextStyle(fontSize: 16),
                  ),
                const SizedBox(height: 10),

                /// -- EDIT BUTTON
                CustomButtonWidget(
                  isFullWidth: false,
                  width: MediaQuery.of(context).size.width * 0.4,
                  text: translate(context, 'edit_profile'),
                  isEditing: _isEditing,
                  onPressed: () => setState(() {
                    _isEditing = !_isEditing;
                  }),
                ),
                const SizedBox(width: 10),

                Divider(color: AppPallete.greyColor),

                // NAME
                _buildEditableField(
                  label: translate(context, 'name'),
                  icon: LineAwesomeIcons.user,
                  initialValue: _editingData!.name,
                  onChanged: (v) => _updateLocalTempData(name: v),
                ),
                const SizedBox(height: 6),

                // PHONE
                _buildEditableField(
                  label: translate(context, 'phone'),
                  icon: LineAwesomeIcons.phone_alt_solid,
                  initialValue: _editingData!.phoneNumber,
                  onChanged: (v) => _updateLocalTempData(phoneNumber: v),
                ),
                const SizedBox(height: 10),

                // LANGUAGE SELECTION
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    translate(context, 'language_settings'),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                _buildLanguageSelector(_editingData!.languagePreference),
                const SizedBox(height: 10),

                /// -- Form Submit Button
                if (_isEditing)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppPallete.amberColor,
                      ),
                      onPressed: () => _saveProfileChanges(),
                      child: Text(
                        translate(context, 'confirm_changes'),
                        style: Theme.of(context).textTheme.bodyLarge!.apply(
                          color: AppPallete.whiteColor,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 10),

                /// -- Created Date and Delete Button
                _buildFooter(_editingData!),

                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(String imagePath) {
    return imagePath.isNotEmpty
        ? CircleAvatar(
            maxRadius: 60,
            backgroundColor: AppPallete.transparentColor,
            backgroundImage: FileImage(File(imagePath)),
          )
        : CircleAvatar(
            maxRadius: 60,
            backgroundColor: AppPallete.transparentColor,
            child: Icon(
              LineAwesomeIcons.user,
              size: 100,
              color: AppPallete.greyColor,
            ),
          );
  }

  Widget _buildEditableField({
    required String label,
    required IconData icon,
    required String initialValue,
    required ValueChanged<String> onChanged,
  }) {
    return TextFormField(
      enabled: _isEditing,
      initialValue: initialValue,
      decoration: InputDecoration(label: Text(label), prefixIcon: Icon(icon)),
      onChanged: onChanged,
    );
  }

  Widget _buildLanguageSelector(String language) {
    return _isEditing
        ? DropdownButtonFormField<String>(
            value: language,
            decoration: InputDecoration(
              labelText: translate(context, 'select_language'),
              prefixIcon: Icon(LineAwesomeIcons.language_solid),
            ),
            items: const [
              DropdownMenuItem(value: 'en', child: Text('English')),
              DropdownMenuItem(value: 'my', child: Text('မြန်မာ')),
            ],
            onChanged: (value) {
              if (value != null) {
                _updateLocalTempData(language: value);
                Get.updateLocale(Locale(value));
              }
            },
          )
        : TextFormField(
            enabled: false,
            initialValue: language == 'en' ? 'English' : 'မြန်မာ',
            decoration: InputDecoration(
              label: Text(translate(context, 'language')),
              prefixIcon: Icon(LineAwesomeIcons.language_solid),
            ),
          );
  }

  Widget _buildFooter(UserInfoModel userInfo) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text.rich(
          TextSpan(
            text: translate(context, 'created_at'),
            children: [TextSpan(text: timeago.format(userInfo.createdAt))],
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppPallete.greyColor,
          ),
          onPressed: () {},
          child: Text(
            translate(context, 'delete_acc'),
            style: Theme.of(
              context,
            ).textTheme.bodyLarge!.apply(color: AppPallete.whiteColor),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    UserInfoModel userOnlineInfo,
  ) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () async {
            await ref
                .read(progressProvider.notifier)
                .syncLocalProgressToFirestore(userOnlineInfo.userId);
            SnackbarGetxController.successSnackBar(
              title: translate(context, 'success'),
              message: translate(context, 'progress_synced'),
            );
          },
          child: Text(
            translate(context, 'sync_progress'),
            style: TextStyle(fontFamily: tFont),
          ),
        ),
        const SizedBox(height: 10),
        if (userOnlineInfo.accountType != 'teacher')
          ElevatedButton(
            onPressed: () {
              _showTeacherRequestDialog(
                context,
                ref,
                userOnlineInfo.name,
                userOnlineInfo.email,
              );
            },
            child: Text(
              translate(context, 'request_teacher_privileges'),
              style: TextStyle(fontFamily: tFont),
            ),
          ),
      ],
    );
  }

  void _showTeacherRequestDialog(
    BuildContext context,
    WidgetRef ref,
    String name,
    String email,
  ) {
    final formKey = GlobalKey<FormState>();
    final teacherInfoController = TextEditingController();
    String? errorMessage;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            translate(context, 'request_teacher_privileges'),
            style: TextStyle(fontFamily: tFont),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: name,
                  decoration: InputDecoration(
                    labelText: translate(context, 'name'),
                    hintText: translate(context, 'enter_name'),
                    hintStyle: TextStyle(fontFamily: tFont),
                  ),
                  style: const TextStyle(fontFamily: tFont),
                  enabled: false,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: email,
                  decoration: InputDecoration(
                    labelText: translate(context, 'email'),
                    hintText: translate(context, 'enter_email'),
                    hintStyle: TextStyle(fontFamily: tFont),
                  ),
                  style: const TextStyle(fontFamily: tFont),
                  enabled: false,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: teacherInfoController,
                  decoration: InputDecoration(
                    labelText: translate(context, 'qualifications_reason'),
                    hintText: translate(context, 'enter_qualifications_reason'),
                    hintStyle: TextStyle(fontFamily: tFont),
                  ),
                  style: const TextStyle(fontFamily: tFont),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return translate(
                        context,
                        'provide_qualifications_reason',
                      );
                    }
                    return null;
                  },
                ),
                if (errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontFamily: tFont,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                translate(context, 'cancel'),
                style: TextStyle(fontFamily: tFont),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  setState(() {
                    errorMessage = null;
                  });
                  try {
                    final firestoreService = ref.read(
                      homeRemoteRepositoryProvider,
                    );
                    await firestoreService.submitTeacherRequest(
                      name: name,
                      email: email,
                      teacherInfo: teacherInfoController.text.trim(),
                    );
                    Get.back();
                    SnackbarGetxController.successSnackBar(
                      title: translate(context, 'success'),
                      message: 'Teacher privilege request submitted',
                    );
                  } catch (e) {
                    setState(() {
                      errorMessage = e.toString().replaceAll('Exception: ', '');
                    });
                  }
                }
              },
              child: Text(
                translate(context, 'submit'),
                style: TextStyle(fontFamily: tFont),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
