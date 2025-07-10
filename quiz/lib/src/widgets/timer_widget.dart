import 'dart:async';
import 'package:flutter/material.dart';

class QuizTimer extends StatefulWidget {
  final int totalSeconds;
  final VoidCallback onTimeUp;

  const QuizTimer(
      {required this.totalSeconds, required this.onTimeUp, super.key});

  @override
  State<QuizTimer> createState() => _QuizTimerState();
}

class _QuizTimerState extends State<QuizTimer> {
  late int secondsLeft;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    secondsLeft = widget.totalSeconds;
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (secondsLeft == 0) {
        widget.onTimeUp();
        timer?.cancel();
      } else {
        setState(() {
          secondsLeft--;
        });
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text("Time left: $secondsLeft s",
        style: const TextStyle(fontSize: 16, color: Colors.red));
  }
}
