import 'package:flutter/material.dart';
import 'route_names.dart';
import '../widgets/layout/buyer_shell.dart';
import '../../features/buyer/explore/buyer_explore_screen.dart';
import '../../features/buyer/rfq/buyer_rfq_screen.dart';
import '../../features/buyer/enquiries/buyer_enquiries_screen.dart';
import '../../features/buyer/profile/buyer_profile_screen.dart';
import '../../features/buyer/product/buyer_product_detail_screen.dart';
import '../../features/buyer/artisan/buyer_artisan_storefront_screen.dart';
import '../../data/models/product_model.dart';
import '../../data/models/artisan_model.dart';

class AppRouter {
  AppRouter._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.splash:
      case RouteNames.buyerHome:
        return MaterialPageRoute(builder: (_) => const BuyerShell());

      case RouteNames.buyerExplore:
        return MaterialPageRoute(builder: (_) => const BuyerExploreScreen());

      case RouteNames.buyerRfq:
        final craft = settings.arguments as String?;
        return MaterialPageRoute(builder: (_) => BuyerRfqScreen(prefilledCraft: craft));

      case RouteNames.buyerEnquiries:
        return MaterialPageRoute(builder: (_) => const BuyerEnquiriesScreen());

      case RouteNames.buyerProfile:
        return MaterialPageRoute(builder: (_) => const BuyerProfileScreen());

      case RouteNames.buyerProductDetail:
        final product = settings.arguments as ProductModel;
        return MaterialPageRoute(builder: (_) => BuyerProductDetailScreen(product: product));

      case RouteNames.buyerArtisanStorefront:
        final artisan = settings.arguments as ArtisanModel;
        return MaterialPageRoute(builder: (_) => BuyerArtisanStorefrontScreen(artisan: artisan));

      default:
        return MaterialPageRoute(builder: (_) => const BuyerShell());
    }
  }
}
