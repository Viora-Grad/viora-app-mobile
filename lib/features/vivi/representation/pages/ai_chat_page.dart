import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viora_app/core/di/service_locator.dart';
import 'package:viora_app/features/vivi/representation/blocs/chat/chat_bloc.dart';
import 'package:viora_app/features/vivi/representation/blocs/chat/chat_event.dart';
import 'package:viora_app/features/vivi/representation/blocs/chat/chat_state.dart';
import 'package:viora_app/features/vivi/representation/widgets/chat_input_bar.dart';
import 'package:viora_app/features/vivi/representation/widgets/disclaimer_bar.dart';
import 'package:viora_app/features/vivi/representation/widgets/empty_chat_placeholder.dart';
import 'package:viora_app/features/vivi/representation/widgets/message_bubble.dart';
import 'package:viora_app/features/vivi/representation/widgets/typing_indicator.dart';
import 'package:viora_app/features/vivi/representation/blocs/sessions/sessions_bloc.dart';
import 'package:viora_app/features/vivi/representation/widgets/sessions_drawer.dart';

class AiChatPage extends StatefulWidget {
  const AiChatPage({super.key});

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  final _scrollController = ScrollController();
  final _inputController = TextEditingController();

  @override
  void dispose() {
    _scrollController.dispose();
    _inputController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<ChatBloc>()..add(const NewChatEvent())),
        BlocProvider(create: (_) => sl<SessionsBloc>()),
      ],
      child: Scaffold(
        drawer: const SessionsDrawer(),
        appBar: _buildAppBar(context),
        body: BlocConsumer<ChatBloc, ChatState>(
          listener: (context, state) {
            if (state is ChatReady) {
              _scrollToBottom();
              if (state.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage!),
                    backgroundColor: Colors.redAccent,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }
            }
          },
          builder: (context, state) {
            final ready = state is ChatReady ? state : null;
            final messages = ready?.messages ?? [];
            final isSending = ready?.isSending ?? false;

            return Column(
              children: [
                Expanded(
                  child: messages.isEmpty && !isSending
                      ? EmptyChatPlaceholder(
                          onSuggestionTap: (text) {
                            _inputController.text = text;
                            _inputController.selection =
                                TextSelection.fromPosition(
                                  TextPosition(offset: text.length),
                                );
                          },
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.only(top: 12, bottom: 8),
                          itemCount: messages.length + (isSending ? 1 : 0),
                          itemBuilder: (ctx, i) {
                            if (i == messages.length && isSending) {
                              return const TypingIndicator();
                            }
                            final isLastAi =
                                i == messages.length - 1 &&
                                !messages[i].isUser &&
                                !isSending;
                            return MessageBubble(
                              message: messages[i],
                              isStreaming: isLastAi,
                            );
                          },
                        ),
                ),
                const DisclaimerBar(),
                ChatInputBar(
                  controller: _inputController,
                  isSending: isSending,
                  onSend: (text) =>
                      context.read<ChatBloc>().add(SendMessageEvent(text)),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  PreferredSize _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFF0F0F0), width: 1),
          ),
        ),
        child: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Back',
          ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2F1193), Color(0xFF6B3FA0)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    'V',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Vivi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'Viora AI Assistant',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
          centerTitle: false,
          actions: [
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu_rounded),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
                tooltip: 'Chat history',
              ),
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}
