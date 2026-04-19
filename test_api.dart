import 'dart:convert';
import 'dart:io';

void main() async {
  final request = await HttpClient().getUrl(Uri.parse('https://ruzsalah-backend-production.up.railway.app/api/prayer/times?date=19-04-2026'));
  final response = await request.close();
  final byteStr = await response.transform(utf8.decoder).join();
  print(byteStr);
}
