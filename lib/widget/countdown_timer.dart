import 'dart:async';

import 'package:flutter/material.dart';

class CountdownTimer extends StatefulWidget {
  final VoidCallback onFinish;

  const CountdownTimer({super.key, required this.onFinish});

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  int _countdown = 5;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        widget.onFinish();
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 1, end: _countdown / 5),
          duration: const Duration(seconds: 1),
          builder: (context, value, child) =>
              CircularProgressIndicator(value: value),
        ),
        Align(
          alignment: Alignment.center,
          child: Text("$_countdown"),
        ),
      ],
    );
  }
}
