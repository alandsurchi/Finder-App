import 'dart:io';

void main() {
  final baseDir = 'lib/screens';
  
  // ======= 1. Fix home_screen.dart missing parenthesis =======
  final homePath = '$baseDir/home_screen.dart';
  final homeFile = File(homePath);
  if (homeFile.existsSync()) {
    var home = homeFile.readAsStringSync();
    home = home.replaceAll(
'''
          ],
        );
      }),
    );
  }
}''', 
'''
          ],
        ),
        );
      }),
    );
  }
}'''
    );
    homeFile.writeAsStringSync(home);
  }
  
  // ======= 2. Replace _$1  =======
  final filesToFix = [
    '$baseDir/manage_post_screen.dart',
    '$baseDir/get_verified_screen.dart',
    '$baseDir/item_details_screen.dart',
  ];
  
  for (final path in filesToFix) {
    final file = File(path);
    if (!file.existsSync()) continue;
    var c = file.readAsStringSync();
    
    // Convert $_1 back to safe standard theme tokens via getters
    c = c.replaceAll('color: _\$1, fontSize: 10', 'color: _textLight, fontSize: 10');
    c = c.replaceAll('color: _\$1, fontSize: 11', 'color: _textLight, fontSize: 11');
    c = c.replaceAll('color: _\$1, fontSize: 12', 'color: _textLight, fontSize: 12');
    c = c.replaceAll('color: _\$1,\n                fontSize: 10', 'color: _textLight,\n                fontSize: 10');
    c = c.replaceAll('color: _\$1', 'color: _textDark'); // default
    
    // ======= 3. Fix all trailing invalid const keywords by stripping const from widgets and styles =======
    // Because we migrated constants like _blue to getters (which are not const),
    // any `const Widget(color: _blue)` became an invalid const value.
    // We will mercilessly strip the const keyword from constructors in these files to ensure compilation.
    final widgetsToStrip = [
      'Text', 'Icon', 'Expanded', 'Padding', 'Row', 'Column', 'Container', 'SizedBox',
      'TextStyle', 'BorderSide', 'BoxDecoration', 'BoxShadow', 'OutlinedButton.styleFrom',
      'ElevatedButton.styleFrom', 'EdgeInsets.all', 'EdgeInsets.symmetric', 'EdgeInsets.fromLTRB',
      'EdgeInsets.only'
    ];
    
    for (final w in widgetsToStrip) {
      c = c.replaceAll('const $w(', '$w(');
    }
    
    // Strip const from lists that contain non-const getters
    c = c.replaceAll('const [', '[');
    
    // Re-save file
    file.writeAsStringSync(c);
  }
  
  // ======= 4. Fix widget_test.dart =======
  final testPath = 'test/widget_test.dart';
  final testFile = File(testPath);
  if (testFile.existsSync()) {
    var content = testFile.readAsStringSync();
    content = content.replaceAll('MyApp()', 'FinderApp()'); 
    testFile.writeAsStringSync(content);
  }
  
  print('Final fixes applied successfully! Run `flutter analyze` again to verify.');
}
