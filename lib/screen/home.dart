import 'package:flutter/material.dart';
import 'package:sistema_operativos/screen/grafica.dart';
import 'package:sistema_operativos/screen/process_expulsivos.dart';
import 'package:sistema_operativos/screen/widget/process_blue.dart';
import 'package:sistema_operativos/screen/widget/process_green.dart';
import 'package:sistema_operativos/screen/widget/process_red.dart';
import 'package:sistema_operativos/screen/widget/process_purple.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Function action = () {};
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final GlobalKey<FCFSVisualizationState> fcfsKey = GlobalKey<FCFSVisualizationState>();
  final GlobalKey<SJFVisualizationState> sjfKey = GlobalKey<SJFVisualizationState>();
  final GlobalKey<RandomNonPreemptiveVisualizationState> rafKey = GlobalKey<RandomNonPreemptiveVisualizationState>();
  final GlobalKey<PriorityNonPreemptiveVisualizationState> redKey = GlobalKey<PriorityNonPreemptiveVisualizationState>();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() {
      _currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Simulador de Procesos No expulsivos:'),
        leading: IconButton(onPressed: (){
        Navigator.push(context, MaterialPageRoute(builder: (context) {
              return PerformanceGraph();
            },));
        }, icon: Icon(Icons.bar_chart_rounded)),
        actions: [
          IconButton(onPressed: (){

            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
              return ExclusivoProcessScreen();
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
                  child: Text('Para ir al simulador de Procesos Expulsivos', style: TextStyle(fontSize: 18),)),
              ],
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: [
                FCFSVisualization(
                  key: fcfsKey,
                ),
                SJFVisualization(
                  key: sjfKey,
                ),
                RandomNonPreemptiveVisualization(
                  key: rafKey,
                ),
                PriorityNonPreemptiveVisualization(
                  key: redKey,
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.20, vertical: 20),
        child: Container(
          width: 100,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(200),
            border: Border.all(color: Colors.black, width: 2)
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == 0 ? Colors.blue.withOpacity(0.3) : Colors.white,
                    border: Border.all(
                      width: 2,
                      color: Colors.blue,
                    ),
                  ),
                  child: Center(
                    child: IconButton(
                      onPressed: () {
                        _navigateToPage(0);
                      
                      },
                      icon: Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == 1 ? Colors.purple.withOpacity(0.3) : Colors.white,
                    border: Border.all(
                      width: 2,
                      color: Colors.purple,
                    ),
                  ),
                  child: Center(
                    child: IconButton(
                      onPressed: () {
                        _navigateToPage(1);
                        // Si estamos en la página correcta, agregamos el proceso
                     
                      },
                      icon: Icon(
                        Icons.arrow_circle_up_rounded,
                        color: Colors.purple,
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == 2 ? Colors.green.withOpacity(0.3) : Colors.white,
                    border: Border.all(
                      width: 2,
                      color: Colors.green,
                    ),
                  ),
                  child: Center(
                    child: IconButton(
                      onPressed: () {
                        _navigateToPage(2);
                        // Si estamos en la página correcta, agregamos el proceso
                     
                      },
                      icon: Center(
                        child: Icon(
                          Icons.add,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == 3 ? Colors.red.withOpacity(0.3) : Colors.white,
                    border: Border.all(
                      width: 2,
                      color: Colors.red,
                    ),
                  ),
                  child: IconButton(
                    onPressed: () {
                      _navigateToPage(3);
                      // Si estamos en la página correcta, agregamos el proceso
                    
                    },
                    icon: Center(
                      child: Icon(
                        Icons.photo_size_select_small_outlined,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}