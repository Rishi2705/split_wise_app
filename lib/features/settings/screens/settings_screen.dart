import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:split_wise_app/core/constants/app_colors.dart';
import 'package:split_wise_app/core/constants/app_icons.dart';
import 'package:split_wise_app/core/constants/app_spacing.dart';
import 'package:split_wise_app/core/constants/strings.dart';
import 'package:split_wise_app/core/widgets/common_text_form_field.dart';
import 'package:split_wise_app/core/constants/app_route_constants.dart';
import 'package:split_wise_app/core/Theme/theme_provider.dart';
import 'package:split_wise_app/features/settings/provider/settings_provider.dart';
import 'dart:convert';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _oldPasswordController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  final _nameFormKey = GlobalKey<FormState>();
  final _emailFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _emailController = TextEditingController();
    _oldPasswordController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeControllers();
    });
  }

  void _initializeControllers() {
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    final userData = settingsProvider.userData;
    
    if (userData != null) {
      _fullNameController.text = userData['fullName'] ?? '';
      _emailController.text = userData['email'] ?? '';
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _oldPasswordController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }


  Future<void> _showUpdateNameDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(Strings.updateFullNameTitle),
        content: SingleChildScrollView(
          child: Form(
            key: _nameFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: AppSpacing.md(context)),
                CommonTextField(
                  labelText: Strings.fullNameLabel,
                  hintText: Strings.enterYourFullName,
                  controller: _fullNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return Strings.fullNameRequired;
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(Strings.cancel),
          ),
          Consumer<SettingsProvider>(
            builder: (context, settingsProvider, _) {
              return TextButton(
                onPressed: settingsProvider.isLoading
                    ? null
                    : () async {
                        if (_nameFormKey.currentState!.validate()) {
                          final success =
                              await settingsProvider.updateProfile(
                            fullName: _fullNameController.text.trim(),
                            email: null,
                          );
                          if (!mounted) return;
                          if (success) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(Strings.nameUpdatedSuccess),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  settingsProvider.errorMessage ??
                                      Strings.failedToUpdateName,
                                ),
                              ),
                            );
                          }
                        }
                      },
                child: settingsProvider.isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).primaryColor,
                        ),
                      )
                    : const Text(Strings.update),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showUpdateEmailDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(Strings.updateEmailTitle),
        content: SingleChildScrollView(
          child: Form(
            key: _emailFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: AppSpacing.md(context)),
                CommonTextField(
                  labelText: Strings.emailLabel,
                  hintText: Strings.enterYourNewEmail,
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return Strings.pleaseEnterEmail;
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return Strings.pleaseEnterValidEmail;
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(Strings.cancel),
          ),
          Consumer<SettingsProvider>(
            builder: (context, settingsProvider, _) {
              return TextButton(
                onPressed: settingsProvider.isLoading
                    ? null
                    : () async {
                        if (_emailFormKey.currentState!.validate()) {
                          final success =
                              await settingsProvider.updateProfile(
                            fullName: null,
                            email: _emailController.text.trim(),
                          );
                          if (!mounted) return;
                          if (success) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(Strings.emailUpdatedSuccess),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  settingsProvider.errorMessage ??
                                      Strings.failedToUpdateEmail,
                                ),
                              ),
                            );
                          }
                        }
                      },
                child: settingsProvider.isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).primaryColor,
                        ),
                      )
                    : const Text(Strings.update),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showUpdatePasswordDialog() async {
    _oldPasswordController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(Strings.updatePasswordTitle),
        content: SingleChildScrollView(
          child: Form(
            key: _passwordFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: AppSpacing.md(context)),
                CommonTextField(
                  labelText: Strings.oldPasswordLabel,
                  hintText: Strings.oldPasswordHint,
                  obscureText: true,
                  controller: _oldPasswordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return Strings.oldPasswordRequired;
                    }
                    return null;
                  },
                ),
                SizedBox(height: AppSpacing.md(context)),
                CommonTextField(
                  labelText: Strings.newPasswordLabel,
                  hintText: Strings.newPasswordHint,
                  obscureText: true,
                  controller: _passwordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return Strings.pleaseEnterPassword;
                    }
                    if (value.length < 6) {
                      return Strings.passwordMinLength;
                    }
                    return null;
                  },
                ),
                SizedBox(height: AppSpacing.md(context)),
                CommonTextField(
                  labelText: Strings.confirmPasswordLabel,
                  hintText: Strings.confirmPasswordHint,
                  obscureText: true,
                  controller: _confirmPasswordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return Strings.pleaseConfirmPassword;
                    }
                    if (value != _passwordController.text) {
                      return Strings.passwordsDoNotMatch;
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(Strings.cancel),
          ),
          Consumer<SettingsProvider>(
            builder: (context, settingsProvider, _) {
              return TextButton(
                onPressed: settingsProvider.isLoading
                    ? null
                    : () async {
                        if (_passwordFormKey.currentState!.validate()) {
                          final success =
                              await settingsProvider.updatePassword(
                            oldPassword: _oldPasswordController.text.trim(),
                            newPassword: _passwordController.text.trim(),
                          );
                          if (!mounted) return;
                          if (success) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(Strings.passwordUpdatedSuccess),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  settingsProvider.errorMessage ??
                                      Strings.failedToUpdatePassword,
                                ),
                              ),
                            );
                          }
                        }
                      },
                child: settingsProvider.isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).primaryColor,
                        ),
                      )
                    : const Text(Strings.update),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showLogoutDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(Strings.logoutTitle),
        content: const Text(Strings.logoutMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(Strings.cancel),
          ),
          Consumer<SettingsProvider>(
            builder: (context, settingsProvider, _) {
              return TextButton(
                onPressed: settingsProvider.isLoading
                    ? null
                    : () async {
                        final success = await settingsProvider.logout();
                        if (!mounted) return;
                        if (success) {
                            Navigator.pop(context); // Close dialog first
                            context.goNamed(
                              MyAppRouteConstants.authWrapperRouteName);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                settingsProvider.errorMessage ??
                                    Strings.failedToLogout,
                              ),
                            ),
                          );
                        }
                      },
                child: settingsProvider.isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).primaryColor,
                        ),
                      )
                    : const Text(Strings.logoutTitle),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteAccountDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(Strings.deleteAccountTitle),
        content: const Text(Strings.deleteAccountMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(Strings.cancel),
          ),
          Consumer<SettingsProvider>(
            builder: (context, settingsProvider, _) {
              return TextButton(
                onPressed: settingsProvider.isLoading
                    ? null
                    : () async {
                        final success =
                            await settingsProvider.deleteAccount();
                        if (!mounted) return;
                        if (success) {
                            Navigator.pop(context); // Close dialog first
                            context.goNamed(
                              MyAppRouteConstants.authWrapperRouteName);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                settingsProvider.errorMessage ??
                                    Strings.failedToDeleteAccount,
                              ),
                            ),
                          );
                        }
                      },
                child: settingsProvider.isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.red,
                        ),
                      )
                    : const Text(
                        Strings.delete,
                        style: TextStyle(color: Colors.red),
                      ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showEditOptionsSheet() async {
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md(context)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSheetAction(
                  context: context,
                  title: Strings.updateFullNameTitle,
                  icon: AppIcons.editUserIcon,
                  onTap: () {
                    Navigator.pop(context);
                    _showUpdateNameDialog();
                  },
                ),
                _buildSheetAction(
                  context: context,
                  title: Strings.updateEmailTitle,
                  icon: AppIcons.emailIcon,
                  onTap: () {
                    Navigator.pop(context);
                    _showUpdateEmailDialog();
                  },
                ),
                _buildSheetAction(
                  context: context,
                  title: Strings.updatePasswordTitle,
                  icon: AppIcons.passwordIcon,
                  onTap: () {
                    Navigator.pop(context);
                    _showUpdatePasswordDialog();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appThemeProvider = context.watch<AppThemeProvider>();
    final isDarkMode = appThemeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: const Text(Strings.accountTitle),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, _) {
          if (settingsProvider.isLoading &&
              settingsProvider.userData == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final userData = settingsProvider.userData;
          if (userData == null) {
            return Center(
              child: Text(
                settingsProvider.errorMessage ?? Strings.failedToLoadUserData,
              ),
            );
          }

          final currentUser = settingsProvider.currentUser;
          final fullName = userData['fullName'] ?? Strings.na;
          final email = userData['email'] ?? currentUser?.email ?? Strings.na;
          final phone = userData['phone'] ?? Strings.na;
          final photoUrl = userData['photoUrl'];

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg(context)),
                  child: _buildProfileRow(
                    context: context,
                    name: fullName,
                    email: email,
                    photoUrl: photoUrl,
                    settingsProvider: settingsProvider,
                    phone: phone,
                  ),
                ),
                SizedBox(height: AppSpacing.lg(context)),
                const Divider(height: 1),
                _buildActionRow(
                  context: context,
                  title: isDarkMode ? Strings.switchToLightMode : Strings.switchToDarkMode,
                  leading: isDarkMode
                      ? AppIcons.lightModeIcon
                      : AppIcons.darkModeIcon,
                  color: AppColors.appColor,
                  onTap: () {
                    context.read<AppThemeProvider>().changeTheme();
                  },
                ),
                const Divider(height: 1),
                _buildActionRow(
                  context: context,
                  title: Strings.logoutTitle,
                  leading: AppIcons.logoutIcon,
                  color: Colors.orange,
                  onTap: _showLogoutDialog,
                ),
                const Divider(height: 1),
                _buildActionRow(
                  context: context,
                  title: Strings.deleteAccountTitle,
                  leading: AppIcons.deleteForeverIcon,
                  color: Colors.red,
                  onTap: _showDeleteAccountDialog,
                  isDestructive: true,
                ),
                const Divider(height: 1),
                if (settingsProvider.errorMessage != null)
                  Padding(
                    padding: EdgeInsets.all(AppSpacing.lg(context)),
                    child: Container(
                      padding: EdgeInsets.all(AppSpacing.md(context)),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade100),
                      ),
                      child: Row(
                        children: [
                          const Icon(AppIcons.errorOutlineIcon, color: Colors.red),
                          SizedBox(width: AppSpacing.md(context)),
                          Expanded(
                            child: Text(
                              settingsProvider.errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileRow({
    required BuildContext context,
    required String name,
    required String email,
    required String phone,
    required dynamic photoUrl,
    required SettingsProvider settingsProvider,
  }) {
    return Row(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade200,
              ),
              child: _buildProfileImage(photoUrl),
            ),
            GestureDetector(
              onTap: settingsProvider.isUploadingImage
                  ? null
                  : () async {
                      final success = await settingsProvider.pickAndUploadImage();
                      if (!mounted) return;
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text(Strings.profilePictureUpdated)),
                        );
                      }
                    },
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: settingsProvider.isUploadingImage
                    ? Padding(
                        padding: const EdgeInsets.all(6),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.appColor,
                        ),
                      )
                    : Icon(AppIcons.cameraIcon, size: 16, color: AppColors.appColor),
              ),
            ),
          ],
        ),
        SizedBox(width: AppSpacing.md(context)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: AppSpacing.xs(context)),
              Text(
                email,
                style: TextStyle(color: Colors.grey.shade700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: AppSpacing.xs(context)),
              Text(
                phone,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: _showEditOptionsSheet,
          child: Text(
            Strings.edit,
            style: TextStyle(
              color: AppColors.appColor,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionRow({
    required BuildContext context,
    required String title,
    required IconData leading,
    required Color color,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg(context),
          vertical: AppSpacing.lg(context),
        ),
        child: Row(
          children: [
            Icon(leading, color: color),
            SizedBox(width: AppSpacing.md(context)),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: isDestructive
                      ? Colors.red
                      : Theme.of(context).textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(AppIcons.chevronRightIcon, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildSheetAction({
    required BuildContext context,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.appColor),
      title: Text(title),
      trailing: const Icon(AppIcons.chevronRightIcon),
      onTap: onTap,
    );
  }

  Widget _buildProfileImage(dynamic photoUrl) {
    if (photoUrl != null && photoUrl.startsWith('data:image')) {
      try {
        // Extract base64 from data URL
        final base64String = photoUrl.split(',').last;
        final imageBytes = base64Decode(base64String);
        return ClipOval(
          child: Image.memory(
            imageBytes,
            fit: BoxFit.cover,
          ),
        );
      } catch (e) {
        print('Error decoding image: $e');
        return Icon(
          AppIcons.userIcon,
          size: 60,
          color: Colors.grey[400],
        );
      }
    }
    return Icon(
      AppIcons.userIcon,
      size: 60,
      color: Colors.grey[400],
    );
  }

}
