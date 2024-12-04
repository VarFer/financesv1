import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'database_service.dart'; 

class FinanzasStats extends StatefulWidget {
  const FinanzasStats({super.key});

  @override
  FinanzasStatsState createState() => FinanzasStatsState();
}

class FinanzasStatsState extends State<FinanzasStats> {
  double totalIngresos = 0.0;
  double totalGastos = 0.0;
  double totalDeudas = 0.0;

  @override
  void initState() {
    super.initState();
    obtenerEstadisticas();
  }

  Future<void> obtenerEstadisticas() async {
    totalIngresos = await DatabaseService.getTotalIngresos();
    totalGastos = await DatabaseService.getTotalGastos();
    totalDeudas = await DatabaseService.getTotalDeudas();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas Financieras'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SfCircularChart(
              series: <CircularSeries>[
                PieSeries<ChartData, String>(
                  dataSource: [
                    ChartData('Ingresos', totalIngresos),
                    ChartData('Gastos', totalGastos),
                    ChartData('Deudas', totalDeudas),
                  ],
                  xValueMapper: (ChartData data, _) => data.category,
                  yValueMapper: (ChartData data, _) => data.value,
                  dataLabelSettings: const DataLabelSettings(isVisible: true),
                )
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Ingresos: \$${totalIngresos.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 20),
            ),
            Text(
              'Gastos: \$${totalGastos.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 20),
            ),
            Text(
              'Deudas: \$${totalDeudas.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}

class ChartData {
  ChartData(this.category, this.value);
  final String category;
  final double value;
}
