import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viora_app/features/vivi/domain/entities/session_summary.dart';
import 'package:viora_app/features/vivi/representation/blocs/chat/chat_bloc.dart';
import 'package:viora_app/features/vivi/representation/blocs/chat/chat_event.dart';
import 'package:viora_app/features/vivi/representation/blocs/sessions/sessions_bloc.dart';
import 'package:viora_app/features/vivi/representation/blocs/sessions/sessions_event.dart';
import 'package:viora_app/features/vivi/representation/blocs/sessions/sessions_state.dart';

class SessionsDrawer extends StatefulWidget {
  const SessionsDrawer({super.key});

  @override
  State<SessionsDrawer> createState() => _SessionsDrawerState();
}

class _SessionsDrawerState extends State<SessionsDrawer> {
  @override
  void initState() {
    super.initState();
    context.read<SessionsBloc>().add(const LoadSessionsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.82,
      backgroundColor: const Color(0xFF0F172A),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF2F1193),
                          Color(0xFF6B3FA0)
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text('V',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Vivi',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  context
                      .read<ChatBloc>()
                      .add(const NewChatEvent());
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.add_rounded,
                          color: Colors.white.withValues(alpha: 0.8),
                          size: 18),
                      const SizedBox(width: 10),
                      Text(
                        'New Chat',
                        style: TextStyle(
                            color:
                                Colors.white.withValues(alpha: 0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Text(
                'Recent',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8),
              ),
            ),
            Expanded(
              child: BlocConsumer<SessionsBloc, SessionsState>(
                listener: (context, state) {
                  if (state is SessionHistoryLoaded) {
                    context
                        .read<ChatBloc>()
                        .add(LoadSessionEvent(
                      sessionId: state.history.sessionId,
                      messages: state.history.messages,
                    ));
                    context
                        .read<SessionsBloc>()
                        .add(const LoadSessionsEvent());
                    Navigator.pop(context);
                  }
                },
                builder: (context, state) {
                  if (state is SessionsLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF2F1193),
                          strokeWidth: 2),
                    );
                  }
                  if (state is SessionsError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: TextStyle(
                            color:
                                Colors.white.withValues(alpha: 0.5),
                            fontSize: 13),
                      ),
                    );
                  }
                  if (state is SessionsLoaded) {
                    if (state.sessions.isEmpty) {
                      return Center(
                        child: Text(
                          'No conversations yet.',
                          style: TextStyle(
                              color: Colors.white.withValues(
                                  alpha: 0.35),
                              fontSize: 13),
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 4),
                      itemCount: state.sessions.length,
                      itemBuilder: (ctx, i) => _SessionTile(
                          session: state.sessions[i]),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  final SessionSummary session;
  const _SessionTile({required this.session});

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  Widget build(BuildContext context) {
    final local = session.lastActiveAt.toLocal();
    final dateStr = '${_months[local.month - 1]} ${local.day}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => context
            .read<SessionsBloc>()
            .add(OpenSessionEvent(session)),
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.transparent,
          ),
          child: Row(
            children: [
              Icon(Icons.chat_bubble_outline_rounded,
                  size: 16,
                  color: Colors.white.withValues(alpha: 0.4)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.displayTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color:
                              Colors.white.withValues(alpha: 0.85),
                          fontSize: 13.5,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
              Text(
                dateStr,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
