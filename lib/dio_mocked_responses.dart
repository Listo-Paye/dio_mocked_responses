library dio_mocked_responses;

//ignore_for_file:  prefer_interpolation_to_compose_strings,unnecessary_string_escapes

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:template_expressions/template_expressions.dart';

class MockInterceptor extends Interceptor {
  late final String _basePath;
  final RegExp _regexpTemplate = RegExp(r'"\$\{template\}"');
  static const StandardExpressionSyntax _exSyntax = StandardExpressionSyntax();
  static final List<HistoryItem> _history = [];
  static String? _context;
  static String? _persona;

  MockInterceptor({String basePath = 'test/dio_responses'}) {
    _basePath = basePath.endsWith('/') ? basePath : '$basePath/';
  }

  static List<HistoryItem> get history => _history;

  static void setPersona(String persona) {
    _persona = persona;
  }

  static void clearPersona() {
    _persona = null;
  }

  static String? get persona => _persona;

  static void setContext(String context) {
    _context = context;
  }

  static void clearContext() {
    _context = null;
  }

  static void clearHistory() {
    _history.clear();
  }

  String getfilePath(String path) {
    var context = _context ?? '';
    var persona = _persona ?? '';
    var basePath = persona.isEmpty ? _basePath : '$_basePath$persona/';
    var filePath = '$basePath${path.replaceAll(RegExp(r"(\?|=|&)"), '_')}';
    if (context.isNotEmpty) {
      var fileWithContext = '$filePath/$context.json';
      if (File(fileWithContext).existsSync()) {
        return fileWithContext;
      }
    }
    return '$filePath.json';
  }

  Map<String, dynamic> getQueryParameters(RequestOptions options) {
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

  String getFullPath(RequestOptions options) {
    if (options.queryParameters.isEmpty) {
      return options.path;
    }
    return "${options.path}?${options.queryParameters.entries.map((e) => "${e.key}=${e.value}").join("&")}";
  }

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final file = File(getfilePath(getFullPath(options)));

    _history.add(HistoryItem(
      options.method,
      getFullPath(options),
      options.data,
      getQueryParameters(options),
    ));

    if (!file.existsSync()) {
      handler.reject(DioException(
          requestOptions: options, error: "Can't find file: ${file.path}"));
      return;
    }

    late final Map<String, dynamic> json;
    try {
      json = jsonDecode(file.readAsStringSync());
    } catch (e) {
      handler.reject(DioException(
          requestOptions: options, error: "Can't parse file: ${file.path}"));
      return;
    }

    final Map<String, dynamic> route = json[options.method];

    if (route.isEmpty) {
      handler.reject(DioException(
          requestOptions: options,
          error:
              "Can't find route setting: ${options.path}:${options.method}"));
      return;
    }

    int statusCode = route['statusCode'] as int;

    Map<String, dynamic>? template = route['template'];
    Object? data = route['data'];

    if (statusCode != 200) {
      handler.reject(
        DioException(
          requestOptions: options,
          response: Response(
            requestOptions: options,
            statusCode: statusCode,
            data: data,
          ),
          error: "Mock error with status $statusCode",
          type: DioExceptionType.badResponse,
        ),
      );
      return;
    }

    if (template == null && data == null) {
      handler.resolve(Response(
        requestOptions: options,
        statusCode: statusCode,
      ));
      return;
    }

    Map<String, dynamic>? vars = route['vars'];
    var exContext = vars ?? {};

    exContext.putIfAbsent(
        'req',
        () => {
              'headers': options.headers,
              'queryParameters': options.queryParameters,
              'baseUrl': options.baseUrl,
              'method': options.method,
              'path': options.path,
              // 'uri': options.uri.,
              // 'connectTimeout': options.connectTimeout
            });

    if (options.data != null) {
      if (options.data is Map) {
        exContext.update('req', (value) {
          value['data'] = options.data;
          return value;
        });
      }
      if (options.data is FormData) {
        List<MapEntry<String, String>> fields =
            (options.data as FormData).fields;
        exContext.update('req', (value) {
          value['data'] = {for (var e in fields) e.key: e.value};
          return value;
        });
      }
    }

    if (template != null && data == null) {
      String resData = _templateData(template, exContext);
      if (vars != null && vars.isNotEmpty) {
        resData = _replaceVarObjs(resData, vars);
      }

      resData = Template(
        syntax: [_exSyntax],
        value: resData,
      ).process(context: exContext);

      handler.resolve(Response(
        data: resData,
        requestOptions: options,
        statusCode: statusCode,
      ));
      return;
    }

    String resData = jsonEncode(data);

    if (template != null) {
      String tData = _templateData(template, exContext);
      resData = resData.replaceAll(_regexpTemplate, tData);
    }

    Map<String, dynamic>? templates = route['templates'];
    if (templates != null && templates.isNotEmpty) {
      for (var entry in templates.entries) {
        Map<String, dynamic> template = entry.value;
        String tData = _templateData(template, exContext);
        RegExp regexpTemplate = RegExp(r'"\$\{templates\.' + entry.key + '}"');
        resData = resData.replaceAll(regexpTemplate, tData);
      }
    }

    if (vars != null && vars.isNotEmpty) {
      resData = _replaceVarObjs(resData, vars);
    }

    resData = Template(
      syntax: [_exSyntax],
      value: resData,
    ).process(context: exContext);

    handler.resolve(Response(
      data: jsonDecode(resData),
      requestOptions: options,
      statusCode: statusCode,
    ));
  }

  String _replaceVarObjs(String resData, Map<String, dynamic>? vars) {
    if (vars == null || vars.isEmpty) {
      return resData;
    }
    for (var element in vars.entries) {
      var vKey = element.key;
      var vValue = element.value;
      if (vValue is Iterable || vValue is Map) {
        resData = resData.replaceAll(
            RegExp(r'"\$\{' + vKey + '\}"'), json.encode(vValue));
      }
    }
    return resData;
  }

  String _templateData(
      Map<String, dynamic> template, Map<String, dynamic> exContext) {
    var content = template['content'];
    if (content == null) {
      return "{}";
    }

    int? size = template['size'];
    String sContent = json.encode(content);

    var exTemplate = Template(
      syntax: [_exSyntax],
      value: sContent,
    );

    if (size == null) {
      exContext.putIfAbsent('index', () => 0);
      return exTemplate.process(context: exContext);
    }

    String joinString = List.generate(size, (index) {
      exContext.addAll({'index': index});
      return exTemplate.process(context: exContext);
    }).join(",");
    return "[$joinString]";
  }
}

class HistoryItem {
  final String method;
  final String path;
  final dynamic data;
  final dynamic queryParameters;

  HistoryItem(this.method, this.path, this.data, this.queryParameters);
}
