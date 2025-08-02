import 'package:flutter/material.dart';
import '../utils/colors.dart';

class TimerWidget extends StatelessWidget {
  final int seconds;
  final int totalSeconds;
  final bool isRunning;

  const TimerWidget({
    Key? key,
    required this.seconds,
    required this.totalSeconds,
    this.isRunning = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    final double progress = totalSeconds > 0 ? (totalSeconds - seconds) / totalSeconds : 0;

    return Container(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Progress ring
          SizedBox(
            width: 180,
            height: 180,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 12,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(
                isRunning ? AppColors.accentOrange : AppColors.forestGreen,
              ),
            ),
          ),
          // Time display
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.forestGreen.shade700,
                ),
              ),
              if (isRunning)
                Text(
                  'Stay Focused!',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.forestGreen.shade500,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
