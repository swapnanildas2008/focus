import 'package:flutter/material.dart';
import 'dart:async';
import '../utils/colors.dart';
import '../services/database_helper.dart';
import '../models/focus_session.dart';

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({Key? key}) : super(key: key);

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> with TickerProviderStateMixin {
  Timer? _timer;
  int _seconds = 0;
  int _selectedMinutes = 25;
  bool _isRunning = false;
  bool _isPaused = false;
  List<FocusSession> _completedSessions = [];

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final List<int> _timerOptions = [5, 15, 25, 45, 60, 90];

  @override
  void initState() {
    super.initState();
    _loadCompletedSessions();
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _loadCompletedSessions() async {
    final sessions = await DatabaseHelper().getFocusSessions();
    setState(() {
      _completedSessions = sessions.where((s) => s.isCompleted).toList();
    });
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
      _isPaused = false;
      if (_seconds == 0) {
        _seconds = _selectedMinutes * 60;
      }
    });

    _pulseController.repeat(reverse: true);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_seconds > 0) {
          _seconds--;
        } else {
          _completeSession();
        }
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    _pulseController.stop();
    setState(() {
      _isPaused = true;
      _isRunning = false;
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _pulseController.stop();
    _pulseController.reset();
    setState(() {
      _isRunning = false;
      _isPaused = false;
      _seconds = 0;
    });
  }

  void _completeSession() {
    _timer?.cancel();
    _pulseController.stop();
    _pulseController.reset();
    
    setState(() {
      _isRunning = false;
      _isPaused = false;
      _seconds = 0;
    });

    final session = FocusSession(
      startTime: DateTime.now().subtract(Duration(minutes: _selectedMinutes)),
      endTime: DateTime.now(),
      durationMinutes: _selectedMinutes,
      isCompleted: true,
    );

    DatabaseHelper().insertFocusSession(session);
    _loadCompletedSessions();
    _showCompletionDialog();
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                AppColors.accentPurple.shade100,
                AppColors.accentBlue.shade50,
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.accentPurple,
                      AppColors.accentBlue,
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.timer,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '⏰ Pomodoro Complete!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You completed a $_selectedMinutes minute Pomodoro session!\nYour productivity grows stronger.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.accentPurple.shade600,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.accentPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '+10 Pomodoro Coins Earned! 🍅',
                  style: TextStyle(
                    color: AppColors.accentPurple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.accentPurple,
                        side: BorderSide(color: AppColors.accentPurple),
                      ),
                      child: const Text('Continue'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentPurple,
                      ),
                      child: const Text('View Island'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF5D00FF),
              const Color(0xFF86639B),
            ],
          ),
        ),
        child: SafeArea(
          // ✅ FIXED: Use SingleChildScrollView to prevent overflow
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 
                          MediaQuery.of(context).padding.top - 
                          MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                children: [
                  // ✅ FIXED: Reduced header height
                  Container(
                    height: 70, // Reduced from 80
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Pomodoro Timer',
                              style: TextStyle(
                                fontSize: 26, // Slightly smaller
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Structured productivity',
                              style: TextStyle(
                                color: const Color(0xFFC1CEFF),
                                fontSize: 14, // Slightly smaller
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.accentPurple.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white30),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.timer,
                                size: 16,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${_completedSessions.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // ✅ FIXED: Flexible center section instead of Expanded
                  Container(
                    height: MediaQuery.of(context).size.height * 0.65, // Fixed height
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Animated Timer Circle
                          AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _isRunning ? _pulseAnimation.value : 1.0,
                                child: Container(
                                  width: 280, // Slightly smaller
                                  height: 280,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        Colors.white,
                                        _isRunning
                                            ? AppColors.accentPurple.withOpacity(0.2)
                                            : AppColors.accentBlue.withOpacity(0.1),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: (_isRunning
                                                ? AppColors.accentPurple
                                                : AppColors.accentBlue)
                                            .withOpacity(0.3),
                                        blurRadius: _isRunning ? 30 : 15,
                                        spreadRadius: _isRunning ? 10 : 5,
                                      ),
                                    ],
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Progress indicator
                                      SizedBox(
                                        width: 260,
                                        height: 260,
                                        child: CircularProgressIndicator(
                                          value: _seconds > 0
                                              ? ((_selectedMinutes * 60) - _seconds) / (_selectedMinutes * 60)
                                              : 0,
                                          strokeWidth: 8,
                                          backgroundColor: Colors.white24,
                                          valueColor: AlwaysStoppedAnimation(Colors.white),
                                        ),
                                      ),
                                      // Time display
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            _formatTime(_seconds > 0 ? _seconds : _selectedMinutes * 60),
                                            style: const TextStyle(
                                              fontSize: 48, // Slightly smaller
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              shadows: [
                                                Shadow(
                                                  blurRadius: 10,
                                                  color: Colors.black54,
                                                  offset: Offset(2, 2),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          if (_isRunning)
                                            const Text(
                                              'Stay Focused! 🍅',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.white70,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          
                          const SizedBox(height: 30), // Reduced spacing
                          
                          // Timer Options (only when not running)
                          if (!_isRunning && !_isPaused) ...[
                            Text(
                              'Choose Duration',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                shadows: const [
                                  Shadow(
                                    blurRadius: 5,
                                    color: Colors.black45,
                                    offset: Offset(1, 1),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 10,
                                runSpacing: 10,
                                children: _timerOptions.map((minutes) {
                                  final isSelected = _selectedMinutes == minutes;
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() => _selectedMinutes = minutes);
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 18,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppColors.accentPurple
                                            : Colors.white24,
                                        borderRadius: BorderRadius.circular(25),
                                        boxShadow: isSelected
                                            ? [
                                                BoxShadow(
                                                  color: AppColors.accentPurple.withOpacity(0.6),
                                                  blurRadius: 12,
                                                  offset: const Offset(0, 3),
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Text(
                                        '${minutes}m',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: isSelected ? Colors.white : Colors.white70,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                          
                          const SizedBox(height: 30),
                          
                          // Control Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: _buildControlButtons(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // ✅ FIXED: Reduced bottom stats height
                  Container(
                    height: 90, // Reduced from 100
                    margin: const EdgeInsets.all(16), // Reduced margin
                    decoration: BoxDecoration(
                      color: Colors.white30,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white38),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem('🍅', _completedSessions.length.toString(), 'Sessions'),
                        _buildStatItem('⏱️', '${_completedSessions.fold(0, (sum, s) => sum + s.durationMinutes)}', 'Minutes'),
                        _buildStatItem('🪙', '${_completedSessions.length * 10}', 'Coins'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String emoji, String value, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)), // Reduced size
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18, // Reduced size
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildControlButtons() {
    List<Widget> buttons = [];
    
    if (!_isRunning && !_isPaused) {
      buttons.add(
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.accentPurple,
                AppColors.accentBlue,
              ],
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentPurple.withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 3,
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: _startTimer,
            icon: const Icon(Icons.play_arrow, size: 24),
            label: const Text('Start Pomodoro', style: TextStyle(fontSize: 16)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            ),
          ),
        ),
      );
    }
    
    if (_isRunning) {
      buttons.addAll([
        ElevatedButton.icon(
          onPressed: _pauseTimer,
          icon: const Icon(Icons.pause, size: 20),
          label: const Text('Pause'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accentBlue,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: _stopTimer,
          icon: const Icon(Icons.stop, size: 20),
          label: const Text('Stop'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade400,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          ),
        ),
      ]);
    }
    
    if (_isPaused) {
      buttons.addAll([
        ElevatedButton.icon(
          onPressed: _startTimer,
          icon: const Icon(Icons.play_arrow, size: 20),
          label: const Text('Resume'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accentPurple,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: _stopTimer,
          icon: const Icon(Icons.stop, size: 20),
          label: const Text('Stop'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade400,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          ),
        ),
      ]);
    }
    
    return buttons;
  }
}

extension on Object? {
  get shade600 => null;
  
  get shade100 => null;
  
  get shade50 => null;

  operator +(int other) {}
}
