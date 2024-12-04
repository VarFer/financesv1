import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../database/database_service.dart';  // Asegúrate de que este archivo exista y contenga las funciones necesarias

class EstadisticasScreen extends StatefulWidget {
  const EstadisticasScreen({super.key});

  @override
  _EstadisticasScreenState createState() => _EstadisticasScreenState();
}

class _EstadisticasScreenState extends State<EstadisticasScreen> {
  double totalIngresos = 0.0;
  double totalDeudas = 0.0;
  double totalGastos = 0.0;
  double totalRestante = 0.0;

  @override
  void initState() {
    super.initState();
    obtenerEstadisticas();
  }

  // Método para obtener las estadísticas de la base de datos
  Future<void> obtenerEstadisticas() async {
    try {
      totalIngresos = await DatabaseService.getTotalIngresos();
      totalDeudas = await DatabaseService.getTotalDeudas();
      totalGastos = await DatabaseService.getTotalGastos();

      // Calcular el total restante (Ingresos - Gastos + Deudas pagadas)
      double totalDeudasPagadas = await DatabaseService.getTotalPagos();  // Obtener el total de pagos de deudas
      totalRestante = totalIngresos - totalGastos + totalDeudasPagadas;

      setState(() {}); // Actualizamos el estado para reflejar los nuevos valores
    } catch (e) {
      // En caso de error, puedes manejarlo aquí (e.g., mostrar un mensaje al usuario)
      print("Error al obtener las estadísticas: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas Financieras'),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        elevation: 4,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade100, Colors.purple.shade100], // Degradado suave
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'Análisis Financiero',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Estadísticas de ingresos, gastos y deudas.',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              // Gráfico Comparativo: Ingresos, Deudas y Gastos
              Expanded(
                child: SfCartesianChart(
                  primaryXAxis: CategoryAxis(),
                  title: ChartTitle(text: 'GRAFICO COMPARATIVO'),
                  series: <ChartSeries>[
                    BarSeries<BarData, String>(
                      dataSource: [
                        BarData('Ingresos', totalIngresos),
                        BarData('Deudas', totalDeudas),
                        BarData('Gastos', totalGastos),
                      ],
                      xValueMapper: (BarData data, _) => data.category,
                      yValueMapper: (BarData data, _) => data.amount,
                      color: Colors.green,
                      dataLabelSettings: const DataLabelSettings(isVisible: true),  // Mostrar etiquetas
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Gráfico de Total Restante: Ingresos - Gastos + Pagos de Deudas
              Expanded(
                child: SfCartesianChart(
                  primaryXAxis: CategoryAxis(),
                  title: ChartTitle(text: 'TOTAL RESTANTE'),
                  series: <ChartSeries>[
                    BarSeries<BarData, String>(
                      dataSource: [
                        BarData('Total Restante', totalRestante),
                      ],
                      xValueMapper: (BarData data, _) => data.category,
                      yValueMapper: (BarData data, _) => data.amount,
                      color: Colors.blue,  // Color para el total restante
                      dataLabelSettings: const DataLabelSettings(isVisible: true),  // Mostrar etiquetas
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Gráfico de Distribución Porcentual
              Expanded(
                child: SfCircularChart(
                  title: ChartTitle(text: 'DISTRIBUCIÓN PORCENTUAL'),
                  legend: Legend(isVisible: true),
                  series: <CircularSeries>[
                    PieSeries<BarData, String>(
                      dataSource: [
                        BarData('Ingresos', totalIngresos),
                        BarData('Deudas', totalDeudas),
                        BarData('Gastos', totalGastos),
                      ],
                      xValueMapper: (BarData data, _) => data.category,
                      yValueMapper: (BarData data, _) => data.amount,
                      dataLabelSettings: const DataLabelSettings(isVisible: true),  // Mostrar etiquetas
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Clase auxiliar para el gráfico de barras
class BarData {
  final String category;
  final double amount;

  BarData(this.category, this.amount);
}
