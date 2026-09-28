import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/add_product_screen.dart';
import '../screens/ai_assistant_screen.dart';
import '../screens/alerts_screen.dart';
import '../screens/all_services_screen.dart';
import '../screens/blockchain_verify_screen.dart';
import '../screens/browse_products_screen.dart';
import '../screens/buyer_ai_assistant_screen.dart';
import '../screens/buyer_dashboard_screen.dart';
import '../screens/buyer_details_screen.dart';
import '../screens/buyer_orders_screen.dart';
import '../screens/buyer_profile_screen.dart';
import '../screens/buyer_screen.dart';
import '../screens/chat_farmer_screen.dart';
import '../screens/chat_screen.dart';
import '../screens/community_screen.dart';
import '../screens/create_listing_screen.dart';
import '../screens/create_post_screen.dart';
import '../screens/crop_advisory_screen.dart';
import '../screens/crop_calendar_screen.dart';
import '../screens/crop_details_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/edit_profile_screen.dart';
import '../screens/equipment_screen.dart';
import '../screens/experts_screen.dart';
import '../screens/farmer_advisory_screen.dart';
import '../screens/farmer_onboarding_screen.dart';
import '../screens/farmer_orders_screen.dart';
import '../screens/farmer_products_screen.dart';
import '../screens/farmer_profile_screen.dart';
import '../screens/farmer_upload_screen.dart';
import '../screens/find_farmers_screen.dart';
import '../screens/government_schemes_screen.dart';
import '../screens/invoice_screen.dart';
import '../screens/language_selection_screen.dart';
import '../screens/location_setup_screen.dart';
import '../screens/login_screen.dart';
import '../screens/market_screen.dart';
import '../screens/marketplace_screen.dart';
import '../screens/my_orders_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/order_management_screen.dart';
import '../screens/order_success_screen.dart';
import '../screens/order_tracking_screen.dart';
import '../screens/otp_screen.dart';
import '../screens/payment_screen.dart';
import '../screens/place_order_screen.dart';
import '../screens/post_details_screen.dart';
import '../screens/product_details_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/profile_setup_screen.dart';
import '../screens/ratings_reviews_screen.dart';
import '../screens/register_screen.dart';
import '../screens/request_quote_screen.dart';
import '../screens/role_selection_screen.dart';
import '../screens/schemes_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/soil_health_screen.dart';
import '../screens/theme_selection_screen.dart';
import '../screens/track_order_screen.dart';
import '../screens/weather_screen.dart';
import '../services/token_service.dart';

class AppRouter {
  static const _publicRoutes = {
    '/language',
    '/role-selection',
    '/login',
    '/register',
    '/otp',
    '/profile-setup',
    '/location-setup',
    '/farmer-onboarding',
  };

  static GoRouter create() {
    return GoRouter(
      initialLocation: '/language',
      redirect: (context, state) async {
        final session = await TokenService.loadSession();
        final location = state.uri.path;
        final isPublic = _publicRoutes.contains(location);
        if (!session.isAuthenticated && !isPublic) {
          return '/login?from=${Uri.encodeComponent(state.uri.toString())}';
        }
        if (session.isAuthenticated &&
            (location == '/' || location == '/language' || location == '/login')) {
          return session.role == 'BUYER' ? '/buyer-dashboard' : '/dashboard';
        }
        return null;
      },
      routes: [
        GoRoute(path: '/', name: 'root', builder: (_, __) => const LanguageSelectionScreen()),
        GoRoute(path: '/language', name: 'language', builder: (_, __) => const LanguageSelectionScreen()),
        GoRoute(path: '/role-selection', name: 'role-selection', builder: (_, __) => const RoleSelectionScreen()),
        GoRoute(path: '/login', name: 'login', builder: (_, __) => const LoginScreen()),
        GoRoute(path: '/register', name: 'register', builder: (_, __) => const RegisterScreen()),
        GoRoute(path: '/otp', name: 'otp', builder: (_, __) => const OtpScreen()),
        GoRoute(path: '/profile-setup', name: 'profile-setup', builder: (_, __) => const ProfileSetupScreen()),
        GoRoute(path: '/location-setup', name: 'location-setup', builder: (_, __) => const LocationSetupScreen()),
        GoRoute(path: '/farmer-onboarding', name: 'farmer-onboarding', builder: (_, __) => const FarmerOnboardingScreen()),
        GoRoute(path: '/dashboard', name: 'dashboard', builder: (_, __) => const DashboardScreen()),
        GoRoute(path: '/buyer-dashboard', name: 'buyer-dashboard', builder: (_, __) => const BuyerDashboardScreen()),
        GoRoute(path: '/ai-assistant', name: 'ai-assistant', builder: (_, __) => const AIAssistantScreen()),
        GoRoute(path: '/buyer-ai-assistant', name: 'buyer-ai-assistant', builder: (_, __) => const BuyerAIAssistantScreen()),
        GoRoute(path: '/alerts', name: 'alerts', builder: (_, __) => const AlertsScreen()),
        GoRoute(path: '/all-services', name: 'all-services', builder: (_, __) => const AllServicesScreen()),
        GoRoute(path: '/browse-products', name: 'browse-products', builder: (_, __) => const BrowseProductsScreen()),
        GoRoute(path: '/buyer', name: 'buyer', builder: (_, __) => const BuyerScreen()),
        GoRoute(path: '/buyer-details', name: 'buyer-details', builder: (_, state) => BuyerDetailsScreen(crop: state.uri.queryParameters['crop'] ?? '', farmer: state.uri.queryParameters['farmer'] ?? '', quantity: state.uri.queryParameters['quantity'] ?? '', location: state.uri.queryParameters['location'] ?? '', price: state.uri.queryParameters['price'] ?? '')),
        GoRoute(path: '/buyer-orders', name: 'buyer-orders', builder: (_, __) => const BuyerOrdersScreen()),
        GoRoute(path: '/buyer-profile', name: 'buyer-profile', builder: (_, __) => const BuyerProfileScreen()),
        GoRoute(path: '/chat', name: 'chat', builder: (_, __) => const ChatScreen()),
        GoRoute(path: '/chat-farmer', name: 'chat-farmer', builder: (_, __) => const ChatFarmerScreen()),
        GoRoute(path: '/community', name: 'community', builder: (_, __) => const CommunityScreen()),
        GoRoute(path: '/create-listing', name: 'create-listing', builder: (_, __) => const CreateListingScreen()),
        GoRoute(path: '/create-post', name: 'create-post', builder: (_, __) => const CreatePostScreen()),
        GoRoute(path: '/post-details', name: 'post-details', builder: (_, state) => PostDetailsScreen(userName: state.uri.queryParameters['user'] ?? '', question: state.uri.queryParameters['question'] ?? '')),
        GoRoute(path: '/crop-advisory', name: 'crop-advisory', builder: (_, __) => const CropAdvisoryScreen()),
        GoRoute(path: '/crop-calendar', name: 'crop-calendar', builder: (_, __) => const CropCalendarScreen()),
        GoRoute(path: '/crop-details', name: 'crop-details', builder: (_, __) => const CropDetailsScreen()),
        GoRoute(path: '/blockchain-verify', name: 'blockchain-verify', builder: (_, __) => const BlockchainVerifyScreen()),
        GoRoute(path: '/disease-detection', name: 'disease-detection', builder: (_, __) => const BlockchainVerifyScreen()),
        GoRoute(path: '/edit-profile', name: 'edit-profile', builder: (_, __) => const EditProfileScreen()),
        GoRoute(path: '/equipment', name: 'equipment', builder: (_, __) => const EquipmentScreen()),
        GoRoute(path: '/experts', name: 'experts', builder: (_, __) => const ExpertsScreen()),
        GoRoute(path: '/farmer-advisory', name: 'farmer-advisory', builder: (_, __) => const FarmerAdvisoryScreen()),
        GoRoute(path: '/farmer-orders', name: 'farmer-orders', builder: (_, __) => const FarmerOrdersScreen()),
        GoRoute(path: '/farmer-products', name: 'farmer-products', builder: (_, __) => const FarmerProductsScreen()),
        GoRoute(path: '/farmer-profile', name: 'farmer-profile', builder: (_, __) => const FarmerProfileScreen()),
        GoRoute(path: '/farmer-upload', name: 'farmer-upload', builder: (_, __) => const FarmerUploadScreen()),
        GoRoute(path: '/find-farmers', name: 'find-farmers', builder: (_, __) => const FindFarmersScreen()),
        GoRoute(path: '/government-schemes', name: 'government-schemes', builder: (_, __) => const GovernmentSchemesScreen()),
        GoRoute(
          path: '/invoice',
          name: 'invoice',
          builder: (_, state) => InvoiceScreen(
            orderId: int.tryParse(state.uri.queryParameters['orderId'] ?? ''),
          ),
        ),
        GoRoute(path: '/market', name: 'market', builder: (_, __) => const MarketScreen()),
        GoRoute(path: '/marketplace', name: 'marketplace', builder: (_, __) => const MarketplaceScreen()),
        GoRoute(path: '/add-product', name: 'add-product', builder: (_, __) => const AddProductScreen()),
        GoRoute(path: '/my-orders', name: 'my-orders', builder: (_, __) => const MyOrdersScreen()),
        GoRoute(path: '/notifications', name: 'notifications', builder: (_, __) => const NotificationScreen()),
        GoRoute(path: '/order-management', name: 'order-management', builder: (_, __) => const OrderManagementScreen()),
        GoRoute(path: '/order-success', name: 'order-success', builder: (_, __) => const OrderSuccessScreen()),
        GoRoute(path: '/order-tracking', name: 'order-tracking', builder: (_, __) => const OrderTrackingScreen()),
        GoRoute(
          path: '/payment',
          name: 'payment',
          builder: (_, state) => PaymentScreen(
            orderId: int.tryParse(state.uri.queryParameters['orderId'] ?? ''),
            totalAmount: double.tryParse(state.uri.queryParameters['totalAmount'] ?? ''),
            productName: state.uri.queryParameters['productName'],
            quantity: double.tryParse(state.uri.queryParameters['quantity'] ?? ''),
            unit: state.uri.queryParameters['unit'],
            deliveryAddress: state.uri.queryParameters['deliveryAddress'],
          ),
        ),
        GoRoute(path: '/place-order', name: 'place-order', builder: (_, __) => const PlaceOrderScreen()),
        GoRoute(path: '/product-details', name: 'product-details', builder: (_, __) => const ProductDetailsScreen()),
        GoRoute(path: '/profile', name: 'profile', builder: (_, __) => const ProfileScreen()),
        GoRoute(path: '/ratings-reviews', name: 'ratings-reviews', builder: (_, __) => const RatingsReviewsScreen()),
        GoRoute(path: '/request-quote', name: 'request-quote', builder: (_, __) => const RequestQuoteScreen()),
        GoRoute(path: '/schemes', name: 'schemes', builder: (_, __) => const SchemesScreen()),
        GoRoute(path: '/settings', name: 'settings', builder: (_, __) => const SettingsScreen()),
        GoRoute(path: '/soil-health', name: 'soil-health', builder: (_, __) => const SoilHealthScreen()),
        GoRoute(path: '/theme-selection', name: 'theme-selection', builder: (_, __) => const ThemeSelectionScreen()),
        GoRoute(path: '/track-order', name: 'track-order', builder: (_, __) => const TrackOrderScreen()),
        GoRoute(path: '/weather', name: 'weather', builder: (_, __) => const WeatherScreen()),
      ],
      errorBuilder: (_, state) => Scaffold(
        body: Center(child: Text('Page not found: ${state.uri.path}')),
      ),
    );
  }
}
