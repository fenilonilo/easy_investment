import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/ai_chat_models.dart';
import '../../../viewmodels/chat_viewmodel.dart';

/// Conversas anteriores do usuário (`GET /ai/sessions`).
/// Fecha devolvendo o `session_id` escolhido, ou null se o usuário desistir.
class SessionHistorySheet extends ConsumerStatefulWidget {
  const SessionHistorySheet({super.key});

  @override
  ConsumerState<SessionHistorySheet> createState() =>
      _SessionHistorySheetState();
}

class _SessionHistorySheetState extends ConsumerState<SessionHistorySheet> {
  late Future<List<AiSessionInfo>> _future;

  @override
  void initState() {
    super.initState();
    _future = ref.read(chatNotifierProvider.notifier).listarConversas();
  }

  void _recarregar() {
    setState(() {
      _future = ref.read(chatNotifierProvider.notifier).listarConversas();
    });
  }

  Future<void> _apagar(AiSessionInfo s) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteChatTitle),
        content: Text(l10n.deleteChatBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await ref.read(chatNotifierProvider.notifier).apagarConversa(s.sessionId);
      if (!mounted) return;
      _recarregar();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e is AiApiException ? e.mensagemAmigavel : l10n.deleteFailed,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.65,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  const Icon(Icons.history_rounded, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    l10n.previousChats,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: FutureBuilder<List<AiSessionInfo>>(
                future: _future,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.hasError) {
                    final e = snap.error;
                    return _Aviso(
                      icone: Icons.error_outline_rounded,
                      texto: e is AiApiException
                          ? e.mensagemAmigavel
                          : l10n.loadChatsFailed,
                      acao: _recarregar,
                    );
                  }
                  final sessions = snap.data ?? const <AiSessionInfo>[];
                  if (sessions.isEmpty) {
                    return _Aviso(
                      icone: Icons.forum_outlined,
                      texto: l10n.noChatsYet,
                    );
                  }
                  return ListView.separated(
                    itemCount: sessions.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final s = sessions[i];
                      return ListTile(
                        title: Text(
                          s.titulo,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          _subtitulo(s, l10n),
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textSecondary),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline_rounded,
                              size: 20),
                          tooltip: l10n.deleteChat,
                          onPressed: () => _apagar(s),
                        ),
                        onTap: () => Navigator.of(context).pop(s.sessionId),
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
  }

  String _subtitulo(AiSessionInfo s, AppLocalizations l10n) {
    final trocas = l10n.exchanges(s.runsCount);
    final data = s.updatedAt;
    if (data == null) return trocas;
    return '$trocas • ${DateFormat('dd/MM HH:mm').format(data)}';
  }
}

class _Aviso extends StatelessWidget {
  final IconData icone;
  final String texto;
  final VoidCallback? acao;

  const _Aviso({required this.icone, required this.texto, this.acao});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, size: 36, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            Text(
              texto,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textSecondary),
            ),
            if (acao != null) ...[
              const SizedBox(height: 12),
              TextButton(onPressed: acao, child: Text(AppLocalizations.of(context)!.retryAgain)),
            ],
          ],
        ),
      ),
    );
  }
}
