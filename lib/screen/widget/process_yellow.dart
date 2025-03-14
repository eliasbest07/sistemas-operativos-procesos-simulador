import 'dart:async';

import 'dart:math';import 'package:flutter/material.dart';
import 'package:sistema_operativos/model/process.dart';

class RoundRobinVisualization extends StatefulWidget {
  const RoundRobinVisualization({super.key});

  @override
  RoundRobinVisualizationState createState() => RoundRobinVisualizationState();
}

class RoundRobinVisualizationState extends State<RoundRobinVisualization> {
  List<Process> processes = [];
  List<Process> waitingQueue = [];
  Process? currentProcess;
  int processCounter = 1;
  final Random _random = Random();
  final int quantum = 3; // Quantum de tiempo para cada proceso
  int quantumCounter = 0;
  Timer? _mainTimer;
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _mainTimer?.cancel();
    super.dispose();
  }

  void addProcess() {
    setState(() {
      int randomDuration = 1 + _random.nextInt(9);
      Process newProcess = Process(id: processCounter++, duration: randomDuration);
      processes.add(newProcess);
      waitingQueue.add(newProcess);
      
      // Comenzar el ciclo de Round Robin si no está activo
      if (!isProcessing) {
        startProcessing();
      }
    });
  }

  void startProcessing() {
    isProcessing = true;
    _processNextInQueue();
    
    _mainTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (currentProcess != null) {
        setState(() {
          currentProcess!.duration--;
          quantumCounter++;
          
          // Verificar si el proceso ha terminado
          if (currentProcess!.duration <= 0) {
            processes.remove(currentProcess);
            waitingQueue.remove(currentProcess);
            currentProcess = null;
            quantumCounter = 0;
            _processNextInQueue();
          } 
          // Verificar si se ha completado el quantum
          else if (quantumCounter >= quantum) {
            // Mover el proceso actual al final de la cola
            if (waitingQueue.contains(currentProcess)) {
              waitingQueue.remove(currentProcess);
              waitingQueue.add(currentProcess!);
            }
            currentProcess = null;
            quantumCounter = 0;
            _processNextInQueue();
          }
        });
      } else {
        _processNextInQueue();
      }
      
      // Si no hay más procesos, detener el timer
      if (waitingQueue.isEmpty && currentProcess == null) {
        timer.cancel();
        isProcessing = false;
      }
    });
  }

  void _processNextInQueue() {
    if (waitingQueue.isNotEmpty && currentProcess == null) {
      setState(() {
        currentProcess = waitingQueue.first;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Round Robin Visualization", style: TextStyle(color: Colors.orange)),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          // Mostrar el proceso actual
          Container(
            padding: const EdgeInsets.all(10),
            alignment: Alignment.center,
            child: Column(
              children: [
                const Text("Proceso en ejecución", 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 10),
                if (currentProcess != null)
                  ActiveProcessWidget(
                    process: currentProcess!,
                    quantum: quantum,
                    currentQuantum: quantumCounter,
                  )
                else
                  const Text("Ningún proceso en ejecución"),
              ],
            ),
          ),
          const Divider(thickness: 2),
          // Mostrar la cola de espera
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Cola de espera", 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: waitingQueue.length,
                      itemBuilder: (context, index) {
                        // No mostrar el proceso actual en la cola de espera
                        if (waitingQueue[index] == currentProcess) {
                          return const SizedBox.shrink();
                        }
                        return WaitingProcessWidget(
                          process: waitingQueue[index],
                          position: index,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.yellow,
        onPressed: addProcess,
        
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ActiveProcessWidget extends StatelessWidget {
  final Process process;
  final int quantum;
  final int currentQuantum;

  const ActiveProcessWidget({
    super.key,
    required this.process,
    required this.quantum,
    required this.currentQuantum,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 180,
      decoration: BoxDecoration(
        color: Colors.yellow,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Proceso ${process.id}",
            style: const TextStyle(
              fontSize: 18, 
              fontWeight: FontWeight.bold,
              color: Colors.black
            ),
          ),
          const SizedBox(height: 10),
          const SizedBox(height: 10),
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              children: [
                CircularProgressIndicator(
                  value: process.duration / 10,
                  strokeWidth: 8,
                  backgroundColor: Colors.black12,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.black87),
                ),
                Center(
                  child: Text(
                    "${process.duration}",
                    style: const TextStyle(
                      fontSize: 24, 
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Quantum: $currentQuantum/$quantum",
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class WaitingProcessWidget extends StatelessWidget {
  final Process process;
  final int position;

  const WaitingProcessWidget({
    super.key,
    required this.process,
    required this.position,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.orange,
          child: Text(
            "${process.id}",
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text("Proceso ${process.id}"),
        subtitle: Text("Tiempo restante: ${process.duration}"),
        trailing: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              "${position + 1}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}