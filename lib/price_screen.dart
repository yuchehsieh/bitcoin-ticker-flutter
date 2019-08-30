import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'coin_data.dart';

const CRYPTO_EXCHANGED_URL =
    'https://apiv2.bitcoinaverage.com/indices/global/ticker/';

/// Example Url -> 'https://apiv2.bitcoinaverage.com/indices/global/ticker/BTCUSD'

class PriceScreen extends StatefulWidget {
  @override
  _PriceScreenState createState() => _PriceScreenState();
}

class _PriceScreenState extends State<PriceScreen> {
  String _selectedCurrency;

  double _btcExchangedRate = 0;
  double _ethExchangedRate = 0;
  double _ltcExchangedRate = 0;

  @override
  void initState() {
    super.initState();
    updateExchangeRate('USD');
  }

  Future<void> updateExchangeRate(String currencyToExchanged) async {
    /// Create multiple Future
    List<Future> cryptoResponses = [];

    cryptoList.forEach((eachCrypto) {
      cryptoResponses.add(
          http.get('$CRYPTO_EXCHANGED_URL$eachCrypto$currencyToExchanged'));
    });

    /// Wait for multiple Future
    List<dynamic> results = await Future.wait(cryptoResponses);

    /// Decode every result
    /// put it in separative variable
    double btcRate;
    double ethRate;
    double ltcRate;

    results.asMap().forEach((i, result) {
      if (result.body.isEmpty) return;
      final decodedResult = jsonDecode(result.body);
      final lastValue = decodedResult['last'];
      if (i == 0) btcRate = lastValue;
      if (i == 1) ethRate = lastValue;
      if (i == 2) ltcRate = lastValue;

      print('$i: $lastValue');
    });

    /// Update each exchanged rate
    /// with the currency
    setState(() {
      _btcExchangedRate = btcRate;
      _ethExchangedRate = ethRate;
      _ltcExchangedRate = ltcRate;
      _selectedCurrency = currencyToExchanged;
    });
  }

  DropdownButton<String> getMaterialDropDown() {
    return DropdownButton<String>(
      hint: Text('Choose a Currency'),
      value: _selectedCurrency,
      style: TextStyle(
        color: Colors.white,
      ),
      items: currenciesList.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: (value) {
        updateExchangeRate(value);
      },
    );
  }

  CupertinoPicker getCupertinoPicker() {
    return CupertinoPicker(
      backgroundColor: Colors.lightBlue,
      onSelectedItemChanged: (int index) {
        updateExchangeRate(currenciesList[index]);
      },
      children: currenciesList.map((item) {
        return Text(item);
      }).toList(),
      itemExtent: 30.0,
    );
  }

  Widget getPicker() {
    return Platform.isIOS ? getCupertinoPicker() : getMaterialDropDown();
  }

  @override
  Widget build(BuildContext context) {
    print(_selectedCurrency);

    return Scaffold(
      appBar: AppBar(
        title: Text('🤑 Coin Ticker'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  CryptoLabel(
                    cryptoCoin: 'BTC',
                    exchangedRate: _btcExchangedRate,
                    selectedCurrency: _selectedCurrency,
                  ),
                  CryptoLabel(
                    cryptoCoin: 'ETH',
                    exchangedRate: _ethExchangedRate,
                    selectedCurrency: _selectedCurrency,
                  ),
                  CryptoLabel(
                    cryptoCoin: 'LTC',
                    exchangedRate: _ltcExchangedRate,
                    selectedCurrency: _selectedCurrency,
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 150.0,
            alignment: Alignment.center,
            padding: EdgeInsets.only(bottom: 30.0),
            color: Colors.lightBlue,
            child: getPicker(),
          ),
        ],
      ),
    );
  }
}

class CryptoLabel extends StatelessWidget {
  const CryptoLabel({
    Key key,
    @required String cryptoCoin,
    @required double exchangedRate,
    @required String selectedCurrency,
  })  : exchangedRate = exchangedRate,
        selectedCurrency = selectedCurrency,
        cryptoCoin = cryptoCoin,
        super(key: key);

  final String cryptoCoin;
  final double exchangedRate;
  final String selectedCurrency;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(18.0, 18.0, 18.0, 0),
      child: Card(
        color: Colors.lightBlueAccent,
        elevation: 5.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 28.0),
          child: Text(
            '1 $cryptoCoin = $exchangedRate $selectedCurrency',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20.0,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
