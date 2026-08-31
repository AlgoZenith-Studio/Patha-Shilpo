/// Route table from TRD.md §11.3.
///
/// The role prefixes exist so the route guard can pick a shell. That guard is
/// **cosmetic** — the authoritative check is the Firestore Security Rules
/// (TRD.md §5.2).
abstract final class Routes {
  static const String splash = '/';
  static const String roleSelect = '/role-select';
  static const String login = '/login';
  static const String otp = '/otp';

  static const String artisanHome = '/artisan';
  static const String artisanProducts = '/artisan/products';
  static const String artisanEnquiries = '/artisan/enquiries';
  static const String artisanProfile = '/artisan/profile';
  static const String artisanAddProduct = '/artisan/add-product';

  static const String buyerExplore = '/buyer';
  static const String buyerProduct = '/buyer/product';
  static const String buyerRfq = '/buyer/rfq';
  static const String buyerEnquiries = '/buyer/enquiries';
  static const String buyerProfile = '/buyer/profile';

  static const String moderator = '/moderator';
  static const String dept = '/dept';

  /// Settings — the single control for the app's language.
  static const String settings = '/settings';

}
