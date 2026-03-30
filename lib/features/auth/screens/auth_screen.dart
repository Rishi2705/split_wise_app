import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:split_wise_app/core/constants/app_route_constants.dart';
import 'package:split_wise_app/core/constants/app_spacing.dart';
import 'package:split_wise_app/core/widgets/common_app_bar.dart';
import 'package:split_wise_app/core/widgets/common_text_form_field.dart';
import 'package:split_wise_app/core/widgets/submit_button.dart';
import '../provider/auth_provider.dart';
import 'package:split_wise_app/core/constants/strings.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isLogin = false;
  String email = '';
  String password = '';

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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            !isLogin ? Strings.createAccountTitle : Strings.loginTitle,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          SizedBox(height: AppSpacing.xl(context)),
                          CommonTextField(
                            labelText: Strings.emailLabel,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (!value!.contains('@')) {
                                return Strings.pleaseEnterValidEmail;
                              }
                              if (value.isEmpty) {
                                return Strings.pleaseEnterEmail;
                              }
                              return null;
                            },
                            onSaved: (value) {
                              setState(() {
                                email = value!;
                              });
                            },
                          ),
                          SizedBox(height: AppSpacing.md(context)),
                          CommonTextField(
                            labelText: Strings.passwordLabel,
                            obscureText: true,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return Strings.pleaseEnterPassword;
                              } else if (value.length < 6) {
                                return Strings.passwordMinLength;
                              }
                              return null;
                            },
                            onSaved: (value) {
                              setState(() {
                                password = value!;
                              });
                            },
                          ),
                          SizedBox(height: AppSpacing.xl(context)),
                          Consumer<AuthProvider>(
                            builder: (context, authProvider, _) {
                              return SubmitButton(
                                text: Strings.submitLabel,
                                isLoading: authProvider.isBusy,
                                onPressed: authProvider.isBusy
                                    ? null
                                    : () async {
                                        if (_formKey.currentState == null) return;
                                        if (!_formKey.currentState!.validate()) return;
                                        _formKey.currentState!.save();

                                        try {
                                          if (isLogin) {
                                            await authProvider.login(
                                              email.trim(),
                                              password.trim(),
                                            );
                                            if (!mounted) return;
                                            context.goNamed(
                                              MyAppRouteConstants.bottomNavRouteName,
                                            );
                                          } else {
                                            await authProvider.signup(
                                              email.trim(),
                                              password.trim(),
                                            );
                                            if (!mounted) return;
                                            context.goNamed(
                                              MyAppRouteConstants.userDetailsRouteName,
                                            );
                                          }
                                        } catch (e) {
                                          if (!mounted) return;
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text(e.toString())),
                                          );
                                        }
                                      },
                              );
                            },
                          ),
                          SizedBox(height: AppSpacing.xxl(context)),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                isLogin = !isLogin;
                              });
                            },
                            child: Text(
                              !isLogin
                                  ? Strings.alreadyHaveAccountLogin
                                  : Strings.createAnAccount,
                            ),
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
