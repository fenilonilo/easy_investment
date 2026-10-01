import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:markdown/markdown.dart' as md;
import '../../../core/constants/app_colors.dart';
import '../../viewmodels/chat_viewmodel.dart';
import 'widgets/session_history_sheet.dart';
import 'widgets/typing_indicator.dart';

class ChatView extends ConsumerStatefulWidget {
  const ChatView({super.key});

  @override
  ConsumerState<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends ConsumerState<ChatView> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    // Reabre a última conversa após reload/reinício do app.
    Future.microtask(
        () => ref.read(chatNotifierProvider.notifier).restaurarUltima());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    if (ref.read(chatNotifierProvider).typing) return;
    HapticFeedback.lightImpact();
    _ctrl.clear();
    ref.read(chatNotifierProvider.notifier).send(text);
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  void _scrollToBottom() {
    if (_scroll.hasClients) {
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _abrirHistorico() async {
    HapticFeedback.lightImpact();
    final sessionId = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const SessionHistorySheet(),
    );
    if (sessionId == null || !mounted) return;
    await ref.read(chatNotifierProvider.notifier).abrirConversa(sessionId);
    if (!mounted) return;
    Future.delayed(const Duration(milliseconds: 150), _scrollToBottom);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatNotifierProvider);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final streaming = state.streamingText.isNotEmpty;

    ref.listen<ChatState>(chatNotifierProvider, (_, __) {
      Future.delayed(const Duration(milliseconds: 150), _scrollToBottom);
    });

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, Color(0xFF00A004)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.smart_toy_rounded,
                color: Colors.black,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.assetAdvisor,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                Text(
                  state.typing
                      ? (state.toolLabel ?? l10n.thinking)
                      : l10n.liveMarketData,
                  style: TextStyle(
                      fontSize: 10, color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: l10n.previousChats,
            onPressed: _abrirHistorico,
          ),
          IconButton(
            icon: const Icon(Icons.add_comment_outlined),
            tooltip: l10n.newChat,
            onPressed: () {
              HapticFeedback.lightImpact();
              ref.read(chatNotifierProvider.notifier).clear();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: state.messages.length + (state.typing ? 1 : 0),
              itemBuilder: (_, i) {
                if (state.typing && i == state.messages.length) {
                  // Enquanto não chega token, indicador; depois, a resposta
                  // parcial vai crescendo na própria bolha.
                  if (!streaming) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: state.toolLabel == null
                            ? const TypingIndicator()
                            : _ToolChip(label: state.toolLabel!),
                      ),
                    );
                  }
                  return _MessageBubble(
                    message: ChatMessage(
                      text: state.streamingText,
                      isUser: false,
                      timestamp: DateTime.now(),
                    ),
                    isDark: isDark,
                  );
                }
                final msg = state.messages[i];
                final shown = !msg.isUser && msg.text == kChatGreeting
                    ? ChatMessage(
                        text: l10n.chatGreeting,
                        isUser: false,
                        timestamp: msg.timestamp)
                    : msg;
                return _MessageBubble(message: shown, isDark: isDark);
              },
            ),
          ),
          if (state.error != null)
            _ErrorBanner(
              message: state.error!,
              onRetry: state.podeTentarDeNovo && !state.typing
                  ? ref.read(chatNotifierProvider.notifier).tentarDeNovo
                  : null,
              onDismiss: () =>
                  ref.read(chatNotifierProvider.notifier).limparErro(),
            ),
          // Input bar
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.divider : Colors.grey.shade200,
                  width: 0.5,
                ),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      onSubmitted: (_) => _send(),
                      onChanged: (_) => setState(() {}),
                      textInputAction: TextInputAction.send,
                      maxLines: 4,
                      minLines: 1,
                      maxLength: kChatMaxMessageLength,
                      decoration: InputDecoration(
                        hintText: l10n.askAboutAsset,
                        // maxLength trunca em silêncio: avisa perto/no limite.
                        counterText: _ctrl.text.length >= 3800
                            ? '${_ctrl.text.length}/$kChatMaxMessageLength'
                            : '',
                        counterStyle: TextStyle(
                          fontSize: 11,
                          color: _ctrl.text.length >= kChatMaxMessageLength
                              ? AppColors.loss
                              : AppColors.textSecondary,
                        ),
                        helperText:
                            _ctrl.text.length >= kChatMaxMessageLength
                                ? l10n.charLimitReached(kChatMaxMessageLength)
                                : null,
                        helperStyle: const TextStyle(
                            fontSize: 11, color: AppColors.loss),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor:
                            isDark ? AppColors.cardDark : Colors.grey.shade100,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: state.typing
                        ? ref.read(chatNotifierProvider.notifier).cancelar
                        : _send,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: state.typing
                            ? AppColors.textSecondary
                            : AppColors.primary,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Icon(
                        state.typing ? Icons.stop_rounded : Icons.send_rounded,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolChip extends StatelessWidget {
  final String label;

  const _ToolChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;
  final VoidCallback? onRetry;

  const _ErrorBanner(
      {required this.message, required this.onDismiss, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.loss.withOpacity(0.12),
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 18, color: AppColors.loss),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style:
                  const TextStyle(fontSize: 12, color: AppColors.loss),
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              child: Text(AppLocalizations.of(context)!.retryAgain,
                  style: const TextStyle(fontSize: 12, color: AppColors.loss)),
            ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 18),
            color: AppColors.loss,
            onPressed: onDismiss,
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isDark;

  const _MessageBubble({required this.message, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final theme = Theme.of(context);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 10,
          left: isUser ? 48 : 0,
          right: isUser ? 0 : 48,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isUser
              ? AppColors.primary
              : (isDark ? AppColors.cardDark : Colors.white),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 18),
          ),
          border: isUser
              ? null
              : Border.all(
                  color: isDark ? AppColors.divider : Colors.grey.shade200,
                  width: 0.5,
                ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: isUser
            ? Text(
                message.text,
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.w500),
              )
            : MarkdownBody(
                data: latexLegivel(message.text),
                selectable: true,
                // gitHubWeb habilita tabelas — o agente responde com elas.
                extensionSet: md.ExtensionSet.gitHubWeb,
                styleSheet: MarkdownStyleSheet(
                  p: theme.textTheme.bodyMedium,
                  strong: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                  tableHead: theme.textTheme.bodySmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                  tableBody: theme.textTheme.bodySmall,
                  // Contraste explícito: os defaults somem no tema escuro.
                  blockquote: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.85)),
                  blockquoteDecoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(4),
                    border: const Border(
                      left: BorderSide(color: AppColors.primary, width: 3),
                    ),
                  ),
                  horizontalRuleDecoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                          color: isDark
                              ? AppColors.divider
                              : Colors.grey.shade300,
                          width: 1),
                    ),
                  ),
                  code: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                    backgroundColor: isDark
                        ? Colors.white.withOpacity(0.08)
                        : Colors.black.withOpacity(0.06),
                  ),
                  codeblockPadding: const EdgeInsets.all(10),
                  codeblockDecoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.08)
                        : Colors.black.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
      ),
    );
  }
}

/// O agente às vezes responde com LaTeX (`$$\frac{a}{b}$$`), que o markdown
/// não renderiza. Converte o básico para texto legível.
String latexLegivel(String texto) {
  String limpa(String m) {
    var t = m;
    // \frac{a}{b} -> (a)/(b); repete p/ aninhados simples.
    final frac = RegExp(r'\\frac\{([^{}]*)\}\{([^{}]*)\}');
    for (var i = 0; i < 3; i++) {
      t = t.replaceAllMapped(frac, (x) => '(${x[1]})/(${x[2]})');
    }
    t = t.replaceAllMapped(
        RegExp(r'\\(?:text|mathrm|mathbf|operatorname)\{([^{}]*)\}'),
        (x) => x[1]!);
    const troca = {
      r'\times': '×',
      r'\cdot': '·',
      r'\approx': '≈',
      r'\leq': '≤',
      r'\geq': '≥',
      r'\%': '%',
      r'\$': r'$',
      r'\,': ' ',
      r'\left': '',
      r'\right': '',
    };
    troca.forEach((k, v) => t = t.replaceAll(k, v));
    return t.trim();
  }

  return texto
      .replaceAllMapped(RegExp(r'\$\$([\s\S]+?)\$\$'), (m) => limpa(m[1]!))
      .replaceAllMapped(RegExp(r'\\\(([\s\S]+?)\\\)|\\\[([\s\S]+?)\\\]'),
          (m) => limpa(m[1] ?? m[2]!));
}
