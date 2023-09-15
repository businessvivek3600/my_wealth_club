import 'package:ansicolor/ansicolor.dart';
import 'package:flutter/foundation.dart';

AnsiPen _blackLog = AnsiPen()..black(bold: true);
AnsiPen _infoLog = AnsiPen()..cyan(bold: true);
AnsiPen _successLog = AnsiPen()..green(bold: true);
AnsiPen _warningLog = AnsiPen()..yellow(bold: true);
AnsiPen _errorLog = AnsiPen()..red(bold: true);

blackLog(String data, [String? tag, String? extra]) =>
    logD(_blackLog(data), tag, extra);
infoLog(String data, [String? tag, String? extra]) =>
    logD(_infoLog('ℹ $data'), tag, extra);
successLog(String data, [String? tag, String? extra]) =>
    logD(_successLog('✔ $data'), tag, extra);
warningLog(String data, [String? tag, String? extra]) =>
    logD(_warningLog('⚠️ $data'), tag, extra);
errorLog(String data, [String? tag, String? extra]) =>
    logD(_errorLog('💀 $data'), tag, extra);

logD(String data, [String? tag, String? extra, bool colored = false]) {
  ansiColorDisabled = colored;
  debugPrint(
      '${_blackLog('--->')}${tag != null ? ('<$tag> ') : ''} $data ${extra != null ? ('<$extra> ') : ''} ${_blackLog('<---')}');
}

longLogger(String data,[String? tag]) {
  int maxCharactersPerLine = 200;
  warningLog('Running on $tag');
  if (data.length > maxCharactersPerLine) {
    int iterations = (data.length / maxCharactersPerLine).floor();
    for (int i = 0; i <= iterations; i++) {
      int endingIndex = i * maxCharactersPerLine + maxCharactersPerLine;
      if (endingIndex > data.length) {
        endingIndex = data.length;
      }
      infoLog(data.substring(i * maxCharactersPerLine, endingIndex));
    }
  } else {
    infoLog(data.toString());
  }
}
