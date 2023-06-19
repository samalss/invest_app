import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'Project.dart';

class AnalyticsPage extends StatefulWidget {
  final String userId;

  AnalyticsPage({required this.userId});

  @override
  _AnalyticsPageState createState() => _AnalyticsPageState();
}
  String money(int amount){
  return NumberFormat('###,###', 'en_US').format(int.parse(amount.toStringAsFixed(0))).replaceAll(',', ' ');
  }
class _AnalyticsPageState extends State<AnalyticsPage> {
  Future<List<Project>>? _projectsFuture;
  final customTextStyle = TextStyle(fontSize: 20,);
  int incomePerMonth = 0;
  int totalIncome = 0;

  @override
  void initState() {
    super.initState();
    _projectsFuture = fetchProjects(widget.userId);
  }

  Future<List<Project>> fetchProjects(String userId) async {
    final projectIdsSnapshot = await FirebaseFirestore.instance
        .collection('investments')
        .where('userId', isEqualTo: userId)
        .get();

    final projectIds = projectIdsSnapshot.docs.map((doc) => doc['projectId'])
        .toList();

    final projects = await Future.wait(
      projectIds.map((projectId) async {
        final projectSnapshot = await FirebaseFirestore.instance
            .collection('projects')
            .doc(projectId)
            .get();

        final querySnapshot = await FirebaseFirestore.instance
            .collection('investments')
            .where('userId', isEqualTo: userId)
            .where('projectId', isEqualTo: projectId)
            .limit(1)
            .get();

        final investmentDoc = querySnapshot.docs.first;

        final investDetailsSnapshot = await FirebaseFirestore.instance
            .collection('investments')
            .doc(investmentDoc.id)
            .collection('investDetails')
            .get();


        final _totalInvestment = investDetailsSnapshot.docs.fold<double>(
          0,
              (sum, doc) => sum + doc['amount'],
        );

        final project = Project.forAnalytic(
          userId: userId,
          projectId: projectId,
          projectName: projectSnapshot['project_name'],
          total: _totalInvestment,
          project_created_date: projectSnapshot['project_created_date'],
          projectCurrentCost: projectSnapshot['project_current_cost'],
          projectDescription: projectSnapshot['project_description'],
          projectTotalCost: projectSnapshot['project_total_cost'],
          verified: projectSnapshot['verified'],
          verification_documents: projectSnapshot['verification_documents'],
          interest: projectSnapshot['interest'],
          short_description: projectSnapshot['short_description'],
        );
        print(project);
        return project;
      }),
    );

    return projects;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('In-App Portfolio Analytics'),
      ),
      body: Scaffold(
        body: FutureBuilder<List<Project>>(
          future: _projectsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              final projects = snapshot.data!;
              List<ProjectEarnings> projectEarningsData = [];
              late num income;
              late num total;
              incomePerMonth = 0;
              totalIncome = 0;
              for (int index = 0; index < projects.length; index++) {
                final project = projects[index];
                income = int.parse(
                    ((project.total * ((project.interest + 100) / 100)) / 12)
                        .toStringAsFixed(0));
                total = int.parse(
                    ((project.total * ((project.interest + 100) / 100)))
                        .toStringAsFixed(0));

                projectEarningsData.add(ProjectEarnings(
                  projectName: project.projectName,
                  total: total,
                  income: income,
                ));

                totalIncome += int.parse(total.toString());
                incomePerMonth += int.parse(income.toString());
              };

              return buildChart(projectEarningsData, incomePerMonth);
            } else {
              return Center(child: Text('No projects found'));
            }
          },
        ),

      ),
    );
  }


  Widget buildChart(List<ProjectEarnings> projectEarningsData,
      int incomePerMonth) {
    return SingleChildScrollView(

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SfCartesianChart(
            title: ChartTitle(text: "Income per month on each project"),
            series: <ChartSeries>[
              BarSeries<ProjectEarnings, String>(
                dataSource: projectEarningsData,
                // Your project data source
                xValueMapper: (ProjectEarnings project, _) =>
                project.projectName,
                yValueMapper: (ProjectEarnings project, _) => project.income,
                dataLabelSettings: DataLabelSettings(isVisible: true,
                    textStyle: TextStyle(fontSize: 15),
                    color: Colors.grey[350]),
                borderRadius: BorderRadius.all(Radius.circular(15)),
                color: Colors.deepOrange[300],
              ),
            ],
            primaryXAxis: CategoryAxis(
              labelStyle: TextStyle(fontSize: 16),
            ),
            primaryYAxis: NumericAxis(
              edgeLabelPlacement: EdgeLabelPlacement.shift,
              labelStyle: TextStyle(fontSize: 15),
            ),
          ),
          SfCartesianChart(
            title: ChartTitle(text: "Total Income on each project"),
            // Chart configuration and data
            series: <ChartSeries>[
              BarSeries<ProjectEarnings, String>(

                dataSource: projectEarningsData,
                // Your project data source
                xValueMapper: (ProjectEarnings project, _) =>
                project.projectName,
                yValueMapper: (ProjectEarnings project, _) => project.total,
                dataLabelSettings: DataLabelSettings(isVisible: true,
                    textStyle: TextStyle(fontSize: 15),
                    color: Colors.grey[350]),
                borderRadius: BorderRadius.all(Radius.circular(15)),
                color: Colors.deepOrange[300],
              ),
            ],
            primaryXAxis: CategoryAxis(
              labelStyle: TextStyle(fontSize: 16),
            ),
            primaryYAxis: NumericAxis(
              edgeLabelPlacement: EdgeLabelPlacement.shift,
              labelStyle: TextStyle(fontSize: 15),
            ),
          ),
          SfCircularChart(
            title: ChartTitle(text: "Total Income per month"),

            legend: Legend(
                isVisible: true,
                overflowMode: LegendItemOverflowMode.scroll,
                title: LegendTitle(textStyle: TextStyle(fontSize: 50,)),
                position: LegendPosition.left
            ),
            series: <CircularSeries>[
              DoughnutSeries<ProjectEarnings, String>(
                dataSource: projectEarningsData,

                xValueMapper: (ProjectEarnings data, _) => data.projectName,
                yValueMapper: (ProjectEarnings data, _) => data.income,
                enableTooltip: true,
                dataLabelSettings: DataLabelSettings(
                  isVisible: true,
                  labelPosition: ChartDataLabelPosition.inside,
                  textStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
            annotations: <CircularChartAnnotation>[
              CircularChartAnnotation(
                widget: Container(
                  child: Text(
                    '${money(incomePerMonth)} KZT',
                    style: TextStyle(
                        fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          SfCircularChart(
            title: ChartTitle(text: "Total Income"),

            legend: Legend(
                isVisible: true,
                overflowMode: LegendItemOverflowMode.scroll,
                position: LegendPosition.left

            ),

            series: <CircularSeries>[
              DoughnutSeries<ProjectEarnings, String>(
                dataSource: projectEarningsData,
                xValueMapper: (ProjectEarnings data, _) => data.projectName,
                yValueMapper: (ProjectEarnings data, _) => data.total,
                enableTooltip: true,
                dataLabelSettings: DataLabelSettings(

                  isVisible: true,
                  labelPosition: ChartDataLabelPosition.inside,
                  textStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
            annotations: <CircularChartAnnotation>[
              CircularChartAnnotation(
                widget: Container(
                  child: Text(
                    '${money(totalIncome)} KZT',
                    style: TextStyle(
                        fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


class ProjectEarnings {
  final String projectName;
  final num total;
  final num income;

  ProjectEarnings({required this.projectName, required this.total, required this.income});
}