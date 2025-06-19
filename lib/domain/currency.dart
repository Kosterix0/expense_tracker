enum Currency { PLN, EUR, USD }

extension CurrencyExtension on Currency {
  String get code {
    switch (this) {
      case Currency.PLN:
        return 'PLN';
      case Currency.EUR:
        return 'EUR';
      case Currency.USD:
        return 'USD';
    }
  }

  String get name {
    switch (this) {
      case Currency.PLN:
        return 'Polish złoty';
      case Currency.EUR:
        return 'Euro';
      case Currency.USD:
        return 'US Dollar';
    }
  }

  String get symbol {
    switch (this) {
      case Currency.PLN:
        return 'zł';
      case Currency.EUR:
        return '€';
      case Currency.USD:
        return '\$';
    }
  }
}
