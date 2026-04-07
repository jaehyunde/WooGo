import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';

String translateLocation(String dbValue, BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  if (dbValue == '냉장') return l10n.storageFridge;
  if (dbValue == '냉동') return l10n.storageFreezer;
  if (dbValue == '펜트리') return l10n.storagePantry;
  return dbValue;
}

/// 카테고리 이름을 입력받아 적절한 이모지를 반환하는 함수
String getCategoryEmoji(String name) {
  final lowerName = name.toLowerCase();

  if (lowerName.contains('육류') || lowerName.contains('고기') || lowerName.contains('meat')) return '🥩';
  if (lowerName.contains('치즈') || lowerName.contains('cheese')) return '🧀';
  if (lowerName.contains('유제품') || lowerName.contains('우유') || lowerName.contains('dairy') || lowerName.contains('milk')) return '🥛';
  if (lowerName.contains('야채') || lowerName.contains('채소') || lowerName.contains('vegetable') || lowerName.contains('veggie')) return '🥦';
  if (lowerName.contains('과일') || lowerName.contains('fruit')) return '🍎';
  if (lowerName.contains('냉동') || lowerName.contains('아이스크림') || lowerName.contains('frozen')) return '❄️';
  if (lowerName.contains('음료') || lowerName.contains('beverage') || lowerName.contains('drink')) return '🥤';
  if (lowerName.contains('빵') || lowerName.contains('떡') || lowerName.contains('bakery') || lowerName.contains('bread')) return '🍞';
  if (lowerName.contains('생선') || lowerName.contains('해산물') || lowerName.contains('fish') || lowerName.contains('seafood')) return '🐟';
  if (lowerName.contains('소스') || lowerName.contains('양념') || lowerName.contains('sauce') || lowerName.contains('seasoning')) return '🥫';
  if (lowerName.contains('즉석') || lowerName.contains('밀키트') || lowerName.contains('instant') || lowerName.contains('mealkit')) return '🥡';
  if (lowerName.contains('통조림') || lowerName.contains('캔') || lowerName.contains('canned') || lowerName.contains('tin')) return '🥫';
  if (lowerName.contains('면') || lowerName.contains('파스타') || lowerName.contains('pasta')) return '🍝';
  if (lowerName.contains('기타') || lowerName.contains('etc')) return '📦';

  return '🏷️'; //
}

Widget getCategoryIcon(String name, {double size = 20, double padding = 8}) {
  return Container(
    padding: EdgeInsets.all(padding),
    decoration: BoxDecoration(
        color: Colors.grey[100],
        shape: BoxShape.circle
    ),
    child: Text(
      getCategoryEmoji(name), // 위에서 만든 함수 재사용
      style: TextStyle(fontSize: size),
    ),
  );
}

String translateCategory(String dbValue, BuildContext context) {
  final l10n = AppLocalizations.of(context);
  if (l10n == null) return dbValue;

  // 예: categoryMeat, categoryVegetable 등 (본인의 ARB 키 확인 필요)
  switch (dbValue) {
    case '육류': return l10n.categoryMeat;
    case '채소': return l10n.categoryVegetable;
    case '과일': return l10n.categoryFruit;
    case '유제품': return l10n.categoryDairy;
    case '생선': return l10n.categoryFish;
    case '해산물': return l10n.categorySeafood;
    case '음료': return l10n.categoryBeverage;
    case '빵': return l10n.categoryBakery;
    case '조미료': return l10n.categorySauce;
    case '냉동': return l10n.categoryFrozen;
    case '통조림': return l10n.categoryCanned;
    case '즉석': return l10n.categoryInstant;
    case '면': return l10n.categoryNoodle;
    case '기타': return l10n.categoryEtc;
    default: return dbValue;
  }
}