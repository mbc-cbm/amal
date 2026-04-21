import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/router/app_router.dart';
import '../../shared/widgets/amal_button.dart';
import '../../shared/widgets/amal_text_field.dart';

class EmailAuthScreen extends ConsumerStatefulWidget {
  const EmailAuthScreen({super.key});

  @override
  ConsumerState<EmailAuthScreen> createState() => _EmailAuthScreenState();
}

class _EmailAuthScreenState extends ConsumerState<EmailAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _isSignUp = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit(AppLocalizations l10n) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final notifier = ref.read(signInProvider.notifier);
    bool ok;
    if (_isSignUp) {
      ok = await notifier.createAccount(
          _emailCtrl.text.trim(), _passwordCtrl.text);
    } else {
      ok = await notifier.signInWithEmail(
          _emailCtrl.text.trim(), _passwordCtrl.text);
    }
    if (ok && mounted) context.go(AppRoutes.onboardingLanguage);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final signInState = ref.watch(signInProvider);
    final isLoading = signInState is AsyncLoading;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        leading: BackButton(color: cs.onSurface),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: AutofillGroup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    _isSignUp ? l10n.createAccount : l10n.signIn,
                    style: AppTypography.headlineMedium
                        .copyWith(color: cs.onSurface),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // ── Email ────────────────────────────────────────────────
                  AmalTextField(
                    label: l10n.emailLabel,
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    prefixIcon: const Icon(Icons.email_outlined),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return l10n.errorInvalidEmail;
                      }
                      if (!v.contains('@')) return l10n.errorInvalidEmail;
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // ── Password ─────────────────────────────────────────────
                  AmalTextField(
                    label: l10n.passwordLabel,
                    controller: _passwordCtrl,
                    obscureText: true,
                    textInputAction: _isSignUp
                        ? TextInputAction.next
                        : TextInputAction.done,
                    autofillHints: _isSignUp
                        ? const [AutofillHints.newPassword]
                        : const [AutofillHints.password],
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    validator: (v) {
                      if (v == null || v.length < 8) {
                        return l10n.errorWeakPassword;
                      }
                      return null;
                    },
                  ),

                  // ── Confirm password (sign-up only) ───────────────────────
                  if (_isSignUp) ...[
                    const SizedBox(height: AppSpacing.md),
                    AmalTextField(
                      label: l10n.confirmPasswordLabel,
                      controller: _confirmCtrl,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.newPassword],
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      validator: (v) {
                        if (v != _passwordCtrl.text) {
                          return l10n.passwordsDoNotMatch;
                        }
                        return null;
                      },
                    ),
                  ],

                  // ── Forgot password (sign-in only) ────────────────────────
                  if (!_isSignUp)
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: AmalTextButton(
                        label: l10n.forgotPassword,
                        onPressed: () =>
                            context.go(AppRoutes.authForgotPassword),
                        subtle: true,
                      ),
                    ),

                  const SizedBox(height: AppSpacing.xl),

                  // ── Submit ────────────────────────────────────────────────
                  AmalPrimaryButton(
                    label: _isSignUp ? l10n.createAccount : l10n.signIn,
                    isLoading: isLoading,
                    onPressed: () => _submit(l10n),
                  ),

                  // ── Error ─────────────────────────────────────────────────
                  if (signInState is AsyncError) ...[
                    const SizedBox(height: AppSpacing.md),
                    _ErrorText(
                      message: _mapError(signInState.error, l10n),
                    ),
                  ],

                  const SizedBox(height: AppSpacing.lg),

                  // ── Toggle sign-in / sign-up ──────────────────────────────
                  Center(
                    child: AmalTextButton(
                      label: _isSignUp
                          ? l10n.alreadyHaveAccount
                          : l10n.noAccount,
                      onPressed: () => setState(() => _isSignUp = !_isSignUp),
                      subtle: true,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _mapError(Object error, AppLocalizations l10n) {
    final code = error.toString();
    if (code.contains('email-already-in-use')) return l10n.errorEmailAlreadyInUse;
    if (code.contains('wrong-password') || code.contains('invalid-credential')) {
      return l10n.errorWrongPassword;
    }
    if (code.contains('user-not-found')) return l10n.errorUserNotFound;
    if (code.contains('weak-password')) return l10n.errorWeakPassword;
    if (code.contains('network')) return l10n.errorNetworkRequest;
    return l10n.errorSignInFailed;
  }
}

class _ErrorText extends StatelessWidget {
  const _ErrorText({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.errorContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Text(
        message,
        style: AppTypography.bodySmall.copyWith(color: cs.onErrorContainer),
        textAlign: TextAlign.center,
      ),
    );
  }
}
