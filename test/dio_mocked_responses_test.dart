import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio_mocked_responses/dio_mocked_responses.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("Vanilla", () {
    setUp(() {
      MockInterceptor.clearPersona();
      MockInterceptor.clearContext();
    });

    test('Load a file directly', () async {
      final file = File(
        'test/dio_responses/api/client/55036c03-6d3f-4053-9547-c08a32ac9aca/contacts.json',
      );
      final json = jsonDecode(await file.readAsString());
      final contacts = json['GET']['data']['contacts'];

      final seth = contacts.first;
      expect(seth['id'], 1);
      expect(seth['name'], 'Seth Ladd');

      final eric = contacts.last;
      expect(eric['id'], 2);
      expect(eric['name'], 'Eric Seidel');
    });

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

    test('Load file with Interceptor and query params', () async {
      final dio = Dio()
        ..interceptors.add(
          MockInterceptor(basePath: 'test/dio_responses'),
        );

      final response = await dio.get<Map<String, dynamic>>(
        'api/client/55036c03-6d3f-4053-9547-c08a32ac9aca/contacts?only=1',
      );
      expect(response.statusCode, equals(200));
      expect(response.data, isNotNull);
      final contacts = response.data!['contacts'];

      final seth = contacts.first;
      expect(seth['id'], 1);
      expect(seth['name'], 'Seth Ladd');

      expect(contacts, hasLength(1));
    });

    test('Use context', () async {
      final dio = Dio()
        ..interceptors.add(
          MockInterceptor(basePath: 'test/dio_responses'),
        );

      MockInterceptor.setContext('demo');

      final response = await dio.get<Map<String, dynamic>>(
        'api/client/55036c03-6d3f-4053-9547-c08a32ac9aca/contacts?only=1',
      );
      expect(response.statusCode, equals(200));
      expect(response.data, isNotNull);
      final contacts = response.data!['contacts'];

      final seth = contacts.first;
      expect(seth['id'], 2);
      expect(seth['name'], 'Seth Ladd');

      expect(contacts, hasLength(1));
      MockInterceptor.clearContext();
    });
  });

  group("Without Persona", () {
    test('Load file with Interceptor', () async {
      final dio = Dio()
        ..interceptors.add(
          MockInterceptor(basePath: 'test/dio_responses'),
        );
      MockInterceptor.setPersona('user');

      final response = await dio.get<Map<String, dynamic>>(
        'api/client/55036c03-6d3f-4053-9547-c08a32ac9aca/contacts',
      );
      expect(response.statusCode, equals(200));
      expect(response.data, isNotNull);
      final contacts = response.data!['contacts'];

      final seth = contacts.first;
      expect(seth['id'], 4);
      expect(seth['name'], 'Seth Ladd');

      final eric = contacts.last;
      expect(eric['id'], 5);
      expect(eric['name'], 'Eric Seidel');
      MockInterceptor.clearPersona();
    });

    test('Load file with Interceptor and query params', () async {
      final dio = Dio()
        ..interceptors.add(
          MockInterceptor(basePath: 'test/dio_responses'),
        );
      MockInterceptor.setPersona('user');

      final response = await dio.get<Map<String, dynamic>>(
        'api/client/55036c03-6d3f-4053-9547-c08a32ac9aca/contacts?only=1',
      );
      expect(response.statusCode, equals(200));
      expect(response.data, isNotNull);
      final contacts = response.data!['contacts'];

      final seth = contacts.first;
      expect(seth['id'], 6);
      expect(seth['name'], 'Seth Ladd');

      expect(contacts, hasLength(1));
      MockInterceptor.clearPersona();
    });

    test('Use context', () async {
      final dio = Dio()
        ..interceptors.add(
          MockInterceptor(basePath: 'test/dio_responses'),
        );
      MockInterceptor.setPersona('user');

      MockInterceptor.setContext('demo');

      final response = await dio.get<Map<String, dynamic>>(
        'api/client/55036c03-6d3f-4053-9547-c08a32ac9aca/contacts?only=1',
      );
      expect(response.statusCode, equals(200));
      expect(response.data, isNotNull);
      final contacts = response.data!['contacts'];

      final seth = contacts.first;
      expect(seth['id'], 3);
      expect(seth['name'], 'Seth Ladd');

      expect(contacts, hasLength(1));
      MockInterceptor.clearPersona();
      MockInterceptor.clearContext();
    });
  });

  group("History", () {
    setUp(() {
      MockInterceptor.clearPersona();
      MockInterceptor.clearContext();
      MockInterceptor.clearHistory();
    });

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

      expect(
        MockInterceptor.history.first.path,
        'api/client/55036c03-6d3f-4053-9547-c08a32ac9aca/contacts',
      );
      expect(
        MockInterceptor.history.first.method,
        'GET',
      );
    });

    test('Load file with Interceptor and query params in path', () async {
      final dio = Dio()
        ..interceptors.add(
          MockInterceptor(basePath: 'test/dio_responses'),
        );

      final response = await dio.get<Map<String, dynamic>>(
        'api/client/55036c03-6d3f-4053-9547-c08a32ac9aca/contacts?only=1',
      );
      expect(response.statusCode, equals(200));
      expect(response.data, isNotNull);
      final contacts = response.data!['contacts'];

      final seth = contacts.first;
      expect(seth['id'], 1);
      expect(seth['name'], 'Seth Ladd');

      expect(contacts, hasLength(1));

      expect(
        MockInterceptor.history.first.path,
        'api/client/55036c03-6d3f-4053-9547-c08a32ac9aca/contacts?only=1',
      );
      expect(
        MockInterceptor.history.first.method,
        'GET',
      );
      var qp =
          MockInterceptor.history.first.queryParameters as Map<String, dynamic>;
      expect(qp.length, 1);
      expect(qp.entries.first.key, 'only');
      expect(qp.entries.first.value, '1');
    });

    test('Load file with Interceptor and query params not in path', () async {
      final dio = Dio()
        ..interceptors.add(
          MockInterceptor(basePath: 'test/dio_responses'),
        );

      final response = await dio.get<Map<String, dynamic>>(
        'api/client/55036c03-6d3f-4053-9547-c08a32ac9aca/contacts',
        queryParameters: {'only': '1'},
      );
      expect(response.statusCode, equals(200));
      expect(response.data, isNotNull);
      final contacts = response.data!['contacts'];

      final seth = contacts.first;
      expect(seth['id'], 1);
      expect(seth['name'], 'Seth Ladd');

      expect(contacts, hasLength(1));

      expect(
        MockInterceptor.history.first.path,
        'api/client/55036c03-6d3f-4053-9547-c08a32ac9aca/contacts?only=1',
      );
      expect(
        MockInterceptor.history.first.method,
        'GET',
      );

      var qp =
          MockInterceptor.history.first.queryParameters as Map<String, dynamic>;
      expect(qp.length, 1);
      expect(qp.entries.first.key, 'only');
      expect(qp.entries.first.value, '1');
    });

    test('Load file with Interceptor, query params and data', () async {
      final dio = Dio()
        ..interceptors.add(
          MockInterceptor(basePath: 'test/dio_responses'),
        );

      final response = await dio.post(
        'api/client/55036c03-6d3f-4053-9547-c08a32ac9aca/contacts',
        queryParameters: {'only': '1'},
        data: [
          {'name': 'Seth Ladd'}
        ],
      );
      expect(response.statusCode, equals(200));
      expect(response.data, isNull);

      expect(
        MockInterceptor.history.first.path,
        'api/client/55036c03-6d3f-4053-9547-c08a32ac9aca/contacts?only=1',
      );
      expect(
        MockInterceptor.history.first.method,
        'POST',
      );

      final qp =
          MockInterceptor.history.first.queryParameters as Map<String, dynamic>;
      expect(qp.length, 1);
      expect(qp.entries.first.key, 'only');
      expect(qp.entries.first.value, '1');

      final data = MockInterceptor.history.first.data as List<dynamic>;
      expect(data, hasLength(1));
      expect(data.first as Map<String, dynamic>, {'name': 'Seth Ladd'});
    });
  });
}
