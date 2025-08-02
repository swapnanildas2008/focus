import 'package:flutter/material.dart';
import 'dart:math';
import '../utils/colors.dart';
import '../utils/island_data.dart';
import '../services/database_helper.dart';
import '../models/focus_session.dart';
import '../models/island_item.dart';

class IslandScreen extends StatefulWidget {
  const IslandScreen({Key? key}) : super(key: key);

  @override
  State<IslandScreen> createState() => _IslandScreenState();
}

class _IslandScreenState extends State<IslandScreen> with TickerProviderStateMixin {
  List<FocusSession> _completedSessions = [];
  List<IslandItem> _placedItems = [];
  String _selectedCategory = 'tree';
  bool _isPlacingMode = false;
  IslandItemData? _itemToPlace; // Store the item being placed
  
  late AnimationController _waveController;
  late AnimationController _cloudsController;
  late Animation<double> _waveAnimation;
  late Animation<double> _cloudsAnimation;

  @override
  void initState() {
    super.initState();
    _loadData();
    
    _waveController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    _cloudsController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _waveAnimation = Tween<double>(
      begin: 0,
      end: 2 * pi,
    ).animate(_waveController);
    
    _cloudsAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_cloudsController);
  }

  @override
  void dispose() {
    _waveController.dispose();
    _cloudsController.dispose();
    super.dispose();
  }

  void _loadData() async {
    final sessions = await DatabaseHelper().getFocusSessions();
    setState(() {
      _completedSessions = sessions.where((s) => s.isCompleted).toList();
    });
  }

  int get _totalCoins => _completedSessions.length * 10;

  List<IslandItemData> get _availableItems {
    final totalSessions = _completedSessions.length;
    return IslandData.getItemsByCategory(_selectedCategory)
        .where((item) => item.requiredSessions <= totalSessions)
        .toList();
  }

// In your IslandScreen, update the _showItemShop method:

void _showItemShop() async {
  print('🛒 Opening shop...');
  print('Total sessions: ${_completedSessions.length}');
  print('Total coins: $_totalCoins');
  print('Selected category: $_selectedCategory');
  print('Available items: ${_availableItems.length}');
  
  final result = await showModalBottomSheet<IslandItemData>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => StatefulBuilder(
      builder: (BuildContext context, StateSetter setModalState) {
        // ✅ FIXED: Recalculate available items in modal
        final totalSessions = _completedSessions.length;
        final availableItems = IslandData.getItemsByCategory(_selectedCategory)
            .where((item) => item.requiredSessions <= totalSessions)
            .toList();
        
        print('Modal available items: ${availableItems.length}');
        
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header with debug info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.forestGreen.shade400,
                      AppColors.forestGreen.shade600,
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '🏪 Island Shop',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.accentOrange,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.monetization_on, color: Colors.white, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '$_totalCoins',
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
                    // ✅ DEBUG: Show session count
                    Text(
                      'Sessions: ${_completedSessions.length} | Items: ${availableItems.length}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Category tabs
              Container(
                height: 60,
                child: Row(
                  children: ['tree', 'stone', 'bird', 'flower'].map((category) {
                    final isSelected = _selectedCategory == category;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          print('Switching to category: $category');
                          setModalState(() {
                            _selectedCategory = category;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.accentOrange.withOpacity(0.1) : null,
                            border: Border(
                              bottom: BorderSide(
                                color: isSelected ? AppColors.accentOrange : Colors.transparent,
                                width: 3,
                              ),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _getCategoryEmoji(category),
                                style: const TextStyle(fontSize: 20),
                              ),
                              Text(
                                category.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? AppColors.accentOrange : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              
              // Items grid with fallback
              Expanded(
                child: availableItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '🎯',
                              style: TextStyle(fontSize: 48),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Complete focus sessions\nto unlock items!',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.forestGreen.shade600,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Sessions needed: ${_getNextRequiredSessions()}',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.forestGreen.shade400,
                              ),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: availableItems.length,
                        itemBuilder: (context, index) {
                          final item = availableItems[index];
                          final canAfford = _totalCoins >= item.coins;
                          
                          return GestureDetector(
                            onTap: canAfford ? () {
                              print('Purchasing: ${item.name}');
                              Navigator.pop(context, item);
                            } : () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Need ${item.coins - _totalCoins} more coins!'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: canAfford ? Colors.white : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: canAfford ? AppColors.forestGreen.shade200 : Colors.grey.shade300,
                                  width: canAfford ? 2 : 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: canAfford 
                                        ? AppColors.forestGreen.withOpacity(0.1)
                                        : Colors.grey.withOpacity(0.1),
                                    blurRadius: 5,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    child: Image.network(
                                      item.imageUrl,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return const Center(
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        );
                                      },
                                      errorBuilder: (context, error, stackTrace) {
                                        print('Image error for ${item.name}: $error');
                                        return Container(
                                          decoration: BoxDecoration(
                                            color: AppColors.forestGreen.shade100,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Center(
                                            child: Text(
                                              _getCategoryEmoji(item.category), 
                                              style: const TextStyle(fontSize: 40),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    item.name,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: canAfford ? AppColors.forestGreen.shade700 : Colors.grey,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.description,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade600,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: canAfford ? AppColors.accentOrange : Colors.grey,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.monetization_on, color: Colors.white, size: 12),
                                        const SizedBox(width: 2),
                                        Text(
                                          '${item.coins}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    ),
  );
  
  if (result != null) {
    _purchaseItem(result);
  }
}

// ✅ Helper method to show next unlock requirement
int _getNextRequiredSessions() {
  final allItems = IslandData.getItemsByCategory(_selectedCategory);
  final currentSessions = _completedSessions.length;
  
  for (final item in allItems) {
    if (item.requiredSessions > currentSessions) {
      return item.requiredSessions;
    }
  }
  return 1; // Default to 1 if all items are unlocked
}

  String _getCategoryEmoji(String category) {
    switch (category) {
      case 'tree': return '🌳';
      case 'stone': return '🪨';
      case 'bird': return '🐦';
      case 'flower': return '🌸';
      default: return '❓';
    }
  }

  // ✅ FIXED: Simplified purchase process
  void _purchaseItem(IslandItemData item) {
    setState(() {
      _itemToPlace = item;
      _isPlacingMode = true;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tap anywhere on the island to place your ${item.name}'),
        backgroundColor: AppColors.accentOrange,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Cancel',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              _isPlacingMode = false;
              _itemToPlace = null;
            });
          },
        ),
      ),
    );
  }

  void _placeItem(Offset position) {
    if (_itemToPlace == null) return;
    
    // Convert screen position to relative position
    final relativeX = position.dx / MediaQuery.of(context).size.width;
    final relativeY = position.dy / MediaQuery.of(context).size.height;
    
    final islandItem = IslandItem(
      itemId: _itemToPlace!.id,
      category: _itemToPlace!.category,
      positionX: relativeX,
      positionY: relativeY,
      placedAt: DateTime.now(),
    );
    
    setState(() {
      _placedItems.add(islandItem);
      _isPlacingMode = false;
      _itemToPlace = null;
      // Deduct coins here if needed
    });
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_itemToPlace!.name} placed successfully! 🎉'),
        backgroundColor: AppColors.forestGreen,
        duration: const Duration(seconds: 2),
      ),
    );
    
    // Save to database (implement this)
    // DatabaseHelper().insertIslandItem(islandItem);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF87CEEB), // Sky blue
                  const Color(0xFF98D8E8), // Light blue
                  const Color(0xFF06B6D4), // Cyan
                ],
              ),
            ),
          ),
          
          // Animated Clouds
          AnimatedBuilder(
            animation: _cloudsAnimation,
            builder: (context, child) {
              return Positioned(
                left: -100 + (_cloudsAnimation.value * MediaQuery.of(context).size.width * 1.5),
                top: 50,
                child: Container(
                  width: 80,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              );
            },
          ),
          
          // More clouds at different positions
          AnimatedBuilder(
            animation: _cloudsAnimation,
            builder: (context, child) {
              return Positioned(
                right: -50 + (_cloudsAnimation.value * MediaQuery.of(context).size.width * 0.8),
                top: 100,
                child: Container(
                  width: 60,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              );
            },
          ),
          
          // Island Base
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: MediaQuery.of(context).size.height * 0.7,
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.5,
                  colors: [
                    const Color(0xFF90EE90), // Light green
                    const Color(0xFF228B22), // Forest green
                    const Color(0xFF006400), // Dark green
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.elliptical(200, 100),
                ),
              ),
            ),
          ),
          
          // Animated Water Waves
          Positioned(
            left: 0,
            right: 0,
            bottom: MediaQuery.of(context).size.height * 0.7 - 10,
            height: 20,
            child: AnimatedBuilder(
              animation: _waveAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: WavePainter(_waveAnimation.value),
                  size: Size(MediaQuery.of(context).size.width, 20),
                );
              },
            ),
          ),
          
          // Placed Items
          ..._placedItems.map((placedItem) {
            final itemData = IslandData.getAllItems()
                .firstWhere((item) => item.id == placedItem.itemId);
            
            return Positioned(
              left: placedItem.positionX * MediaQuery.of(context).size.width - 25,
              top: placedItem.positionY * MediaQuery.of(context).size.height - 25,
              child: GestureDetector(
                onTap: () {
                  // Show item info
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${itemData.name}: ${itemData.description}'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: Container(
                  width: 50,
                  height: 50,
                  child: Image.network(
                    itemData.imageUrl,
                    errorBuilder: (context, error, stackTrace) => 
                      Text(_getCategoryEmoji(itemData.category), style: const TextStyle(fontSize: 30)),
                  ),
                ),
              ),
            );
          }).toList(),
          
          // ✅ FIXED: Island interaction overlay
          if (_isPlacingMode)
            Positioned.fill(
              child: GestureDetector(
                onTapDown: (details) {
                  // Only allow placement on the island area (bottom 70% of screen)
                  if (details.globalPosition.dy > MediaQuery.of(context).size.height * 0.3) {
                    _placeItem(details.globalPosition);
                  }
                },
                child: Container(
                  color: Colors.black.withOpacity(0.2),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_itemToPlace != null) ...[
                            Container(
                              width: 60,
                              height: 60,
                              child: Image.network(
                                _itemToPlace!.imageUrl,
                                errorBuilder: (context, error, stackTrace) => 
                                  Text(_getCategoryEmoji(_itemToPlace!.category), style: const TextStyle(fontSize: 40)),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          const Text(
                            'Tap anywhere on the island\nto place your item',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          
          // Header
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '🏝️ My Island',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${_placedItems.length} items placed',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.accentOrange,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.monetization_on, color: Colors.white, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          '$_totalCoins',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showItemShop,
        backgroundColor: AppColors.accentOrange,
        icon: const Icon(Icons.shopping_cart),
        label: const Text('Shop'),
      ),
    );
  }
}

// Keep the WavePainter class the same
class WavePainter extends CustomPainter {
  final double animationValue;

  WavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4FC3F7)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height / 2);

    for (double x = 0; x <= size.width; x += 1) {
      final y = size.height / 2 + 5 * sin((x / 50) + animationValue);
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
