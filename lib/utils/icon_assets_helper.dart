class IconAssetsHelper {
  static const String iconPath = 'assets/images/icons/';
  static Map<String, String> map = {
    "favourites": "icon_mine_favourites.png",
    "history": "icon_mine_history.png",
    "pyrasebook": "icon_mine_phracebook.png",
    "datetime": "icon_phrase_cat_datetime.png",
    "emergency": "icon_phrase_cat_emergency.png",
    "essentials": "icon_phrase_cat_essentials.png",
    "health": "icon_phrase_cat_health.png",
    "shopping": "icon_phrase_cat_shopping.png",
    "technology": "icon_phrase_cat_techonlogy.png",
    "travelling": "icon_phrase_cat_travelling.png",
    "dining": "icon_phrase_cat_dining.png",
    "lodging": "icon_phrase_cat_lodging.png",
  };

  static String getIcon(String name) {
    return iconPath + (map[name] ?? '');
  }
}
