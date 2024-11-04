# Flutter Dio Mock Interceptor

_Forked from [Flutter Dio Mock Interceptor](https://github.com/yongxin-tech/Flutter_Dio_Mock_Interceptor)_

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://github.com/yongxin-tech/Flutter_Dio_Mock_Interceptor/blob/63d859aba8b999b9e62431c5675a8bfa312667ae/LICENSE) [![Publish to pub.dev](https://github.com/Listo-Paye/dio_mocked_responses/actions/workflows/publish.yaml/badge.svg)](https://github.com/Listo-Paye/dio_mocked_responses/actions/workflows/publish.yaml)

# Environment

The widget was only tested on following environment,
* Flutter: 3.24+ (with sound null safety)
* Dio: 5.0.0+

# Usage

Add interceptor to Dio
```dart
    final dio = Dio()
      ..interceptors.add(
        MockInterceptor(
          basePath: 'test/dio_responses',
        ),
      );
```

`basePath` is the path to the folder containing the mock responses. The path is relative to the root of the assets folder.
His default value is `test/dio_responses`.

By example, if you want to test your backend API for the route `api/client/55036c03-6d3f-4053-9547-c08a32ac9aca/contacts`, create the file at `test/dio_responses/api/client/55036c03-6d3f-4053-9547-c08a32ac9aca/contacts.json` with:
  
  ```json
{
  "GET": {
    "statusCode": 200,
    "data": {
      "contacts": [
        {
          "id": 1,
          "name": "Seth Ladd"
        },
        {
          "id": 2,
          "name": "Eric Seidel"
        }
      ]
    }
  }
}
  ```

* For this example:
```dart
test('Load file with Interceptor', () async {
    final dio = Dio()
    ..interceptors.add(
    MockInterceptor(basePath: 'test/dio_responses'),
    );
    
    final response = await dio.get<Map<String, dynamic>>(
    'api/client/55036c03-6d3f-4053-9547-c08a32ac9aca/contacts',
    );
    expect(response.statusCode, equals(200));
    expect(response.data, isNotNull);
    final contacts = response.data!['contacts'];
    
    final seth = contacts.first;
    expect(seth['id'], 1);
    expect(seth['name'], 'Seth Ladd');
    
    final eric = contacts.last;
    expect(eric['id'], 2);
    expect(eric['name'], 'Eric Seidel');
});
```

* Template example:
```json
{
  "POST": {
    "statusCode": 200,
    "template": {
      "size": 100000,
      "content": {
        "id": "test${index}",
        "name": "name_${index}"
      }
    }
  }
}
```

## Get history
You can get the history of requests with the `history` property of the interceptor.

```dart
Future<void> aCallWasMadeWithData(
    WidgetTester tester,
    String verb,
    String path,
    bdd.DataTable dataTable,
    ) async {
  expect(
      MockInterceptor.history.where((p) => p.method == verb && p.path == path),
      hasLength(1));
}
```

## Contextualised responses

You can contextualize the responses by adding the `context` parameter to the interceptor.

```dart
Future<void> myContextIs(WidgetTester tester, String ctx) async {
  MockInterceptor.setContext(ctx);
}
```

When you set the context, the interceptor will look for the file with the same name as the context in the folder of the response.

For example, if you set the context as 'test', the interceptor will look for the file `test/dio_responses/api/client/55036c03-6d3f-4053-9547-c08a32ac9aca/contacts/test.json`.

If 'test' is not found, the interceptor will look for the file `test/dio_responses/api/client/55036c03-6d3f-4053-9547-c08a32ac9aca/contacts.json`.

To remove the context, you can call `MockInterceptor.clearContext()`.

# License

This project is licensed under the MIT License - see the [LICENSE](https://github.com/yongxin-tech/Flutter_Dio_Mock_Interceptor/blob/63d859aba8b999b9e62431c5675a8bfa312667ae/LICENSE) file for details.

> Copyright (c) 2024-present [Listo Paye](https://listo.pro/)
> 
> Copyright (c) 2023-present [Yong-Xin Technology Ltd.](https://yong-xin.tech/)
