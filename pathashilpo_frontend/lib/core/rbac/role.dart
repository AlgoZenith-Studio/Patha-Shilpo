/// The four roles from TRD.md §5.2.
///
/// Only [artisan] and [buyer] are reachable from the UI in the MVP;
/// [moderator] and [dept] exist so the rules and the model are complete.
enum UserRole {
  artisan,
  buyer,
  moderator,
  dept;

  static UserRole? fromString(String? value) => switch (value) {
        'artisan' => UserRole.artisan,
        'buyer' => UserRole.buyer,
        'moderator' => UserRole.moderator,
        'dept' => UserRole.dept,
        _ => null,
      };

  String get wireValue => name;

  /// Roles a user may choose for themselves at first login. The other two are
  /// set manually in the console — a client must never be able to grant them.
  static const List<UserRole> selectableAtSignup = <UserRole>[artisan, buyer];
}
