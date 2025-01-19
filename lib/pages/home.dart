import 'package:flutter/material.dart';
import 'package:inventaris/modules/data_model.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<GDPData> _chartData;
  late TooltipBehavior _tooltipBehavior;
  int? sudahDitempatkan;
  int? belumDitempatkan;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tooltipBehavior = TooltipBehavior(enable: true);
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      var chartData = await DataModel.getPieChartData();
      var placementCount = await DataModel.getCountPlacement();

      setState(() {
        _chartData = chartData
            .map<GDPData>((data) => GDPData(data['status'], data['count']))
            .toList();
        sudahDitempatkan = placementCount['sudah_count'];
        belumDitempatkan = placementCount['belum_count'];
        isLoading = false;
      });
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Inventory Dashboard'),
          centerTitle: true,
          titleTextStyle: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black),
          backgroundColor: Colors.transparent,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (sudahDitempatkan != null && belumDitempatkan != null)
                      Column(
                        children: [
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "Sudah Ditempatkan: $sudahDitempatkan",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "Belum Ditempatkan: $belumDitempatkan",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    SizedBox(height: 16),
                    Expanded(
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SfCircularChart(
                            title: ChartTitle(
                              text: "Chart Kondisi Barang",
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            legend: Legend(
                              isVisible: true,
                              overflowMode: LegendItemOverflowMode.wrap,
                            ),
                            tooltipBehavior: _tooltipBehavior,
                            series: <CircularSeries>[
                              DoughnutSeries<GDPData, String>(
                                dataSource: _chartData,
                                xValueMapper: (GDPData data, _) =>
                                    data.continent,
                                yValueMapper: (GDPData data, _) => data.gdp,
                                dataLabelSettings: const DataLabelSettings(
                                  isVisible: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class GDPData {
  GDPData(this.continent, this.gdp);
  final String continent;
  final int gdp;
}
