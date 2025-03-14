import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class Process {
  final int id;             // Identificador único para el proceso
  final int duration;       // Duración total del proceso (tiempo de ejecución)
  final int size;           // Tamaño del proceso (prioridad)
  double remainingTime;     // Tiempo restante para completar el proceso

  Process({
    required this.id, 
    required this.duration,
    required this.size,
  }) : remainingTime = duration.toDouble(); // Inicializamos el remainingTime con el valor de duration

  // Método para reiniciar el tiempo restante si es necesario
  void reset() {
    remainingTime = duration.toDouble();
  }
}

class PriorityNonPreemptiveVisualization extends StatefulWidget {
  const PriorityNonPreemptiveVisualization({super.key});

  @override
  PriorityNonPreemptiveVisualizationState createState() => PriorityNonPreemptiveVisualizationState();
}

class PriorityNonPreemptiveVisualizationState extends State<PriorityNonPreemptiveVisualization> {
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
      int randomSize = 120 + _random.nextInt(41); // Tamaño entre 80 y 120
      processes.add(Process(
        id: processCounter++, 
        duration: randomDuration,
        size: randomSize,
      ));
    });
    _startExecution();
  }

  void _startExecution() {
    // Ordenar los procesos según el tamaño (prioridad basada en tamaño más pequeño)
    setState(() {
      processes.sort((a, b) => a.size.compareTo(b.size));
    });

    if (activeIndex == -1 && processes.isNotEmpty) {
      setState(() {
        activeIndex = 0; // El primer proceso en la lista se activa (el de menor tamaño)
      });
      _executeProcess();
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
            // Reordenar según tamaño para el siguiente
            processes.sort((a, b) => a.size.compareTo(b.size));
            activeIndex = 0; // El siguiente proceso en la lista (menor tamaño)
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
        title: const  Text('Planificación basada en prioridades',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.red[700],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    processes.isNotEmpty && activeIndex >= 0
                        ? 'Ejecutando Proceso P${processes[activeIndex].id}' 
                        : 'No se esta ejecutando un proceso',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  if (processes.isNotEmpty && activeIndex >= 0)
                    Text(
                      'Prioridad por menor tamaño: ${processes[activeIndex].size}',
                      style: const TextStyle(fontSize: 16),
                    ),
                ],
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
                  child: RedProcessWidget(
                    process: process,
                    remainingTime: process.remainingTime,
                    size: process.size,
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
              backgroundColor: Colors.red[600],
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

class RedProcessWidget extends StatelessWidget {
  final Process process;
  final double remainingTime;
  final int size;
  final bool isActive;

  const RedProcessWidget({
    super.key,
    required this.process,
    required this.remainingTime,
    required this.size,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: isActive ? Colors.red[700] : Colors.red[400],
        
        border: isActive 
            ? Border.all(color: Colors.yellow, width: 3) 
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "P${process.id} ${size}",
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
       
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