import 'package:flutter/material.dart';

class StreamingAiText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final double charsPerSecond;

  const StreamingAiText({
    super.key,
    required this.text,
    this.style,
    this.charsPerSecond = 60,
  });

  @override
  State<StreamingAiText> createState() => _StreamingAiTextState();
}

class _StreamingAiTextState extends State<StreamingAiText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _visibleChars = 0;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  @override
  void didUpdateWidget(StreamingAiText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _controller.stop();
      _controller.reset();
      _visibleChars = 0;
      _startAnimation();
    }
  }

  void _startAnimation() {
    if (widget.text.isEmpty) return;
    final durationMs = (widget.text.length / widget.charsPerSecond * 1000)
        .round();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: durationMs.clamp(100, 15000)),
    );
    _controller.addListener(_onTick);
    _controller.forward();
  }

  void _onTick() {
    final newChars = (_controller.value * widget.text.length).round();
    if (newChars != _visibleChars) {
      setState(() => _visibleChars = newChars.clamp(0, widget.text.length));
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTick);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(widget.text.substring(0, _visibleChars), style: widget.style);
  }
}
