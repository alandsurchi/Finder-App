import 'dart:io';

void main() {
  final baseDir = 'lib/screens';
  
  // 1. Fix get_verified_screen.dart
  final getVerifiedPath = '$baseDir/get_verified_screen.dart';
  var getVerified = File(getVerifiedPath).readAsStringSync();
  
  // Add missing `t` in build
  getVerified = getVerified.replaceAll(
    '  Widget build(BuildContext context) {\n    return Scaffold(',
    '  Widget build(BuildContext context) {\n    final t = AppColorTokens.of(context);\n    return Scaffold('
  );
  
  // Add getters to _GetVerifiedScreenState
  getVerified = getVerified.replaceAll(
    '  bool _submitted = false;\n',
    '  bool _submitted = false;\n\n  AppColorTokens get t => AppColorTokens.of(context);\n  Color get _bg => t.bg;\n  Color get _blue => t.primary;\n  Color get _blueLight => t.primaryContainer;\n  Color get _white => t.surface;\n  Color get _divider => t.divider;\n  Color get _textLight => t.onSurfaceMuted;\n  Color get _textDark => t.onSurface;\n'
  );
  
  // Remove const for TextStyles that use getters
  getVerified = getVerified.replaceAll(RegExp(r'const\s+TextStyle\(\s*color:\s*_(textLight|textDark|blue|white)'), 'TextStyle(color: _\$1');
  
  File(getVerifiedPath).writeAsStringSync(getVerified);


  // 2. Fix manage_post_screen.dart
  final managePostPath = '$baseDir/manage_post_screen.dart';
  var managePost = File(managePostPath).readAsStringSync();
  
  managePost = managePost.replaceAll(
    '  void _markChanged() => setState(() => _hasChanges = true);\n',
    '  void _markChanged() => setState(() => _hasChanges = true);\n\n  AppColorTokens get t => AppColorTokens.of(context);\n  Color get _bg => t.bg;\n  Color get _textDark => t.onSurface;\n  Color get _textLight => t.onSurfaceMuted;\n  Color get _textMid => t.onSurfaceVar;\n  Color get _red => t.error;\n  Color get _redLight => t.errorSurface;\n  Color get _orange => t.warning;\n  Color get _blue => t.primary;\n  Color get _green => t.success;\n  Color get _white => t.surface;\n  Color get _divider => t.divider;\n'
  );
  
  managePost = managePost.replaceAll(RegExp(r'const\s+TextStyle\(\s*color:\s*_(textLight|textDark|textMid|blue|white|red|orange)'), 'TextStyle(color: _\$1');
  managePost = managePost.replaceAll(RegExp(r'const\s+TextStyle\(\s*fontWeight:\s*FontWeight.bold,\s*color:\s*_(textDark)'), 'TextStyle(fontWeight: FontWeight.bold, color: _\$1');
  
  File(managePostPath).writeAsStringSync(managePost);


  // 3. Fix item_details_screen.dart
  final itemDetailsPath = '$baseDir/item_details_screen.dart';
  var itemDetails = File(itemDetailsPath).readAsStringSync();
  
  itemDetails = itemDetails.replaceAll(
    '_buildOwnerCard(item, context),',
    '_buildOwnerCard(item, context, t),'
  );
  itemDetails = itemDetails.replaceAll(
    '_buildSafetyActions(),',
    '_buildSafetyActions(t),'
  );
  
  itemDetails = itemDetails.replaceAll(
    '  Widget build(BuildContext context) {\n    return GestureDetector(',
    '  Widget build(BuildContext context) {\n    final t = AppColorTokens.of(context);\n    final _blue = t.primary;\n    final _textDark = t.onSurface;\n    final _textLight = t.onSurfaceMuted;\n    return GestureDetector('
  );
  
  itemDetails = itemDetails.replaceAll(RegExp(r'const\s+TextStyle\(\s*color:\s*_(textLight|textDark|blue)'), 'TextStyle(color: _\$1');
  
  File(itemDetailsPath).writeAsStringSync(itemDetails);

  print('Files patched successfully!');
}
