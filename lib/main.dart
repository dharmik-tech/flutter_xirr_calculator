import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.teal,
        hintColor: Colors.tealAccent,
        fontFamily: 'Roboto',
      ),
      home: XIRRScreen(),
    );
  }
}

class XIRRScreen extends StatefulWidget {
  @override
  _XIRRScreenState createState() => _XIRRScreenState();
}

class _XIRRScreenState extends State<XIRRScreen> {
  List<TextEditingController> cashflowControllers = [];
  List<DateTime?> dates = [];
  List<String> transactionTypes = [];
  TextEditingController finalCashflowController = TextEditingController();

  // TextEditingController initialInvestmentController = TextEditingController();
  // TextEditingController finalInvestmentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Sample data for initialization
    cashflowControllers.addAll([
      TextEditingController(),
      TextEditingController(),
    ]);
    dates.addAll([null, null]); // Initialize with null dates
    transactionTypes.addAll(
        ["Deposit", "Deposit"]); // Initialize with Deposit transaction types
  }

  // double calculateXIRR(
  //   List<double> cashflows,
  //   List<DateTime?> dates,
  // ) {
  //   // Adjust the cashflows to include initial and final investments
  //   // cashflows.insert(0, -initialInvestment);
  //   // cashflows.add(finalInvestment);
  //   developer.log('cashflow $cashflows');
  //   developer.log('dates $dates');
  //
  //   assert(cashflows.length == dates.length,
  //       "Cashflows and dates should have the same length.");
  //
  //   double guess = 0.1; // Initial guess for XIRR
  //   double guessNext = 0.2; // Initial guess for the next iteration
  //   double precision = 0.00001; // Desired precision for the XIRR result
  //
  //   for (int i = 0; i < 1000; i++) {
  //     // Perform up to 1000 iterations (can be adjusted as needed)
  //     double sum = 0.0;
  //     for (int j = 0; j < cashflows.length; j++) {
  //       double t =
  //           ((j == 0) ? 0.0 : dates[j - 1]?.difference(dates[0]!).inDays ?? 0) /
  //               365;
  //       sum += cashflows[j] / pow(1 + guess, t);
  //     }
  //
  //     double derivativeSum = 0.0;
  //     for (int j = 0; j < cashflows.length; j++) {
  //       double t =
  //           ((j == 0) ? 0.0 : dates[j - 1]?.difference(dates[0]!).inDays ?? 0) /
  //               365;
  //       derivativeSum += (-t * cashflows[j]) / pow(1 + guess, t + 1);
  //     }
  //
  //     guessNext = guess - (sum / derivativeSum);
  //
  //     if ((guessNext - guess).abs() <= precision) {
  //       return guessNext;
  //     }
  //
  //     guess = guessNext;
  //   }
  //
  //   // Return NaN if the XIRR calculation does not converge after the maximum iterations
  //   return double.nan;
  // }

  double calculateXIRR(List<double> cashFlows, List<DateTime?> dates) {
    if (cashFlows.length != dates.length) {
      throw ArgumentError(
          "The number of cash flows must match the number of dates.");
    }

    int maxIterations = 100;
    double epsilon = 1e-8; // The desired precision of the XIRR calculation
    double guess = 0.1; // Initial guess for XIRR

    for (int i = 0; i < maxIterations; i++) {
      double xirr = guess;
      double d1 = 0.0, d2 = 0.0;

      for (int j = 0; j < cashFlows.length; j++) {
        double days = dates[j]!.difference(dates[0]!).inDays / 365.0;
        d1 += cashFlows[j] / pow(1.0 + xirr, days);
        d2 += -days * cashFlows[j] / pow(1.0 + xirr, days + 1.0);
      }

      double newGuess = guess - d1 / d2;

      if ((newGuess - guess).abs() < epsilon) {
        return newGuess;
      }

      guess = newGuess;
    }

    throw Exception(
        "XIRR calculation did not converge after $maxIterations iterations.");
  }

  void _calculateXIRR() {
    List<double> cashflows = cashflowControllers
        .map((controller) => double.tryParse(controller.text) ?? 0.0)
        .toList();

    if (cashflows.isEmpty || dates.isEmpty) {
      _showErrorDialog("Please enter cashflows and dates.");
      return;
    }

    // double initialInvestment = double.tryParse(initialInvestmentController.text) ?? 0.0;
    // double finalInvestment = double.tryParse(finalInvestmentController.text) ?? 0.0;

    // if (initialInvestment == 0.0) {
    //   _showErrorDialog("Please enter the initial investment.");
    //   return;
    // }
    //
    // if (finalInvestment == 0.0) {
    //   _showErrorDialog("Please enter the final investment.");
    //   return;
    // }

    // Adjust cashflow values based on transaction type (deposit or withdrawal)
    for (int i = 0; i < cashflows.length; i++) {
      if (transactionTypes[i] == "Withdraw") {
        cashflows[i] = -cashflows[i];
      }
    }

    double xirr = calculateXIRR(cashflows, dates);
    _showResultDialog(xirr);
  }

  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showResultDialog(double xirr) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('XIRR Result'),
          content: Text(
            'Your return is : ${(xirr * 100).round().toStringAsFixed(2)} %',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context, int index) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dates[index] ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        dates[index] = picked;
      });
    }
  }

  void _addNewRow() {
    setState(() {
      cashflowControllers.add(TextEditingController());
      dates.add(null); // Add a null date for the new row
      transactionTypes.add("Deposit"); // Add a default value for the new row
    });
  }

  void _removeRow(int index) {
    setState(() {
      cashflowControllers.removeAt(index);
      dates.removeAt(index);
      transactionTypes.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('XIRR Calculator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // TextField(
            //   controller: initialInvestmentController,
            //   keyboardType: TextInputType.numberWithOptions(decimal: true),
            //   decoration: InputDecoration(labelText: 'Initial Investment'),
            // ),
            // SizedBox(height: 16),
            // TextField(
            //   controller: finalInvestmentController,
            //   keyboardType: TextInputType.numberWithOptions(decimal: true),
            //   decoration: InputDecoration(labelText: 'Final Investment'),
            // ),
            // SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: cashflowControllers.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: cashflowControllers[index],
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 8),
                                  hintStyle: const TextStyle(color: Colors.black12),
                                  border: const OutlineInputBorder(),
                                  isDense: true,
                                  labelStyle: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                  labelText: 'Cashflow ${index + 1}'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // dates[index] != null
                          //     ?
                          InkWell(
                            onTap: () {
                              _selectDate(context, index);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                  borderRadius: BorderRadius.circular(4)),
                              child: Text(
                                  dates[index] != null
                                      ? DateFormat('yyyy/MM/dd')
                                          .format(dates[index]!)
                                      : 'Select Date',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary)),
                            ),
                          ),

                          const SizedBox(width: 8),
                          DropdownButton<String>(
                            value: transactionTypes[index],
                            onChanged: (String? newValue) {
                              setState(() {
                                transactionTypes[index] = newValue!;
                              });
                            },
                            items: <String>['Deposit', 'Withdraw']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () => _removeRow(index),
                            icon: const Icon(Icons.delete),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _addNewRow,
              child: const Text('Add Row'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _calculateXIRR,
              child: const Text('Calculate XIRR'),
            ),
          ],
        ),
      ),
    );
  }
}
