/// HistoryItem class
///
/// This class is used to store the history of requests made to the server.
class HistoryItem {
  /// The HTTP method used in the request.
  final String method;

  /// The path of the request.
  final String path;

  /// The data sent in the request.
  final dynamic data;

  /// The query parameters of the request.
  final dynamic queryParameters;

  HistoryItem(this.method, this.path, this.data, this.queryParameters);
}
