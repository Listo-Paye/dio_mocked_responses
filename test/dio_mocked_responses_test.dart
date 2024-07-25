import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio_mocked_responses/dio_mocked_responses.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Test', () {
    expect(1, 1);
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
}
