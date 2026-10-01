import 'package:finder/l10n/l10n.dart';

class AppCategories {
  static const List<String> homeCategories = ['All Items', 'Lost', 'Found'];
  static const List<String> homeSubFilters = ['Nearby', 'Recent', 'With Reward'];
  static const List<String> statusTypes = ['Lost', 'Found'];

  static const List<String> postCategories = [
    'Electronics',
    'Watches & Jewelry',
    'Wallets & Bags',
    'Keys',
    'Pets',
    'Clothing',
    'Documents',
    'Other',
  ];

  static const List<String> searchCategories = [
    'All',
    'Electronics',
    'Keys',
    'Pets',
    'Wallets',
    'Bags',
    'Other',
  ];

  static const List<String> filterTypes = ['All', 'Lost', 'Found'];
  static const List<String> filterCategories = [
    'Electronics',
    'Wallet',
    'Keys',
    'Pets',
    'Jewelry',
    'Documents',
    'Others',
  ];
  static const List<String> filterTimes = ['Any time', 'Last 24h', 'Last Week', 'Last Month'];
  static const List<String> filterSortOptions = ['Most Recent', 'Nearest to Me'];

  static const List<String> managePostVisibilities = ['Public', 'Friends Only', 'Private'];

  /// Display name for a category / filter value. The lists above stay as the
  /// API values; only what the user sees is translated. Unknown values
  /// (e.g. a category the server added later) are shown as they are.
  static String label(AppLocalizations l10n, String value) {
    switch (value) {
      case 'All Items':
        return l10n.categoryAllItems;
      case 'All':
        return l10n.categoryAll;
      case 'Lost':
        return l10n.commonLost;
      case 'Found':
        return l10n.commonFound;
      case 'Nearby':
        return l10n.categoryNearby;
      case 'Recent':
        return l10n.categoryRecent;
      case 'With Reward':
        return l10n.categoryWithReward;
      case 'Electronics':
        return l10n.categoryElectronics;
      case 'Watches & Jewelry':
        return l10n.categoryWatchesJewelry;
      case 'Wallets & Bags':
        return l10n.categoryWalletsBags;
      case 'Keys':
        return l10n.categoryKeys;
      case 'Pets':
        return l10n.categoryPets;
      case 'Clothing':
        return l10n.categoryClothing;
      case 'Documents':
        return l10n.categoryDocuments;
      case 'Other':
        return l10n.categoryOther;
      case 'Wallets':
        return l10n.categoryWallets;
      case 'Bags':
        return l10n.categoryBags;
      case 'Wallet':
        return l10n.categoryWallet;
      case 'Jewelry':
        return l10n.categoryJewelry;
      case 'Others':
        return l10n.categoryOthers;
      case 'Any time':
        return l10n.filterAnyTime;
      case 'Last 24h':
        return l10n.filterLast24h;
      case 'Last Week':
        return l10n.filterLastWeek;
      case 'Last Month':
        return l10n.filterLastMonth;
      case 'Most Recent':
        return l10n.filterMostRecent;
      case 'Nearest to Me':
        return l10n.filterNearest;
      case 'Public':
        return l10n.categoryVisibilityPublic;
      case 'Friends Only':
        return l10n.categoryVisibilityFriendsOnly;
      case 'Private':
        return l10n.categoryVisibilityPrivate;
      default:
        return value;
    }
  }
}
