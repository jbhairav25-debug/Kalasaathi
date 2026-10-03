import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'data/mock_data.dart';
import 'models/product.dart';
import 'models/order.dart';

import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'screens/marketplace_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/image_enhancement_screen.dart';
import 'screens/voice_catalogue_screen.dart';
import 'screens/pricing_screen.dart';
import 'screens/approval_screen.dart';
import 'screens/success_screen.dart';
import 'screens/product_details_screen.dart';

/// App-wide state management for products and orders
class AppState extends ChangeNotifier {
  final List<Product> _myProducts = List.from(MockData.myProducts);
  final List<Product> _marketplaceProducts = List.from(MockData.marketplaceProducts);
  final List<Order> _myOrders = List.from(MockData.myOrders);

  List<Product> get myProducts => List.unmodifiable(_myProducts);
  List<Product> get marketplaceProducts => List.unmodifiable(_marketplaceProducts);
  List<Order> get myOrders => List.unmodifiable(_myOrders);

  void publishProduct(Product product) {
    _myProducts.insert(0, product);
    _marketplaceProducts.insert(0, product);
    notifyListeners();
  }
}

final AppState appState = AppState();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const KalaSaathiApp());
}

class KalaSaathiApp extends StatelessWidget {
  const KalaSaathiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        return MaterialApp(
          title: 'KalaSaathi',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          initialRoute: '/',
          routes: {
            '/': (context) => const SplashScreen(),
            '/onboarding': (context) => const OnboardingScreen(),
            '/main': (context) => const MainNavigationScreen(),
            '/image-enhancement': (context) => const ImageEnhancementScreen(),
            '/voice-catalogue': (context) => const VoiceCatalogueScreen(),
            '/pricing': (context) => const PricingScreen(),
            '/approval': (context) => ApprovalScreen(
                  onPublish: (product) => appState.publishProduct(product),
                ),
            '/success': (context) => const SuccessScreen(),
            '/product-details': (context) => const ProductDetailsScreen(),
          },
        );
      },
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  bool _handledInitialTab = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_handledInitialTab) {
      _handledInitialTab = true;
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args['tab'] is int) {
        final tabIndex = args['tab'] as int;
        if (tabIndex >= 0 && tabIndex < 5 && tabIndex != 1) {
          _currentIndex = tabIndex;
        }
      }
    }
  }

  void _onTabTapped(int index) {
    if (index == 1) {
      // Tap on "Add Craft" tab opens the photo enhancement flow
      Navigator.of(context).pushNamed('/image-enhancement');
    } else {
      setState(() => _currentIndex = index);
    }
  }

  void _navigateToProductDetails(Product product) {
    Navigator.of(context).pushNamed(
      '/product-details',
      arguments: product,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine screen to display based on tab
    final List<Widget> screens = [
      HomeScreen(
        myProducts: appState.myProducts,
        myOrders: appState.myOrders,
        onAddCraft: () =>
            Navigator.of(context).pushNamed('/image-enhancement'),
        onProductTap: _navigateToProductDetails,
      ),
      // Dummy placeholder for Add Craft tab which triggers a modal route
      const SizedBox.shrink(),
      MarketplaceScreen(
        products: appState.marketplaceProducts,
        onProductTap: _navigateToProductDetails,
      ),
      OrdersScreen(orders: appState.myOrders),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex == 1 ? 0 : _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppTheme.primary,
          unselectedItemColor: AppTheme.textTertiary,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          elevation: 0,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              activeIcon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              label: 'Add Craft',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.storefront_outlined),
              activeIcon: Icon(Icons.storefront_rounded),
              label: 'Marketplace',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.local_shipping_outlined),
              activeIcon: Icon(Icons.local_shipping_rounded),
              label: 'Orders',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
