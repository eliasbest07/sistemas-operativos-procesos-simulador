import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class Process {
  final int id;             // Identificador único para el proceso
  final int duration;       // Duración total del proceso (tiempo de ejecución)
  double remainingTime;     // Tiempo restante para completar el proceso

  Process({required this.id, required this.duration})
      : remainingTime = duration.toDouble(); // Inicializamos el remainingTime con el valor de duration

  // Método para reiniciar el tiempo restante si es necesario
  void reset() {
    remainingTime = duration.toDouble();
  }
}

class RandomNonPreemptiveVisualization extends StatefulWidget {
  const RandomNonPreemptiveVisualization({super.key});

  @override
  RandomNonPreemptiveVisualizationState createState() => RandomNonPreemptiveVisualizationState();
}

class RandomNonPreemptiveVisualizationState extends State<RandomNonPreemptiveVisualization> {
  List<Process> processes = [];
  int processCounter = 1;
  final Random _random = Random();
  int activeIndex = -1; // Para que no se active ningún proceso al principio
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void addProcess() {
    setState(() {
      int randomDuration = 4 + _random.nextInt(5);
      processes.add(Process(id: processCounter++, duration: randomDuration));
    });
    _startExecution();
  }

  void _startExecution() {
    if (activeIndex == -1 && processes.isNotEmpty) {
      _selectRandomProcess();
      _executeProcess();
    }
  }

  void _selectRandomProcess() {
    if (processes.isNotEmpty) {
      setState(() {
        // Selección aleatoria de un proceso
        activeIndex = _random.nextInt(processes.length);
      });
    }
  }

  void _executeProcess() {
    if (activeIndex >= 0 && activeIndex < processes.length) {
      Process currentProcess = processes[activeIndex];
      
      setState(() {
        currentProcess.remainingTime--; // Decrementar el tiempo restante
      });

      if (currentProcess.remainingTime <= 0) {
        // Cuando termine el proceso, lo eliminamos de la lista
        setState(() {
          processes.removeAt(activeIndex);
          
          if (processes.isNotEmpty) {
            // Selección aleatoria del siguiente proceso
            _selectRandomProcess();
          } else {
            activeIndex = -1; // Si no quedan más procesos
          }
        });
      }

      // Ejecutar el siguiente proceso
      if (processes.isNotEmpty) {
        _timer = Timer(Duration(seconds: 1), _executeProcess); // Usar Timer en lugar de Future.delayed
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('Selección aleatoria', style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.green[700],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Text(
                processes.isNotEmpty && activeIndex >= 0
                    ? 'Ejecutando Proceso P${processes[activeIndex].id}' 
                    : 'No se esta ejecutando procesos',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          // Aquí dibujamos los procesos en una lista horizontal
          Container(
            width: screenWidth,
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: processes.length,
              itemBuilder: (context, index) {
                Process process = processes[index];
                bool isActive = index == activeIndex;
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GreenProcessWidget(
                    process: process,
                    remainingTime: process.remainingTime,
                    isActive: isActive,
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: addProcess,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
            ),
            child: const SizedBox(
              width: 150,
              child: Row(
                children: [
                  Icon(Icons.add_circle_outlined, color: Colors.white,),
                  SizedBox(width: 5,),
                  Text('Agregar Proceso', style: TextStyle(color: Colors.white),),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

class GreenProcessWidget extends StatelessWidget {
  final Process process;
  final double remainingTime;
  final bool isActive;

  const GreenProcessWidget({
    super.key,
    required this.process,
    required this.remainingTime,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: isActive ? Colors.green[700] : Colors.green[400],
        shape: BoxShape.circle,
        border: isActive 
            ? Border.all(color: Colors.yellow, width: 3) 
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "P${process.id} ${remainingTime.toStringAsFixed(0)}/${process.duration}",
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              value: remainingTime / process.duration,
              strokeWidth: 5,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation<Color>(
                isActive ? Colors.yellow : Colors.white
              ),
            ),
          ),
        ],
      ),
    );
  }
}