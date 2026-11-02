import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class Stock {
  final String symbol;
  final double price;
  final double dailyChange;

  const Stock({
    required this.symbol,
    required this.price,
    required this.dailyChange,
  });

  Stock copyWith({
    String? symbol,
    double? price,
    double? dailyChange,
  }) {
    return Stock(
      symbol: symbol ?? this.symbol,
      price: price ?? this.price,
      dailyChange: dailyChange ?? this.dailyChange,
    );
  }
}

enum StockAction { Increase, Decrease, Reset }

class StockBloc {
  static const Stock startingStock = Stock(
    symbol: 'AAPL',
    price: 100.0,
    dailyChange: 0.0,
  );

  final _inputController = StreamController<StockAction>();
  final _outputController = StreamController<Stock>.broadcast();
  final Random _random = Random();

  Stock _stock = startingStock;

  Stream<Stock> get stream => _outputController.stream;
  Sink<StockAction> get inputSink => _inputController.sink;
  Stock get currentStock => _stock;

  StockBloc() {
    _inputController.stream.listen((action) {
      double newPrice = _stock.price;

      switch (action) {
        case StockAction.Increase:
          newPrice += _random.nextDouble() * 2;
          break;

        case StockAction.Decrease:
          newPrice -= _random.nextDouble() * 2;

          if (newPrice < 0) {
            newPrice = 0;
          }
          break;

        case StockAction.Reset:
          newPrice = startingStock.price;
          break;
      }

      _stock = _stock.copyWith(
        price: newPrice,
        dailyChange: newPrice - startingStock.price,
      );

      _outputController.sink.add(_stock);
    });
  }

  Future<void> dispose() async {
    await _inputController.close();
    await _outputController.close();
  }
}


class StockApp extends StatefulWidget {
  const StockApp({super.key});

  @override
  State<StockApp> createState() => _StockAppState();
}

class _StockAppState extends State<StockApp> {
  final StockBloc bloc = StockBloc();

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StockPage(bloc: bloc),
    );
  }
}

class StockPage extends StatelessWidget {
  final StockBloc bloc;

  const StockPage({super.key, required this.bloc});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Market'),
      ),
      body: StreamBuilder<Stock>(
        stream: bloc.stream,
        initialData: bloc.currentStock,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final Stock stock = snapshot.data!;
          Color priceColor = Colors.grey;

          if (stock.dailyChange > 0) {
            priceColor = Colors.green;
          } else if (stock.dailyChange < 0) {
            priceColor = Colors.red;
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  stock.symbol,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(height: 12),
                Text(
                  '\$${stock.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 40,
                    color: priceColor,
                  ),
                ),
                Text(
                  'Daily change: '
                  '\$${stock.dailyChange.toStringAsFixed(2)}',
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    bloc.inputSink.add(StockAction.Increase);
                  },
                  child: const Text('Bull Market'),
                ),
                ElevatedButton(
                  onPressed: () {
                    bloc.inputSink.add(StockAction.Decrease);
                  },
                  child: const Text('Bear Market'),
                ),
                ElevatedButton(
                  onPressed: () {
                    bloc.inputSink.add(StockAction.Reset);
                  },
                  child: const Text('Reset'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

void main() {
  runApp(const StockApp());
}
