import 'package:flutter/material.dart';
import 'dart:async';
import '../utils/colors.dart';
import '../services/database_helper.dart';
import '../models/focus_session.dart';

class FocusModeScreen extends StatefulWidget {
  const FocusModeScreen({Key? key}) : super(key: key);

  @override
  State<FocusModeScreen> createState() => _FocusModeScreenState();
}

class _FocusModeScreenState extends State<FocusModeScreen> with TickerProviderStateMixin {
  Timer? _timer;
  Duration _totalDuration = const Duration(minutes: 30);
  Duration _remainingDuration = const Duration(minutes: 30);
  bool _isRunning = false;
  bool _isPaused = false;
  List<FocusSession> _focusSessions = [];

  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _loadFocusSessions();
    
    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _glowAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _glowController.dispose();
    super.dispose();
  }

  void _loadFocusSessions() async {
    final sessions = await DatabaseHelper().getFocusSessions();
    setState(() {
      _focusSessions = sessions.where((s) => s.isCompleted).toList();
    });
  }

  void _showTimePicker() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          int hours = _totalDuration.inHours;
          int minutes = (_totalDuration.inMinutes % 60);
          
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Set Focus Duration'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Quick presets
                Text('Quick Presets:', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [15, 30, 45, 60, 90, 120, 180].map((mins) {
                    final isSelected = _totalDuration.inMinutes == mins;
                    return GestureDetector(
                      onTap: () {
                        setDialogState(() {
                          _totalDuration = Duration(minutes: mins);
                          _remainingDuration = _totalDuration;
                          hours = _totalDuration.inHours;
                          minutes = (_totalDuration.inMinutes % 60);
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.accentPurple : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${mins}m',
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                const Text('Or set custom time:', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                
                // Custom time picker
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Hours
                    Column(
                      children: [
                        IconButton(
                          onPressed: () {
                            setDialogState(() {
                              hours = (hours + 1).clamp(0, 23);
                              _totalDuration = Duration(hours: hours, minutes: minutes);
                              _remainingDuration = _totalDuration;
                            });
                          },
                          icon: const Icon(Icons.keyboard_arrow_up),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.accentPurple),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${hours}h',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setDialogState(() {
                              hours = (hours - 1).clamp(0, 23);
                              _totalDuration = Duration(hours: hours, minutes: minutes);
                              _remainingDuration = _totalDuration;
                            });
                          },
                          icon: const Icon(Icons.keyboard_arrow_down),
                        ),
                      ],
                    ),
                    
                    // Minutes
                    Column(
                      children: [
                        IconButton(
                          onPressed: () {
                            setDialogState(() {
                              minutes = (minutes + 5) % 60;
                              _totalDuration = Duration(hours: hours, minutes: minutes);
                              _remainingDuration = _totalDuration;
                            });
                          },
                          icon: const Icon(Icons.keyboard_arrow_up),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.accentPurple),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${minutes}m',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setDialogState(() {
                              minutes = (minutes - 5).clamp(0, 55);
                              _totalDuration = Duration(hours: hours, minutes: minutes);
                              _remainingDuration = _totalDuration;
                            });
                          },
                          icon: const Icon(Icons.keyboard_arrow_down),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _totalDuration = Duration(hours: hours, minutes: minutes);
                    _remainingDuration = _totalDuration;
                  });
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentPurple),
                child: const Text('Set Duration'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
      _isPaused = false;
    });

    _glowController.repeat(reverse: true);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingDuration.inSeconds > 0) {
          _remainingDuration = Duration(seconds: _remainingDuration.inSeconds - 1);
        } else {
          _completeSession();
        }
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    _glowController.stop();
    setState(() {
      _isPaused = true;
      _isRunning = false;
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _glowController.stop();
    _glowController.reset();
    setState(() {
      _isRunning = false;
      _isPaused = false;
      _remainingDuration = _totalDuration;
    });
  }

  void _completeSession() {
    _timer?.cancel();
    _glowController.stop();
    _glowController.reset();
    
    setState(() {
      _isRunning = false;
      _isPaused = false;
      _remainingDuration = _totalDuration;
    });

    final session = FocusSession(
      startTime: DateTime.now().subtract(_totalDuration),
      endTime: DateTime.now(),
      durationMinutes: _totalDuration.inMinutes,
      isCompleted: true,
    );

    DatabaseHelper().insertFocusSession(session);
    _loadFocusSessions();
    _showRewardDialog();
  }

  void _showRewardDialog() {
    final coinsEarned = (_totalDuration.inMinutes * 0.5).round();
    
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
                  Icons.psychology,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '🧠 Deep Focus Complete!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You focused deeply for ${_totalDuration.inMinutes} minutes!\nYour mind grows stronger.',
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
                  '+$coinsEarned Focus Coins Earned! 🔮',
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

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    
    if (duration.inHours > 0) {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    }
    return "$twoDigitMinutes:$twoDigitSeconds";
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
                              'Deep Focus',
                              style: TextStyle(
                                fontSize: 26, // Slightly smaller
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Personalized timing',
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
                                Icons.psychology,
                                size: 16,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${_focusSessions.length}',
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
                  
                  // ✅ FIXED: Fixed height center section
                  Container(
                    height: MediaQuery.of(context).size.height * 0.65,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Animated Timer Circle
                          AnimatedBuilder(
                            animation: _glowAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _isRunning ? _glowAnimation.value : 1.0,
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
                                            : AppColors.accentBlue).withOpacity(0.3),
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
                                          value: (_totalDuration.inSeconds - _remainingDuration.inSeconds) / _totalDuration.inSeconds,
                                          strokeWidth: 8,
                                          backgroundColor: Colors.white24,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      ),
                                      // Time display
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            _formatDuration(_remainingDuration),
                                            style: const TextStyle(
                                              fontSize: 48, // Slightly smaller
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              shadows: [
                                                Shadow(
                                                  blurRadius: 10,
                                                  color: Colors.black45,
                                                  offset: Offset(2, 2),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          if (_isRunning)
                                            const Text(
                                              'Deep Focus Active 🧠',
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
                          
                          const SizedBox(height: 30),
                          
                          // Duration selector
                          if (!_isRunning && !_isPaused) ...[
                            GestureDetector(
                              onTap: _showTimePicker,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(color: Colors.white30),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      'Duration: ${_formatDuration(_totalDuration)}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Tap to customize ⚙️',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          
                          const SizedBox(height: 30),
                          
                          // Control buttons
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
                        _buildStatItem('🧠', _focusSessions.length.toString(), 'Sessions'),
                        _buildStatItem('⏳', '${_focusSessions.fold(0, (sum, s) => sum + s.durationMinutes)}', 'Minutes'),
                        _buildStatItem('🔮', '${(_focusSessions.fold(0, (sum, s) => sum + s.durationMinutes) * 0.5).round()}', 'Focus Coins'),
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
            icon: const Icon(Icons.psychology, size: 24),
            label: const Text('Start Focus', style: TextStyle(fontSize: 16)),
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
  
  get shade50 => null;
  
  get shade100 => null;

  operator +(int other) {}
}
