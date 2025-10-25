# Flutter Dio Mocked Responses

_Forked from [Flutter Dio Mock Interceptor](https://github.com/yongxin-tech/Flutter_Dio_Mock_Interceptor)_
Transferred from [Listo Paye](https://listo.pro/)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://github.com/yongxin-tech/Flutter_Dio_Mock_Interceptor/blob/63d859aba8b999b9e62431c5675a8bfa312667ae/LICENSE) [![Publish to pub.dev](https://github.com/Listo-Paye/dio_mocked_responses/actions/workflows/publish.yaml/badge.svg)](https://github.com/Listo-Paye/dio_mocked_responses/actions/workflows/publish.yaml)

# dio_mocked_responses

`dio_mocked_responses` is a Flutter package designed to mock HTTP responses for testing purposes. It intercepts HTTP requests made using the Dio package and returns mocked responses based on predefined JSON files. This package helps in isolating and testing features of your application without relying on external services.

## Features
- Intercept and mock HTTP requests.
- Configure persona-based and context-based responses.
- Support for template-based dynamic responses.
- Track request history.
- Easy integration with the Dio package.

## Installation
Add `dio_mocked_responses` to your `pubspec.yaml`:
```shell
flutter pub add dev:dio_mocked_responses 
```

## Usage
### Basic Setup
1. Import the package:
```dart
import 'package:dio_mocked_responses/dio_mocked_responses.dart';
```

2. Create a `MockInterceptor` instance:
```dart
final dio = Dio();
dio.interceptors.add(MockInterceptor(basePath: 'test/mocks')); // Specify the base path to your mock files
```

3. Define your mock response files:
   Mock response files are JSON files stored in the `basePath` directory. The directory structure can be personalized using personas or contexts.

Example file structure:
```
/test/mocks/
  GET_user_profile.json
  POST_login.json
  admin/
    GET_dashboard.json
```
Each JSON file should define the HTTP method, status code, response data, and optional templates. Example:
```json
{
  "GET": {
    "statusCode": 200,
    "data": {
      "id": 1,
      "name": "John Doe"
    }
  },
  "POST": {
    "statusCode": 201,
    "template": {
      "content": {"message": "Welcome, ${req.data.username}!"}
    }
  }
}
```

### Adding Personas
Personas allow you to create mock responses tailored to specific roles or users. To set a persona:
```dart
MockInterceptor.setPersona('admin');
```
The interceptor will look for files in the corresponding `admin/` subdirectory.

To clear a persona:
```dart
MockInterceptor.clearPersona();
```

### Adding Contexts
Contexts add another layer of customization for responses. For example, you can define responses specific to a certain application state:
```dart
MockInterceptor.setContext('logged_in');
```
The interceptor will prioritize files with the context name.

To clear a context:
```dart
MockInterceptor.clearContext();
```

### Query Parameters
Query parameters are automatically parsed and can influence the mocked response. If your endpoint has query parameters, ensure the filename reflects them by replacing special characters with `_`.

Example:
```
GET_user_profile?role=admin -> GET_user_profile_role_admin.json
```

### Dynamic Responses with Templates
Templates enable the generation of dynamic responses based on request data or predefined variables. Use the `template` key in your mock file to define dynamic responses.

Example:
```json
{
  "GET": {
    "statusCode": 200,
    "template": {
      "content": {
        "greeting": "Hello, ${req.queryParameters.name}!"
      }
    }
  }
}
```
This generates a response where the greeting dynamically includes the `name` query parameter from the request.

### Tracking Request History
You can access the history of intercepted requests:
```dart
final history = MockInterceptor.history;
history.forEach((item) {
  print('Method: ${item.method}, Path: ${item.path}');
});
```
To clear the history:
```dart
MockInterceptor.clearHistory();
```

## Error Handling
If a file or route is not found, the interceptor will reject the request with a `DioException`:
```dart
DioException: Can't find file: test/mocks/GET_user_profile.json
```
Ensure that your mock files are correctly structured and accessible from the specified `basePath`.

## Example Test
Here is a complete example of using `dio_mocked_responses` in a test:
```dart
import 'package:dio/dio.dart';
import 'package:dio_mocked_responses/dio_mocked_responses.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Dio dio;

  setUp(() {
    dio = Dio();
    dio.interceptors.add(MockInterceptor(basePath: 'test/mocks'));
  });

  test('GET user profile', () async {
    final response = await dio.get('/user/profile');
    expect(response.statusCode, 200);
    expect(response.data['name'], 'John Doe');
  });
}
```

## Contribution
Feel free to submit issues, feature requests, or pull requests to improve this package. Contributions are welcome!
More on [CONTRIBUTING.md](./CONTRIBUTING.md) file.

# License

This project is licensed under the MIT License - see the [LICENSE](https://github.com/yongxin-tech/Flutter_Dio_Mock_Interceptor/blob/63d859aba8b999b9e62431c5675a8bfa312667ae/LICENSE) file for details.

> Copyright (c) 2025 [Listo Paye](https://listo.pro/)
> 
> Copyright (c) 2023 [Yong-Xin Technology Ltd.](https://yong-xin.tech/)
