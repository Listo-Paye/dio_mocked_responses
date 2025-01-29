import 'dart:io';

import 'package:dio/dio.dart';
import 'package:template_expressions/template_expressions.dart';

import 'history_item.dart';

/// MockConfiguration
///
/// This class is used to configure the mock interceptor.
///
/// It contains the regular expression used to replace the template in the response files,
/// the history of requests made to the server, the context and persona used to load the files,
/// and the syntax used to evaluate the expressions in the templates.
class MockConfiguration {
  static final RegExp _regexpTemplate = RegExp(r'"\$\{template\}"');
  static const StandardExpressionSyntax _exSyntax = StandardExpressionSyntax();
  static final List<HistoryItem> _history = [];
  static String? _context;
  static String? _persona;

  /// Returns the history of requests made to the server.
  ///
  /// The history is stored in a list of [HistoryItem] objects.
  static List<HistoryItem> get history => _history;

  /// Returns the regular expression used to replace the template in the response files.
  static RegExp get regexpTemplate => _regexpTemplate;

  /// Returns the syntax used to evaluate the expressions in the templates.
  static StandardExpressionSyntax get exSyntax => _exSyntax;

  /// Sets the persona used to load the files.
  static void setPersona(String persona) {
    _persona = persona;
  }

  /// Clears the persona used to load the files.
  static void clearPersona() {
    _persona = null;
  }

  /// Sets the context used to load the files.
  static void setContext(String context) {
    _context = context;
  }

  /// Clears the context used to load the files.
  static void clearContext() {
    _context = null;
  }

  /// Clears the history of requests made to the server.
  static void clearHistory() {
    _history.clear();
  }

  /// Returns the file path of the response file.
  ///
  /// The file path is built using the base path, the persona, the context, and the path of the request.
  static String getfilePath(String path, String basePath) {
    var context = _context ?? '';
    var persona = _persona ?? '';
    var personaPath = persona.isEmpty ? basePath : '$basePath$persona/';
    var filePath = '$personaPath${path.replaceAll(RegExp(r"(\?|=|&)"), '_')}';
    if (context.isNotEmpty) {
      var fileWithContext = '$filePath/$context.json';
      if (File(fileWithContext).existsSync()) {
        return fileWithContext;
      }
    }
    return '$filePath.json';
  }

  /// Returns the query parameters of the request.
  ///
  /// If the query parameters are empty and the path contains a query string, the query parameters are extracted from the path.
  /// Otherwise, the query parameters are returned as is.
  static Map<String, dynamic> getQueryParameters(RequestOptions options) {
    if (options.queryParameters.isEmpty && options.path.contains('?')) {
      Map<String, dynamic> queryParameters = {};
      for (final queryParameter in options.path.split('?').last.split('&')) {
        final queryParameterSplit = queryParameter.split('=');
        queryParameters[queryParameterSplit.first] = queryParameterSplit.last;
      }
      return queryParameters;
    }
    return options.queryParameters;
  }

  /// Returns the full path of the request.
  ///
  /// If the query parameters are empty, the path is returned as is.
  static String getFullPath(RequestOptions options) {
    if (options.queryParameters.isEmpty) {
      return options.path;
    }
    return "${options.path}?${options.queryParameters.entries.map(
          (e) => "${e.key}=${e.value}",
        ).join(
          "&",
        )}";
  }
}
