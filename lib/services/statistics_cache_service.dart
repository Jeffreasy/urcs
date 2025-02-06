class StatisticsCacheService {
  final _cache = <String, dynamic>{};
  final _cacheTimeout = const Duration(minutes: 5);
  final _cacheTimestamps = <String, DateTime>{};

  T? get<T>(String key) {
    final timestamp = _cacheTimestamps[key];
    if (timestamp == null) return null;

    if (DateTime.now().difference(timestamp) > _cacheTimeout) {
      _cache.remove(key);
      _cacheTimestamps.remove(key);
      return null;
    }

    return _cache[key] as T?;
  }

  void set<T>(String key, T value) {
    _cache[key] = value;
    _cacheTimestamps[key] = DateTime.now();
  }

  void clear() {
    _cache.clear();
    _cacheTimestamps.clear();
  }
}
