import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/validators.dart';
import '../../viewmodels/auth_viewmodel.dart';

class RegisterView extends ConsumerStatefulWidget {
  const RegisterView({super.key});

  @override
  ConsumerState<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends ConsumerState<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  DateTime? _birthDate;
  String _investorProfile = 'CONSERVATIVE';
  bool _obscure = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    HapticFeedback.lightImpact();
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 25),
      firstDate: DateTime(1920),
      lastDate: DateTime(now.year - 18),
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  Future<void> _submit() async {
    HapticFeedback.lightImpact();
    if (!_formKey.currentState!.validate()) return;
    if (_birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.selectBirthDate)),
      );
      return;
    }
    final dateStr =
        '${_birthDate!.year.toString().padLeft(4, '0')}-'
        '${_birthDate!.month.toString().padLeft(2, '0')}-'
        '${_birthDate!.day.toString().padLeft(2, '0')}';
    await ref.read(authNotifierProvider.notifier).register(
          name: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: _pwdCtrl.text,
          birthDate: dateStr,
          investorProfile: _investorProfile,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authNotifierProvider, (_, state) {
      if (state.status == AuthStatus.success) {
        context.go('/home');
      } else if (state.status == AuthStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.error ?? 'Erro')),
        );
      }
    });

    final isLoading =
        ref.watch(authNotifierProvider).status == AuthStatus.loading;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.createAccount)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.yourInfo,
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameCtrl,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => Validators.required(v, l10n.name, l10n),
                  decoration: InputDecoration(
                    labelText: l10n.fullName,
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (v) => Validators.email(v, l10n),
                  decoration: InputDecoration(
                    labelText: l10n.email,
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _pwdCtrl,
                  obscureText: _obscure,
                  textInputAction: TextInputAction.done,
                  validator: (v) => Validators.password(v, l10n),
                  decoration: InputDecoration(
                    labelText: l10n.password,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () =>
                          setState(() => _obscure = !_obscure),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _pickDate,
                  child: AbsorbPointer(
                    child: TextFormField(
                      readOnly: true,
                      validator: (_) =>
                          _birthDate == null ? 'Selecione a data' : null,
                      decoration: InputDecoration(
                        labelText: l10n.birthDate,
                        prefixIcon: const Icon(Icons.calendar_today_outlined),
                        hintText: _birthDate == null
                            ? 'Selecionar...'
                            : '${_birthDate!.day.toString().padLeft(2,'0')}/'
                              '${_birthDate!.month.toString().padLeft(2,'0')}/'
                              '${_birthDate!.year}',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _investorProfile,
                  decoration: InputDecoration(
                    labelText: l10n.investorProfile,
                    prefixIcon: Icon(Icons.show_chart_rounded),
                  ),
                  items: [
                    DropdownMenuItem(
                        value: 'CONSERVATIVE',
                        child: Text(l10n.conservative)),
                    DropdownMenuItem(
                        value: 'MODERATE', child: Text(l10n.moderate)),
                    DropdownMenuItem(
                        value: 'AGGRESSIVE', child: Text(l10n.aggressive)),
                  ],
                  onChanged: (v) {
                    HapticFeedback.selectionClick();
                    setState(() => _investorProfile = v!);
                  },
                ),
                const SizedBox(height: 32),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _submit,
                          child: Text(l10n.createAccount),
                        ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(l10n.haveAccount),
                    TextButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        context.pop();
                      },
                      child: Text(l10n.login),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
