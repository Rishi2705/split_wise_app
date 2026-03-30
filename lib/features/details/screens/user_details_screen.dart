import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:split_wise_app/core/constants/app_route_constants.dart';
import 'package:split_wise_app/core/constants/app_spacing.dart';
import 'package:split_wise_app/core/constants/strings.dart';
import 'package:split_wise_app/core/widgets/common_app_bar.dart';
import 'package:split_wise_app/core/widgets/common_text_form_field.dart';
import 'package:split_wise_app/core/widgets/submit_button.dart';
import 'package:split_wise_app/features/details/services/user_firestore_services.dart';

class UserDetailsScreen extends StatefulWidget {
  const UserDetailsScreen({super.key});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userService = UserFirestoreServices();

  bool _isSaving = false;
  String _fullName = '';
  String _phone = '';
  String _email = '';

  @override
  void initState() {
    super.initState();
    _email = FirebaseAuth.instance.currentUser?.email ?? '';
  }

  Future<void> _saveUserDetails() async {
    final form = _formKey.currentState;
    if (form == null) return;
    if (!form.validate()) return;
    form.save();

    setState(() {
      _isSaving = true;
    });

    try {
      await _userService.createUser(
        fullName: _fullName.trim(),
        phone: _phone.trim(),
        email: _email.trim(),
      );

      if (!mounted) return;
      context.goNamed(MyAppRouteConstants.bottomNavRouteName);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: Strings.appName),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: AppSpacing.screenPadding(context),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                  maxWidth: constraints.maxWidth,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            Strings.completeYourProfile,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          SizedBox(height: AppSpacing.xl(context)),
                          CommonTextField(
                            labelText: Strings.fullNameLabel,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return Strings.pleaseEnterFullName;
                              }
                              return null;
                            },
                            onSaved: (value) => _fullName = value ?? '',
                          ),
                          SizedBox(height: AppSpacing.md(context)),
                          CommonTextField(
                            labelText: Strings.phoneNumberLabel,
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return Strings.pleaseEnterPhoneNumber;
                              }
                              if (value.trim().length < 10) {
                                return Strings.enterValidPhoneNumber;
                              }
                              return null;
                            },
                            onSaved: (value) => _phone = value ?? '',
                          ),
                          SizedBox(height: AppSpacing.md(context)),
                          CommonTextField(
                            labelText: Strings.emailLabel,
                            keyboardType: TextInputType.emailAddress,
                            hintText: _email,
                            validator: (value) {
                              final candidate = (value == null || value.trim().isEmpty)
                                  ? _email
                                  : value;
                              if (candidate.isEmpty || !candidate.contains('@')) {
                                return Strings.pleaseEnterValidEmail;
                              }
                              return null;
                            },
                            onSaved: (value) {
                              final incoming = value?.trim() ?? '';
                              _email = incoming.isEmpty ? _email : incoming;
                            },
                          ),
                          SizedBox(height: AppSpacing.xl(context)),
                          SubmitButton(
                            text: Strings.saveDetails,
                            isLoading: _isSaving,
                            onPressed: _saveUserDetails,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
