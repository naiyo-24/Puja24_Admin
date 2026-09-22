import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();
  try {
    final res = await dio.get('http://192.168.0.78:8000/admin/places?limit=5');
    for (var place in res.data) {
      if (place['type'] == 'pandal' || place['type'] == 'PANDAL') {
        print("Name: \${place['name']}");
        print("Meta: \${place['place_metadata']}");
        print("Meta type: \${place['place_metadata'].runtimeType}");
      }
    }
  } catch (e) {
    print(e);
  }
}
