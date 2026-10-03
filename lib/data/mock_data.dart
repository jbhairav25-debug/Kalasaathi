import '../models/product.dart';
import '../models/order.dart';
import '../models/artisan.dart';

class MockData {
  // === Current Artisan Profile ===
  static Artisan currentArtisan = Artisan(
    id: 'artisan_001',
    name: 'Lakshmi Devi',
    location: 'Warangal',
    state: 'Telangana',
    craftSpecialization: 'Bamboo & Cane Crafts',
    bio:
        'Skilled artisan with 15 years of experience in traditional bamboo weaving. Preserving ancient craft traditions of Telangana.',
    totalProducts: 12,
    totalOrders: 47,
    totalSales: 38500,
    rating: 4.7,
    preferredLanguage: 'Telugu',
    avatarEmoji: '👩‍🎨',
    craftsOffered: [
      'Bamboo Baskets',
      'Cane Furniture',
      'Wall Hangings',
      'Storage Units',
    ],
    joinedDate: DateTime(2023, 3, 15),
  );

  // === My Products (artisan's own) ===
  static List<Product> myProducts = [
    Product(
      id: 'prod_001',
      name: 'Traditional Bamboo Basket',
      artisanId: 'artisan_001',
      artisanName: 'Lakshmi Devi',
      artisanLocation: 'Warangal, Telangana',
      description:
          'A traditional handwoven bamboo basket crafted by skilled artisans using natural bamboo and traditional weaving techniques. Lightweight, durable and eco-friendly, making it suitable for storage, home decoration and gifting.',
      material: 'Bamboo',
      category: ProductCategory.handicrafts,
      price: 800,
      minPrice: 750,
      maxPrice: 850,
      tags: ['Handmade', 'Bamboo', 'Eco-friendly', 'Traditional', 'Handcrafted'],
      rating: 4.8,
      reviewCount: 23,
      stock: 10,
      status: ProductStatus.published,
      imagePath: 'basket',
      imageEmoji: '🧺',
      isAIEnhanced: true,
      createdAt: DateTime(2024, 6, 10),
    ),
    Product(
      id: 'prod_002',
      name: 'Decorative Cane Wall Hanging',
      artisanId: 'artisan_001',
      artisanName: 'Lakshmi Devi',
      artisanLocation: 'Warangal, Telangana',
      description:
          'Exquisitely crafted cane wall hanging that adds a rustic charm to any space. Hand-woven using sustainable cane with intricate geometric patterns inspired by Telangana folk art.',
      material: 'Cane',
      category: ProductCategory.homeDecor,
      price: 1200,
      minPrice: 1100,
      maxPrice: 1350,
      tags: ['Handmade', 'Cane', 'Wall Art', 'Traditional', 'Folk Art'],
      rating: 4.6,
      reviewCount: 15,
      stock: 5,
      status: ProductStatus.published,
      imagePath: 'wallhanging',
      imageEmoji: '🎋',
      isAIEnhanced: true,
      createdAt: DateTime(2024, 7, 22),
    ),
    Product(
      id: 'prod_003',
      name: 'Bamboo Fruit Tray',
      artisanId: 'artisan_001',
      artisanName: 'Lakshmi Devi',
      artisanLocation: 'Warangal, Telangana',
      description:
          'Hand-crafted bamboo fruit tray, perfect for kitchen and dining use. Made from high-quality natural bamboo strips woven in a traditional pattern.',
      material: 'Bamboo',
      category: ProductCategory.handicrafts,
      price: 450,
      minPrice: 400,
      maxPrice: 500,
      tags: ['Bamboo', 'Kitchen', 'Eco-friendly', 'Handmade'],
      rating: 4.5,
      reviewCount: 8,
      stock: 15,
      status: ProductStatus.draft,
      imagePath: 'tray',
      imageEmoji: '🍽️',
      isAIEnhanced: false,
      createdAt: DateTime(2024, 9, 1),
    ),
  ];

  // === Marketplace Products ===
  static List<Product> marketplaceProducts = [
    Product(
      id: 'mkt_001',
      name: 'Traditional Bamboo Basket',
      artisanId: 'artisan_001',
      artisanName: 'Lakshmi Devi',
      artisanLocation: 'Warangal, Telangana',
      description:
          'A traditional handwoven bamboo basket crafted by skilled artisans using natural bamboo and traditional weaving techniques.',
      material: 'Bamboo',
      category: ProductCategory.handicrafts,
      price: 800,
      minPrice: 750,
      maxPrice: 850,
      tags: ['Handmade', 'Bamboo', 'Eco-friendly', 'Traditional'],
      rating: 4.8,
      reviewCount: 23,
      stock: 10,
      status: ProductStatus.published,
      imagePath: 'basket',
      imageEmoji: '🧺',
      isAIEnhanced: true,
      createdAt: DateTime(2024, 6, 10),
    ),
    Product(
      id: 'mkt_002',
      name: 'Handwoven Cotton Saree',
      artisanId: 'artisan_002',
      artisanName: 'Meera Weaver',
      artisanLocation: 'Kanchipuram, Tamil Nadu',
      description:
          'Pure handwoven cotton saree in traditional Kanchipuram style with intricate zari border work. Each saree is a unique work of art taking 3-4 days to complete.',
      material: 'Cotton, Zari',
      category: ProductCategory.textiles,
      price: 3500,
      minPrice: 3200,
      maxPrice: 3800,
      tags: ['Handwoven', 'Cotton', 'Traditional', 'Kanchipuram', 'Zari'],
      rating: 4.9,
      reviewCount: 42,
      stock: 3,
      status: ProductStatus.published,
      imagePath: 'saree',
      imageEmoji: '👘',
      isAIEnhanced: true,
      createdAt: DateTime(2024, 5, 20),
    ),
    Product(
      id: 'mkt_003',
      name: 'Handmade Leather Bag',
      artisanId: 'artisan_003',
      artisanName: 'Raju Leather Works',
      artisanLocation: 'Dharavi, Mumbai',
      description:
          'Genuine leather shoulder bag handcrafted by expert leather artisans. Features traditional embossed patterns with modern functionality.',
      material: 'Genuine Leather',
      category: ProductCategory.leather,
      price: 2200,
      minPrice: 2000,
      maxPrice: 2500,
      tags: ['Leather', 'Handmade', 'Bag', 'Traditional', 'Durable'],
      rating: 4.7,
      reviewCount: 31,
      stock: 7,
      status: ProductStatus.published,
      imagePath: 'bag',
      imageEmoji: '👜',
      isAIEnhanced: true,
      createdAt: DateTime(2024, 4, 15),
    ),
    Product(
      id: 'mkt_004',
      name: 'Terracotta Vase',
      artisanId: 'artisan_004',
      artisanName: 'Pottery Masters',
      artisanLocation: 'Khurja, Uttar Pradesh',
      description:
          'Hand-painted terracotta vase with traditional Khurja pottery patterns. Each piece is kiln-fired and hand-decorated with natural mineral colours.',
      material: 'Terracotta, Natural Pigments',
      category: ProductCategory.pottery,
      price: 650,
      minPrice: 600,
      maxPrice: 750,
      tags: ['Terracotta', 'Pottery', 'Handpainted', 'Home Decor'],
      rating: 4.5,
      reviewCount: 19,
      stock: 12,
      status: ProductStatus.published,
      imagePath: 'vase',
      imageEmoji: '🏺',
      isAIEnhanced: false,
      createdAt: DateTime(2024, 3, 8),
    ),
    Product(
      id: 'mkt_005',
      name: 'Wooden Elephant Sculpture',
      artisanId: 'artisan_005',
      artisanName: 'Chandra Wood Arts',
      artisanLocation: 'Saharanpur, Uttar Pradesh',
      description:
          'Intricately carved wooden elephant sculpture in traditional Saharanpur style. Hand-carved from seasoned mango wood and finished with natural lacquer.',
      material: 'Mango Wood',
      category: ProductCategory.woodcraft,
      price: 1800,
      minPrice: 1600,
      maxPrice: 2000,
      tags: ['Wood', 'Carving', 'Elephant', 'Traditional', 'Home Decor'],
      rating: 4.8,
      reviewCount: 27,
      stock: 6,
      status: ProductStatus.published,
      imagePath: 'elephant',
      imageEmoji: '🐘',
      isAIEnhanced: true,
      createdAt: DateTime(2024, 6, 5),
    ),
    Product(
      id: 'mkt_006',
      name: 'Jute Shopping Bag',
      artisanId: 'artisan_006',
      artisanName: 'Bengal Craft Guild',
      artisanLocation: 'Kolkata, West Bengal',
      description:
          'Eco-friendly jute shopping bag with hand-embroidered motifs. Strong, reusable, and biodegradable — a sustainable alternative to plastic bags.',
      material: 'Natural Jute, Cotton Thread',
      category: ProductCategory.handicrafts,
      price: 380,
      minPrice: 350,
      maxPrice: 420,
      tags: ['Jute', 'Eco-friendly', 'Reusable', 'Embroidered', 'Sustainable'],
      rating: 4.3,
      reviewCount: 56,
      stock: 25,
      status: ProductStatus.published,
      imagePath: 'jute',
      imageEmoji: '🛍️',
      isAIEnhanced: false,
      createdAt: DateTime(2024, 2, 14),
    ),
    Product(
      id: 'mkt_007',
      name: 'Organic Handmade Soap',
      artisanId: 'artisan_007',
      artisanName: 'Himalayan Naturals',
      artisanLocation: 'Dehradun, Uttarakhand',
      description:
          'Cold-pressed handmade soap with organic ingredients from Himalayan herbs. Free from chemicals, parabens and synthetic fragrances.',
      material: 'Coconut Oil, Himalayan Herbs',
      category: ProductCategory.organic,
      price: 280,
      minPrice: 250,
      maxPrice: 320,
      tags: ['Organic', 'Handmade', 'Natural', 'Soap', 'Himalayan'],
      rating: 4.6,
      reviewCount: 88,
      stock: 40,
      status: ProductStatus.published,
      imagePath: 'soap',
      imageEmoji: '🧼',
      isAIEnhanced: false,
      createdAt: DateTime(2024, 1, 22),
    ),
    Product(
      id: 'mkt_008',
      name: 'Rajasthani Wall Hanging',
      artisanId: 'artisan_008',
      artisanName: 'Desert Craft Studio',
      artisanLocation: 'Jaipur, Rajasthan',
      description:
          'Vibrant Rajasthani wall hanging with traditional mirror work and colorful embroidery. Handcrafted by skilled women artisans from rural Rajasthan.',
      material: 'Cotton, Mirrors, Threads',
      category: ProductCategory.homeDecor,
      price: 1450,
      minPrice: 1300,
      maxPrice: 1600,
      tags: ['Rajasthani', 'Mirror Work', 'Embroidery', 'Traditional', 'Colorful'],
      rating: 4.9,
      reviewCount: 34,
      stock: 8,
      status: ProductStatus.published,
      imagePath: 'wallhanging2',
      imageEmoji: '🎨',
      isAIEnhanced: true,
      createdAt: DateTime(2024, 7, 12),
    ),
  ];

  // === Orders ===
  static List<Order> myOrders = [
    Order(
      orderId: 'KS-2024-001',
      productId: 'mkt_001',
      productName: 'Traditional Bamboo Basket',
      productEmoji: '🧺',
      buyerName: 'Priya Sharma',
      buyerLocation: 'Hyderabad',
      quantity: 2,
      amount: 1600,
      orderDate: DateTime(2024, 9, 18),
      status: OrderStatus.delivered,
    ),
    Order(
      orderId: 'KS-2024-002',
      productId: 'mkt_002',
      productName: 'Decorative Cane Wall Hanging',
      productEmoji: '🎋',
      buyerName: 'Arjun Mehta',
      buyerLocation: 'Bengaluru',
      quantity: 1,
      amount: 1200,
      orderDate: DateTime(2024, 9, 20),
      status: OrderStatus.shipped,
    ),
    Order(
      orderId: 'KS-2024-003',
      productId: 'mkt_001',
      productName: 'Traditional Bamboo Basket',
      productEmoji: '🧺',
      buyerName: 'Sunita Reddy',
      buyerLocation: 'Chennai',
      quantity: 3,
      amount: 2400,
      orderDate: DateTime(2024, 9, 22),
      status: OrderStatus.confirmed,
    ),
    Order(
      orderId: 'KS-2024-004',
      productId: 'mkt_003',
      productName: 'Bamboo Fruit Tray',
      productEmoji: '🍽️',
      buyerName: 'Rajesh Kumar',
      buyerLocation: 'Mumbai',
      quantity: 1,
      amount: 450,
      orderDate: DateTime(2024, 9, 22),
      status: OrderStatus.pending,
    ),
  ];

  // === Sample Crafts for Instant Demo ===
  static List<Map<String, dynamic>> sampleCrafts = [
    {
      'key': 'basket',
      'emoji': '🧺',
      'name': 'Traditional Bamboo Basket',
      'region': 'Warangal, Telangana',
      'material': 'Forest Bamboo',
      'defaultLang': 'te',
      'materialCost': 250.0,
      'workHours': 4.0,
      'hourlyWage': 100.0,
      'packagingCost': 30.0,
      'recommendedPrice': 800.0,
    },
    {
      'key': 'pot',
      'emoji': '🏺',
      'name': 'Terracotta Folk Art Vase',
      'region': 'Khurja, Uttar Pradesh',
      'material': 'Mineral Terracotta',
      'defaultLang': 'hi',
      'materialCost': 180.0,
      'workHours': 3.5,
      'hourlyWage': 90.0,
      'packagingCost': 45.0,
      'recommendedPrice': 650.0,
    },
    {
      'key': 'saree',
      'emoji': '🥻',
      'name': 'Pochampally Ikat Silk Saree',
      'region': 'Pochampally, Telangana',
      'material': 'Mulberry Silk, Natural Zari',
      'defaultLang': 'te',
      'materialCost': 1800.0,
      'workHours': 12.0,
      'hourlyWage': 120.0,
      'packagingCost': 80.0,
      'recommendedPrice': 3800.0,
    },
    {
      'key': 'toy',
      'emoji': '🪵',
      'name': 'Channapatna Lacquer Toy',
      'region': 'Channapatna, Karnataka',
      'material': 'Wrightia Tinctoria Wood',
      'defaultLang': 'kn',
      'materialCost': 220.0,
      'workHours': 3.0,
      'hourlyWage': 100.0,
      'packagingCost': 25.0,
      'recommendedPrice': 600.0,
    },
  ];

  // === AI Catalogue Templates ===
  static Map<String, Map<String, dynamic>> catalogueTemplates = {
    'basket': {
      'name': 'Traditional Handwoven Bamboo Basket',
      'category': ProductCategory.handicrafts,
      'material': 'Forest Bamboo',
      'description':
          'A traditional handwoven bamboo basket crafted by skilled artisans using natural bamboo and age-old weaving techniques. Lightweight, durable, and 100% biodegradable. Perfect for storage, kitchen, and festive gifting.',
      'tags': ['Handmade', 'Bamboo', 'Eco-friendly', 'Traditional', 'TelanganaCraft'],
    },
    'pot': {
      'name': 'Handcrafted Terracotta Folk Art Vase',
      'category': ProductCategory.pottery,
      'material': 'Terracotta Clay & Natural Pigments',
      'description':
          'Kiln-fired terracotta vase hand-painted with ancient rural motifs. Crafted using mineral-rich clay shaped on a potter’s wheel and decorated with natural earth colors.',
      'tags': ['Terracotta', 'Handpainted', 'Pottery', 'FolkArt', 'EcoHome'],
    },
    'saree': {
      'name': 'Authentic Pochampally Ikat Silk Saree',
      'category': ProductCategory.textiles,
      'material': 'Pure Mulberry Silk & Zari',
      'description':
          'GI-tagged handwoven Pochampally Ikat silk saree crafted with geometric tie-dye precision. Woven on traditional pit looms over 12 days by master weavers of Telangana.',
      'tags': ['Handloom', 'PochampallyIkat', 'PureSilk', 'GITagged', 'HeritageWeave'],
    },
    'cloth': {
      'name': 'Handwoven Ethnic Cotton Fabric',
      'category': ProductCategory.textiles,
      'material': 'Pure Desi Cotton',
      'description':
          'Authentic handwoven cotton fabric made on traditional pit looms. Each metre tells a story of generational craftsmanship and breathable natural comfort.',
      'tags': ['Handwoven', 'Cotton', 'Traditional', 'Ethnic', 'NaturalDyes'],
    },
    'toy': {
      'name': 'Handcrafted Channapatna Lacquer Wooden Toy',
      'category': ProductCategory.woodcraft,
      'material': 'Hale Wood & Vegetable Dyes',
      'description':
          'Traditional GI-protected wooden toy from Channapatna, Karnataka. Hand-turned on a lathe and buffed with natural lacquer made from vegetable and mineral dyes. 100% child-safe and non-toxic.',
      'tags': ['ChannapatnaToys', 'ChildSafe', 'WoodenToy', 'GITagged', 'LacquerCraft'],
    },
    'default': {
      'name': 'Traditional Handcrafted Artisan Product',
      'category': ProductCategory.handicrafts,
      'material': 'Natural Materials',
      'description':
          'A beautiful handcrafted product made with traditional techniques and sustainable natural materials. Each piece is unique and directly supports marginalized rural artisans.',
      'tags': ['Handmade', 'Traditional', 'ArtisanEmpowered', 'EcoFriendly'],
    },
  };

  // === Mock Comparable Prices ===
  static List<double> getComparablePrices(double costFloor) {
    return [
      (costFloor * 1.25).roundToDouble(),
      (costFloor * 1.45).roundToDouble(),
      (costFloor * 1.65).roundToDouble(),
      (costFloor * 1.85).roundToDouble(),
    ];
  }

  // === Languages ===
  static List<Map<String, String>> supportedLanguages = [
    {'code': 'te', 'name': 'Telugu', 'flag': '🇮🇳'},
    {'code': 'hi', 'name': 'Hindi', 'flag': '🇮🇳'},
    {'code': 'ta', 'name': 'Tamil', 'flag': '🇮🇳'},
    {'code': 'kn', 'name': 'Kannada', 'flag': '🇮🇳'},
    {'code': 'en', 'name': 'English', 'flag': '🇬🇧'},
  ];

  // === Mock Voice Transcriptions by Craft & Language ===
  static Map<String, String> getVoiceTranscription(String craftKey, String langCode) {
    final Map<String, Map<String, Map<String, String>>> data = {
      'basket': {
        'te': {
          'original': 'ఇది చేతితో తయారు చేసిన వెదురు బుట్ట. అడవి వెదురుతో చేసినది, చాలా దృఢంగా ఉంటుంది.',
          'translation': 'This is a handwoven bamboo basket made from natural forest bamboo. Very sturdy, durable and eco-friendly.',
        },
        'hi': {
          'original': 'यह हाथ से बनी पारंपरिक बांस की टोकरी है। पर्यावरण के अनुकूल और बहुत मजबूत है।',
          'translation': 'This is a traditional handwoven bamboo basket. Eco-friendly, lightweight and very sturdy.',
        },
        'ta': {
          'original': 'இது கையால் செய்யப்பட்ட மூங்கில் கூடை. இயற்கையானது மற்றும் மிகவும் உறுதியானது.',
          'translation': 'This is a handwoven bamboo basket made from natural bamboo. Highly durable and eco-friendly.',
        },
        'kn': {
          'original': 'ಇದು ಕೈಯಿಂದ ನೇಯ್ದ ನೈಸರ್ಗಿಕ ಬಿದಿರಿನ ಬುಟ್ಟಿ. ತುಂಬಾ ಗಟ್ಟಿಮುಟ್ಟಾಗಿದೆ.',
          'translation': 'This is a naturally handwoven bamboo basket. Very sturdy, lightweight and eco-friendly.',
        },
        'en': {
          'original': 'This is a traditional handwoven bamboo basket made with natural materials. Very sturdy and eco-friendly.',
          'translation': 'This is a traditional handwoven bamboo basket made with natural materials. Very sturdy and eco-friendly.',
        },
      },
      'pot': {
        'hi': {
          'original': 'यह चाक पर बना मिट्टी का नक्काशीदार फूलदान है। प्राकृतिक रंगों से सजाया गया है।',
          'translation': 'This is a wheel-thrown terracotta vase hand-painted with traditional mineral pigments.',
        },
        'te': {
          'original': 'ఇది కుమ్మరి చక్రంపై చేసిన మట్టి కుండ. సహజ రంగులతో చిత్రాలు వేసాము.',
          'translation': 'This is a terracotta vase shaped on a potter’s wheel and painted with natural mineral colors.',
        },
        'ta': {
          'original': 'இது சக்கரத்தால் செய்யப்பட்ட களிமண் பூந்தொட்டி. பாரம்பரிய வண்ணங்களால் வரையப்பட்டது.',
          'translation': 'This is a wheel-thrown clay vase decorated with traditional folk art motifs.',
        },
        'kn': {
          'original': 'ಇದು ಮಣ್ಣಿನಿಂದ ಮಾಡಿದ ಸುಂದರ ಹೂದಾನಿ. ನೈಸರ್ಗಿಕ ಬಣ್ಣಗಳಿಂದ ಕಲಾತ್ಮಕವಾಗಿ ಅಲಂಕರಿಸಲಾಗಿದೆ.',
          'translation': 'This is a handcrafted terracotta flower vase painted with traditional folk art.',
        },
        'en': {
          'original': 'This is a wheel-thrown terracotta vase decorated with natural folk art colors.',
          'translation': 'This is a wheel-thrown terracotta vase decorated with natural folk art colors.',
        },
      },
      'saree': {
        'te': {
          'original': 'ఇది అసలైన పోచంపల్లి ఇక్కత్ పట్టు చీర. మగ్గంపై 12 రోజులు కష్టపడి నేసినది.',
          'translation': 'This is an authentic Pochampally Ikat pure silk saree, handwoven on traditional looms over 12 days.',
        },
        'hi': {
          'original': 'यह असली पोचमपल्ली इकत सिल्क साड़ी है। पारंपरिक हथकरघे पर 12 दिनों में बुनी गई।',
          'translation': 'This is an authentic GI-tagged Pochampally Ikat silk saree, masterfully handwoven over 12 days.',
        },
        'ta': {
          'original': 'இது அசல் போச்சம்பள்ளி இக்கத் பட்டு புடவை. பாரம்பரிய தறியில் நெய்யப்பட்டது.',
          'translation': 'This is an authentic Pochampally Ikat silk saree woven on traditional handlooms.',
        },
        'kn': {
          'original': 'ಇದು ಅಸಲಿ ಪೋಚಂಪಲ್ಲಿ ಇಕ್ಕತ್ ರೇಷ್ಮೆ ಸೀರೆ. ಕೈಮಗ್ಗದಲ್ಲಿ ನೆಯ್ದ ಶ್ರೇಷ್ಠ ಕಲಾಕೃತಿ.',
          'translation': 'This is an authentic Pochampally Ikat silk saree woven with pure silk on pit looms.',
        },
        'en': {
          'original': 'This is an authentic Pochampally Ikat pure silk saree, handwoven on traditional looms over 12 days.',
          'translation': 'This is an authentic Pochampally Ikat pure silk saree, handwoven on traditional looms over 12 days.',
        },
      },
      'toy': {
        'kn': {
          'original': 'ಇದು ಚನ್ನಪಟ್ಟಣದ ಪ್ರಸಿದ್ಧ ಮರದ ಆಟಿಕೆ. ನೈಸರ್ಗಿಕ ತರಕಾರಿ ಬಣ್ಣ ಬಳಸಲಾಗಿದೆ, ಮಕ್ಕಳಿಗೆ ಸಂಪೂರ್ಣ ಸುರಕ್ಷಿತ.',
          'translation': 'This is a famous Channapatna wooden toy colored with natural vegetable dyes, 100% child-safe.',
        },
        'te': {
          'original': 'ఇది చెన్నపట్న చెక్క బొమ్మ. సహజ కాయగూరల రంగులతో చేసినది, పిల్లలకు చాలా సురక్షితం.',
          'translation': 'This is a handcrafted Channapatna wooden lacquer toy with safe natural vegetable colors.',
        },
        'hi': {
          'original': 'यह चन्नापटना का लकड़ी का खिलौना है। प्राकृतिक रंगों से रंगा है, बच्चों के लिए सुरक्षित।',
          'translation': 'This is a traditional Channapatna wooden toy finished with natural lacquer and non-toxic dyes.',
        },
        'ta': {
          'original': 'இது சென்னபட்டணா மர பொம்மை. இயற்கையான காய்கறி சாயங்களால் செய்யப்பட்டது.',
          'translation': 'This is a handcrafted Channapatna wooden toy finished with non-toxic natural vegetable colors.',
        },
        'en': {
          'original': 'This is a GI-protected Channapatna wooden toy with safe natural vegetable lacquer.',
          'translation': 'This is a GI-protected Channapatna wooden toy with safe natural vegetable lacquer.',
        },
      },
    };

    final craftData = data[craftKey] ?? data['basket']!;
    final langData = craftData[langCode] ?? craftData['te'] ?? craftData['en']!;
    return langData;
  }

  // Legacy accessor for backwards compatibility
  static Map<String, Map<String, String>> voiceTranscriptions = {
    'te': {
      'original': 'ఇది చేతితో తయారు చేసిన వెదురు బుట్ట. చాలా మంచిది మరియు దృఢంగా ఉంటుంది.',
      'translation': 'This is a handmade bamboo basket. It is very good and sturdy.',
    },
    'hi': {
      'original': 'यह हाथ से बनी बांस की टोकरी है। बहुत अच्छी और मजबूत है।',
      'translation': 'This is a handmade bamboo basket. It is very good and strong.',
    },
    'ta': {
      'original': 'இது கையால் செய்யப்பட்ட மூங்கில் கூடை. மிகவும் நல்லது மற்றும் உறுதியானது.',
      'translation': 'This is a handmade bamboo basket. Very good and strong.',
    },
    'kn': {
      'original': 'ಇದು ಕೈಯಿಂದ ತಯಾರಿಸಿದ ಬಿದಿರಿನ ಬುಟ್ಟಿ. ತುಂಬಾ ಒಳ್ಳೆಯದು ಮತ್ತು ಗಟ್ಟಿಮುಟ್ಟಾದ.',
      'translation': 'This is a handmade bamboo basket. Very good and sturdy.',
    },
    'en': {
      'original': 'This is a handmade bamboo basket. It is very good and sturdy.',
      'translation': 'This is a handmade bamboo basket. It is very good and sturdy.',
    },
  };
}
