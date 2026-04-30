abstract class RemoteDataSource<T> {
  Future<T> fetch(String key);
}
