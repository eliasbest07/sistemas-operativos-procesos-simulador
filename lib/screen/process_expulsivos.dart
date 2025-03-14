import 'package:flutter/material.dart';
import 'package:sistema_operativos/screen/grafica.dart';
import 'package:sistema_operativos/screen/home.dart';
import 'package:sistema_operativos/screen/widget/process_brown.dart';
import 'package:sistema_operativos/screen/widget/process_orange.dart';
import 'package:sistema_operativos/screen/widget/process_yellow.dart';


class ExclusivoProcessScreen extends StatefulWidget {
  @override
  _ExclusivoProcessScreenState createState() => _ExclusivoProcessScreenState();
}

class _ExclusivoProcessScreenState extends State<ExclusivoProcessScreen> {
  int _selectedIndex = 0;
  PageController _pageController = PageController();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Procesos Expulsivos'),
        
         leading: IconButton(onPressed: (){
        Navigator.push(context, MaterialPageRoute(builder: (context) {
              return PerformanceGraph();
            },));
        }, icon: Icon(Icons.bar_chart_rounded)),
        actions: [
                    IconButton(onPressed: (){

            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
              return HomeScreen();
            },));
          }, icon: Icon(Icons.arrow_forward_ios_rounded,color: Colors.black,))
        ],
      ),
      body: Column(
        children: [
            Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('Presiona en ', style: TextStyle(fontSize: 18),),
                Icon(Icons.arrow_forward_ios_rounded),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text('Para ir al simulador de Procesos No Expulsivos', style: TextStyle(fontSize: 18),)),
              ],
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              children: const [
               RoundRobinVisualization(),
               SRTFVisualization(),
               PrioritySchedulingVisualization()
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blue,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Round Robin'),
          BottomNavigationBarItem(icon: Icon(Icons.safety_check), label: 'SRTF'),
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_customize), label: 'Priority'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
