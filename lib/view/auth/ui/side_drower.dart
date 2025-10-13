import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:folderlockerapp/view/themes/utill/app_colors.dart';
import 'package:folderlockerapp/view/themes/utill/app_dimention.dart';
import 'package:folderlockerapp/view/themes/utill/app_texts.dart';
import 'package:folderlockerapp/view/themes/utill/theme_setting_page.dart';
import 'package:get/get.dart';

class DrawerScreen extends StatelessWidget {
  const DrawerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 1.5,
      height: MediaQuery.sizeOf(context).height,
      decoration: BoxDecoration(
          color: AppColors.isDarkMode ? AppColors.black10 : AppColors.white, borderRadius: BorderRadius.circular(7)),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "Nothing",
              style: AppTextStyles.kBody20RegularTextStyle,
            ),
            height12,
            TextButton(
                onPressed: () {
                  Get.to(ThemeSettingsScreen());
                },
                child: Text(
                  "settings",
                  style: AppTextStyles.kHeading2RegularTextStyle,
                )),
          ],
        ),
      ),
    );
  }

  Widget buildDrawerItem({required String iconPath, required String text, required VoidCallback onTap}) {
    return ListTile(
      visualDensity: VisualDensity(horizontal: VisualDensity.minimumDensity, vertical: VisualDensity.compact.vertical),
      leading: SvgPicture.asset(iconPath),
      title: Text(text, style: AppTextStyles.kBody15RegularTextStyle),
      onTap: onTap,
    );
  }
}
