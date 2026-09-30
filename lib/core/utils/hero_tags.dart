/// Hero tags for post images.
///
/// Every list that can show the same post (Home, Search, Saved, My posts,
/// Admin) gets its own scope, so two mounted lists never share one tag: a
/// duplicate tag makes Flutter skip the flight, which looked like a glitch.
class HeroTags {
  HeroTags._();

  static const String home = 'home';
  static const String search = 'search';
  static const String saved = 'saved';
  static const String myPosts = 'my-posts';
  static const String admin = 'admin';
  static const String similar = 'similar';

  static String item(String scope, String id) => 'item-image-$scope-$id';
}
