import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkService {
  static Future<bool> isConnected() async {
    final results = await Connectivity().checkConnectivity();
    // connectivity_plus returns a list of results in newer versions
    if (results.isEmpty) return false;
    return !results.contains(ConnectivityResult.none);
  }
}
