library;

//ignore_for_file:  prefer_interpolation_to_compose_strings,unnecessary_string_escapes

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio_mocked_responses/history_item.dart';
import 'package:dio_mocked_responses/mock_configuration.dart';
import 'package:template_expressions_4/template_expressions.dart';

export 'history_item.dart';

/// MockInterceptor
///
/// This class is used to intercept the requests made by the Dio client and return mocked responses.
///
/// To use this class, you need to add it to the interceptors of the Dio client.
/// ```dart
/// final dio = Dio()
/// dio.interceptors.add(MockInterceptor(basePath: 'test/dio_responses'));
/// ```
/// The [basePath] parameter is the path to the directory where the response files are stored.
/// The response files are JSON files that contain the mocked responses for the requests.
/// The files are stored in a directory structure that matches the path of the requests.
/// For example, the response file for the request 'api/client/contacts' would be stored in the file 'test/dio_responses/api/client/contacts.json'.
/// The response files should contain the mocked response for each HTTP method used in the request.
/// The response files should have the following structure:
/// ```json
/// {
///  "GET": {
///   "statusCode": 200,
///   "data": {
///     "contacts": [
///       {
///         "id": 1,
///         "name": "Seth Ladd"
///       },
///       {
///         "id": 2,
///         "name": "Eric Seidel"
///       }
///     ]
///   }
///  }
///  ```
class MockInterceptor extends Interceptor {
  late final String _basePath;

  MockInterceptor({String basePath = 'test/dio_responses'}) {
    _basePath = basePath.endsWith('/') ? basePath : '$basePath/';
  }

  /// Returns the history of requests made to the server.
  ///
  /// The history is stored in a list of [HistoryItem] objects.
  static List<HistoryItem> get history => MockConfiguration.history;

  /// Sets the persona used to load the files.
  static void setPersona(String persona) {
    MockConfiguration.setPersona(persona);
  }

  /// Clears the persona used to load the files.
  static void clearPersona() {
    MockConfiguration.clearPersona();
  }

  /// Sets the context used to load the files.
  static void setContext(String context) {
    MockConfiguration.setContext(context);
  }

  /// Clears the context used to load the files.
  static void clearContext() {
    MockConfiguration.clearContext();
  }

  /// Clears the history of requests made to the server.
  static void clearHistory() {
    MockConfiguration.clearHistory();
  }

  /// onRequest
  ///
  /// This method is called before the request is sent.
  /// The main purpose of this method is to read the response file and return the mocked response.
  ///
  /// If the file is not found, the method will reject the request with an error.
  /// If the file is found, the method will parse the file and return the mocked response.
  ///
  /// The method will also store the history of the request in the [MockConfiguration.history] list.
  ///
  /// Example of a response file:
  /// ```json
  /// {
  ///  "GET": {
  ///   "statusCode": 200,
  ///   "data": {
  ///     "contacts": [
  ///       {
  ///         "id": 1,
  ///         "name": "Seth Ladd"
  ///       },
  ///       {
  ///         "id": 2,
  ///         "name": "Eric Seidel"
  ///       }
  ///     ]
  ///   }
  ///  }
  ///  ```
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final file = File(
      MockConfiguration.getfilePath(
        MockConfiguration.getFullPath(options),
        _basePath,
      ),
    );

    MockConfiguration.history.add(
      HistoryItem(
        options.method,
        MockConfiguration.getFullPath(options),
        options.data,
        MockConfiguration.getQueryParameters(options),
      ),
    );

    if (!file.existsSync()) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: "Can't find file: ${file.path}",
        ),
      );
      return;
    }

    late final Map<String, dynamic> json;
    try {
      json = jsonDecode(file.readAsStringSync());
    } catch (e) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: "Can't parse file: ${file.path}",
        ),
      );
      return;
    }

    final Map<String, dynamic> route = json[options.method];

    if (route.isEmpty) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: "Can't find route setting: ${options.path}:${options.method}",
        ),
      );
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
      handler.resolve(
        Response(requestOptions: options, statusCode: statusCode),
      );
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
      },
    );

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
        syntax: [MockConfiguration.exSyntax],
        value: resData,
      ).process(context: exContext);

      handler.resolve(
        Response(
          data: resData,
          requestOptions: options,
          statusCode: statusCode,
        ),
      );
      return;
    }

    String resData = jsonEncode(data);

    if (template != null) {
      String tData = _templateData(template, exContext);
      resData = resData.replaceAll(MockConfiguration.regexpTemplate, tData);
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
      syntax: [MockConfiguration.exSyntax],
      value: resData,
    ).process(context: exContext);

    handler.resolve(
      Response(
        data: jsonDecode(resData),
        requestOptions: options,
        statusCode: statusCode,
      ),
    );
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
          RegExp(r'"\$\{' + vKey + '\}"'),
          json.encode(vValue),
        );
      }
    }
    return resData;
  }

  String _templateData(
    Map<String, dynamic> template,
    Map<String, dynamic> exContext,
  ) {
    var content = template['content'];
    if (content == null) {
      return "{}";
    }

    int? size = template['size'];
    String sContent = json.encode(content);

    var exTemplate = Template(
      syntax: [MockConfiguration.exSyntax],
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
