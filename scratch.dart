import 'dart:io';

void main() {
  var dir = Directory('/Users/john/.pub-cache/hosted/pub.dev');
  if (dir.existsSync()) {
    for (var d in dir.listSync()) {
      if (d.path.contains('flutter_gemma-')) {
        print(d.path);
      }
    }
  }
}
