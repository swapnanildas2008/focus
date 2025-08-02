class IslandItemData {
  final String id;
  final String name;
  final String category; // 'tree', 'stone', 'bird', 'flower'
  final String imageUrl;
  final int requiredSessions;
  final String description;
  final int coins;

  const IslandItemData({
    required this.id,
    required this.name,
    required this.category,
    required this.imageUrl,
    required this.requiredSessions,
    required this.description,
    required this.coins,
  });
}
class IslandData {
  static const List<IslandItemData> trees = [
    IslandItemData(
      id: 'sapling',
      name: 'Tiny Sapling',
      category: 'tree',
      imageUrl: 'https://cdn-icons-png.flaticon.com/512/628/628324.png',
      requiredSessions: 0, // ✅ FIXED: Start from 0 sessions
      description: 'Your first little tree!',
      coins: 5, // ✅ FIXED: Lower coin cost
    ),
    IslandItemData(
      id: 'oak_young',
      name: 'Young Oak',
      category: 'tree',
      imageUrl: 'https://cdn-icons-png.flaticon.com/512/1301/1301866.png',
      requiredSessions: 1, // ✅ FIXED: Lower requirements
      description: 'A growing oak tree',
      coins: 10,
    ),
    IslandItemData(
      id: 'pine_tree',
      name: 'Pine Tree',
      category: 'tree',
      imageUrl: 'https://cdn-icons-png.flaticon.com/512/1301/1301872.png',
      requiredSessions: 2,
      description: 'Majestic pine tree',
      coins: 15,
    ),
    IslandItemData(
      id: 'cherry_blossom',
      name: 'Cherry Blossom',
      category: 'tree',
      imageUrl: 'https://cdn-icons-png.flaticon.com/512/1301/1301869.png',
      requiredSessions: 3,
      description: 'Beautiful flowering tree',
      coins: 20,
    ),
    IslandItemData(
      id: 'ancient_oak',
      name: 'Ancient Oak',
      category: 'tree',
      imageUrl: 'https://cdn-icons-png.flaticon.com/512/1301/1301875.png',
      requiredSessions: 5,
      description: 'Wise old oak tree',
      coins: 30,
    ),
    IslandItemData(
      id: 'mystical_tree',
      name: 'Mystical Tree',
      category: 'tree',
      imageUrl: 'https://cdn-icons-png.flaticon.com/512/1301/1301878.png',
      requiredSessions: 7,
      description: 'Magical glowing tree',
      coins: 50,
    ),
  ];

  static const List<IslandItemData> stones = [
    IslandItemData(
      id: 'small_rock',
      name: 'Small Rock',
      category: 'stone',
      imageUrl: 'https://cdn-icons-png.flaticon.com/512/2290/2290062.png',
      requiredSessions: 0,
      description: 'A simple stone',
      coins: 3,
    ),
    IslandItemData(
      id: 'crystal',
      name: 'Crystal',
      category: 'stone',
      imageUrl: 'https://cdn-icons-png.flaticon.com/512/2290/2290070.png',
      requiredSessions: 2,
      description: 'Sparkling crystal',
      coins: 12,
    ),
    IslandItemData(
      id: 'boulder',
      name: 'Boulder',
      category: 'stone',
      imageUrl: 'https://cdn-icons-png.flaticon.com/512/2290/2290065.png',
      requiredSessions: 4,
      description: 'Large stone boulder',
      coins: 25,
    ),
  ];

  static const List<IslandItemData> birds = [
    IslandItemData(
      id: 'sparrow',
      name: 'Sparrow',
      category: 'bird',
      imageUrl: 'https://cdn-icons-png.flaticon.com/512/3069/3069172.png',
      requiredSessions: 1,
      description: 'Cheerful little sparrow',
      coins: 8,
    ),
    IslandItemData(
      id: 'robin',
      name: 'Robin',
      category: 'bird',
      imageUrl: 'https://cdn-icons-png.flaticon.com/512/3069/3069174.png',
      requiredSessions: 3,
      description: 'Red-breasted robin',
      coins: 18,
    ),
  ];

  static const List<IslandItemData> flowers = [
    IslandItemData(
      id: 'daisy',
      name: 'Daisy',
      category: 'flower',
      imageUrl: 'https://cdn-icons-png.flaticon.com/512/1202/1202779.png',
      requiredSessions: 0,
      description: 'Simple white daisy',
      coins: 4,
    ),
    IslandItemData(
      id: 'rose',
      name: 'Rose',
      category: 'flower',
      imageUrl: 'https://cdn-icons-png.flaticon.com/512/1202/1202781.png',
      requiredSessions: 1,
      description: 'Beautiful red rose',
      coins: 7,
    ),
  ];

  static List<IslandItemData> getAllItems() {
    return [...trees, ...stones, ...birds, ...flowers];
  }

  static List<IslandItemData> getItemsByCategory(String category) {
    switch (category) {
      case 'tree':
        return trees;
      case 'stone':
        return stones;
      case 'bird':
        return birds;
      case 'flower':
        return flowers;
      default:
        return [];
    }
  }
}
