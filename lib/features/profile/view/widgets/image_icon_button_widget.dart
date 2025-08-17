import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:smart_prep/core/theme/app_pallete.dart';

class ImageIconButtonWidget extends StatefulWidget {
  final Function(String imagePath) onImageSelected;

  const ImageIconButtonWidget({super.key, required this.onImageSelected});

  @override
  State<ImageIconButtonWidget> createState() => _ImageIconButtonWidgetState();
}

class _ImageIconButtonWidgetState extends State<ImageIconButtonWidget> {
  String pickedFilePath = '';

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      widget.onImageSelected(pickedFile.path);
      pickedFilePath = pickedFile.path;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          width: 120,
          height: 120,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: pickedFilePath != ''
                ? Image.file(File(pickedFilePath), fit: BoxFit.fill)
                : Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppPallete.greyColor, width: 2),
                    ),
                    child: CircleAvatar(
                      maxRadius: 60,
                      backgroundColor: AppPallete.transparentColor,
                      child: ClipOval(
                        child: Icon(
                          LineAwesomeIcons.user,
                          size: 100,
                          color: AppPallete.greyColor,
                        ),
                      ),
                    ),
                  ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: AppPallete.amberColor,
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Icon(
                LineAwesomeIcons.image_solid,
                color: AppPallete.whiteColor,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/* class ImageIconButtonWidget extends ConsumerStatefulWidget {
  final VoidCallback? onChanged;
  const ImageIconButtonWidget({super.key, this.onChanged});

  @override
  ConsumerState<ImageIconButtonWidget> createState() =>
      _ImageIconButtonWidgetState();
}

class _ImageIconButtonWidgetState extends ConsumerState<ImageIconButtonWidget> {
  Future<void> _pickImagesFromGallery() async {
    final savedUserInfo = ref
        .watch(authViewModelProvider.notifier)
        .getUserInfo();
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      widget.onChanged!();
      ref
          .watch(authViewModelProvider.notifier)
          .setUserInfo(
            savedUserInfo!.copyWith(profileImageUrl: pickedFile.path),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final savedUserInfo = ref
        .watch(authViewModelProvider.notifier)
        .getUserInfo();
    return Stack(
      children: [
        SizedBox(
          width: 120,
          height: 120,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: savedUserInfo!.profileImageUrl != ''
                ? Image.file(
                    File(savedUserInfo.profileImageUrl),
                    fit: BoxFit.fill,
                  )
                : Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppPallete.greyColor, width: 2),
                    ),
                    child: CircleAvatar(
                      maxRadius: 60,
                      backgroundColor: AppPallete.transparentColor,
                      child: ClipOval(
                        child: Icon(
                          LineAwesomeIcons.user,
                          size: 100,
                          color: AppPallete.greyColor,
                        ),
                      ),
                    ),
                  ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: AppPallete.amberColor,
            ),
            child: IconButton(
              onPressed: () {
                _pickImagesFromGallery();
                setState(() {});
              },
              icon: const Icon(
                LineAwesomeIcons.image_solid,
                color: AppPallete.whiteColor,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
} */
