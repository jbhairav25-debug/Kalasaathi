class Artisan {
  final String id;
  final String name;
  final String location;
  final String state;
  final String craftSpecialization;
  final String bio;
  final int totalProducts;
  final int totalOrders;
  final double totalSales;
  final double rating;
  final String preferredLanguage;
  final String avatarEmoji;
  final List<String> craftsOffered;
  final DateTime joinedDate;

  const Artisan({
    required this.id,
    required this.name,
    required this.location,
    required this.state,
    required this.craftSpecialization,
    required this.bio,
    required this.totalProducts,
    required this.totalOrders,
    required this.totalSales,
    required this.rating,
    required this.preferredLanguage,
    required this.avatarEmoji,
    required this.craftsOffered,
    required this.joinedDate,
  });

  Artisan copyWith({
    String? id,
    String? name,
    String? location,
    String? state,
    String? craftSpecialization,
    String? bio,
    int? totalProducts,
    int? totalOrders,
    double? totalSales,
    double? rating,
    String? preferredLanguage,
    String? avatarEmoji,
    List<String>? craftsOffered,
    DateTime? joinedDate,
  }) {
    return Artisan(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      state: state ?? this.state,
      craftSpecialization: craftSpecialization ?? this.craftSpecialization,
      bio: bio ?? this.bio,
      totalProducts: totalProducts ?? this.totalProducts,
      totalOrders: totalOrders ?? this.totalOrders,
      totalSales: totalSales ?? this.totalSales,
      rating: rating ?? this.rating,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      avatarEmoji: avatarEmoji ?? this.avatarEmoji,
      craftsOffered: craftsOffered ?? this.craftsOffered,
      joinedDate: joinedDate ?? this.joinedDate,
    );
  }
}
