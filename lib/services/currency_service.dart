import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyService {
  static const String _baseUrl =
      'https://api.nbp.pl/api/exchangerates/rates/a/';

  Future<double> getExchangeRate(String currency) async {
    if (currency == 'PLN') return 1.0;

    final response = await http.get(
      Uri.parse('$_baseUrl$currency?format=json'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['rates'][0]['mid'] as double;
    } else {
      throw Exception(
        'Failed to load exchange rate for $currency',
      );
    }
  }

  Future<double> convert(
    double amount,
    String from,
    String to,
  ) async {
    if (from == to) return amount;

    final fromRate = await getExchangeRate(from);
    final toRate = await getExchangeRate(to);

    return (amount * fromRate) / toRate;
  }
}
