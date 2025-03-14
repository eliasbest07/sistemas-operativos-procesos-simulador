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

class SJFVisualization extends StatefulWidget {
  const SJFVisualization({super.key});

  @override
  SJFVisualizationState createState() => SJFVisualizationState();
}

class SJFVisualizationState extends State<SJFVisualization> {
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
      int randomDuration = 2 + _random.nextInt(5);
      processes.add(Process(id: processCounter++, duration: randomDuration));
    });
    _startExecution();
  }

  void _startExecution() {
    // Ordenar los procesos según el tiempo restante (SJF - Shortest Job First)
    setState(() {
      processes.sort((a, b) => a.remainingTime.compareTo(b.remainingTime));
    });

    if (activeIndex == -1 && processes.isNotEmpty) {
      setState(() {
        activeIndex = 0; // El primer proceso en la lista se activa
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
            activeIndex = 0; // El siguiente proceso en la lista
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
      appBar: AppBar(title: Text('Primero el trabajo más corto (SJF)', style: TextStyle(color: Colors.purple),)),
      body: Column(
        children: [

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
                  child: ProcessWidget(
                    process: process,
                    remainingTime: process.remainingTime,
                    isActive: isActive,
                  ),
                );
              },
            ),
          ),
          Expanded(child: SizedBox(height: 20)),
          ElevatedButton(
            onPressed: addProcess,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
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
        ],
      ),
    );
  }
}

class ProcessWidget extends StatelessWidget {
  final Process process;
  final double remainingTime;
  final bool isActive;

  const ProcessWidget({
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
        color: isActive ? Colors.purple[700] : Colors.purple[400],
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