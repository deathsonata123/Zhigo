import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/restaurant_provider.dart';
import 'screens/home_screen.dart';
import 'screens/restaurant_detail_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/active_delivery_screen.dart';
import 'screens/partner_onboarding_screen.dart';
import 'widgets/floating_chatbot.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => RestaurantProvider()),
      ],
      child: MaterialApp(
        title: 'Zhigo Customer',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.orange,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: false,
            elevation: 0,
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const HomeScreen(),
          '/restaurant': (context) => const RestaurantDetailScreen(),
          '/checkout': (context) => const CheckoutScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/partner-onboarding': (context) => const PartnerOnboardingScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/delivery') {
            final orderId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => ActiveDeliveryScreen(orderId: orderId),
            );
          }
          return null;
        },
        builder: (context, child) {
          return Stack(
            children: [
              child!,
              const FloatingChatbot(),
            ],
          );
        },
      ),
    );
  }
}
