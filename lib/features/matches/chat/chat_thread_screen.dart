import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/theme/app_colors.dart';
import '../../../shared/persistence/app_storage.dart';
import '../controllers/matches_controller.dart';

class ChatThreadScreen extends StatefulWidget {
  final String profileId;
  final String title;

  const ChatThreadScreen({
    super.key,
    required this.profileId,
    required this.title,
  });

  @override
  State<ChatThreadScreen> createState() => _ChatThreadScreenState();
}

class _ChatThreadScreenState extends State<ChatThreadScreen> {
  final TextEditingController _composer = TextEditingController();
  final FocusNode _focus = FocusNode();

  List<_ChatMsg> _messages = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _composer.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final storage = context.read<AppStorage>();
    final raw = storage.loadChatMessages(widget.profileId);
    final msgs = raw.map(_ChatMsg.fromJson).toList();
    setState(() {
      _messages = msgs;
      _loading = false;
    });
  }

  Future<void> _persist() async {
    final storage = context.read<AppStorage>();
    final raw = _messages.map((m) => m.toJson()).toList();
    await storage.saveChatMessages(widget.profileId, raw);
  }

  Future<void> _send() async {
    final text = _composer.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(
        _ChatMsg(
          text: text,
          isMe: true,
          atMs: DateTime.now().millisecondsSinceEpoch,
        ),
      );
      _composer.clear();
    });

    await _persist();

    // Update matches list snippet
    await context.read<MatchesController>().updateThreadLastMessage(
      profileId: widget.profileId,
      lastMessage: text,
    );

    // keep keyboard open; Enter should not send (send button only)
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final body = _loading
        ? const Center(child: CircularProgressIndicator())
        : _messages.isEmpty
        ? Center(
            child: Text(
              'Be bold and make the first move.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            itemCount: _messages.length,
            itemBuilder: (context, i) {
              final m = _messages[i];
              return _Bubble(msg: m);
            },
          );

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          Expanded(child: body),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _composer,
                      focusNode: _focus,
                      textInputAction:
                          TextInputAction.newline, // Enter -> newline
                      keyboardType: TextInputType.multiline,
                      minLines: 1,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Write a message…',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  FilledButton(onPressed: _send, child: const Text('Send')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final _ChatMsg msg;
  const _Bubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    // Spark accent for received bubbles (per your spec); sent bubbles stay neutral.
    final bg = msg.isMe
        ? AppColors.surfaceMuted
        : AppColors.sparkDating.withOpacity(0.18);
    final align = msg.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: align,
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 320),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(msg.text),
          ),
        ],
      ),
    );
  }
}

class _ChatMsg {
  final String text;
  final bool isMe;
  final int atMs;

  const _ChatMsg({required this.text, required this.isMe, required this.atMs});

  Map<String, dynamic> toJson() => {'text': text, 'isMe': isMe, 'atMs': atMs};

  factory _ChatMsg.fromJson(Map<String, dynamic> json) {
    return _ChatMsg(
      text: (json['text'] ?? '') as String,
      isMe: (json['isMe'] ?? false) as bool,
      atMs: (json['atMs'] as num?)?.toInt() ?? 0,
    );
  }
}
