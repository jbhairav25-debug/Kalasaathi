import 'package:uuid/uuid.dart';

enum ProductStatus { draft, published, archived }
enum ProductCategory {
  handicrafts,
  textiles,
  pottery,
  leather,
  woodcraft,
  organic,
  homeDecor,
}

extension ProductCategoryExtension on ProductCategory {
  String get displayName {
    switch (this) {
      case ProductCategory.handicrafts: return 'Handicrafts';
      case ProductCategory.textiles: return 'Textiles';
      case ProductCategory.pottery: return 'Pottery';
      case ProductCategory.leather: return 'Leather';
      case ProductCategory.woodcraft: return 'Woodcraft';
      case ProductCategory.organic: return 'Organic Products';
      case ProductCategory.homeDecor: return 'Home Decor';
    }
  }

  String get emoji {
    switch (this) {
      case ProductCategory.handicrafts: return '🧺';
      case ProductCategory.textiles: return '🧵';
      case ProductCategory.pottery: return '🏺';
      case ProductCategory.leather: return '👜';
      case ProductCategory.woodcraft: return '🪵';
      case ProductCategory.organic: return '🌿';
      case ProductCategory.homeDecor: return '🏮';
    }
  }
}

class Product {
  final String id;
  final String name;
  final String artisanId;
  final String artisanName;
  final String artisanLocation;
  final String description;
  final String material;
  final ProductCategory category;
  final double price;
  final double minPrice;
  final double maxPrice;
  final List<String> tags;
  final double rating;
  final int reviewCount;
  final int stock;
  final ProductStatus status;
  final String imagePath; // For mock: emoji/color identifier
  final String imageEmoji;
  final bool isNew;
  final bool isAIEnhanced;
  final DateTime createdAt;

  const Product({
    required this.id,
    required this.name,
    required this.artisanId,
    required this.artisanName,
    required this.artisanLocation,
    required this.description,
    required this.material,
    required this.category,
    required this.price,
    required this.minPrice,
    required this.maxPrice,
    required this.tags,
    required this.rating,
    required this.reviewCount,
    required this.stock,
    required this.status,
    required this.imagePath,
    required this.imageEmoji,
    this.isNew = false,
    this.isAIEnhanced = false,
    required this.createdAt,
  });

  Product copyWith({
    String? id,
    String? name,
    String? artisanId,
    String? artisanName,
    String? artisanLocation,
    String? description,
    String? material,
    ProductCategory? category,
    double? price,
    double? minPrice,
    double? maxPrice,
    List<String>? tags,
    double? rating,
    int? reviewCount,
    int? stock,
    ProductStatus? status,
    String? imagePath,
    String? imageEmoji,
    bool? isNew,
    bool? isAIEnhanced,
    DateTime? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      artisanId: artisanId ?? this.artisanId,
      artisanName: artisanName ?? this.artisanName,
      artisanLocation: artisanLocation ?? this.artisanLocation,
      description: description ?? this.description,
      material: material ?? this.material,
      category: category ?? this.category,
      price: price ?? this.price,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      tags: tags ?? this.tags,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      stock: stock ?? this.stock,
      status: status ?? this.status,
      imagePath: imagePath ?? this.imagePath,
      imageEmoji: imageEmoji ?? this.imageEmoji,
      isNew: isNew ?? this.isNew,
      isAIEnhanced: isAIEnhanced ?? this.isAIEnhanced,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static String generateId() => const Uuid().v4();
}
