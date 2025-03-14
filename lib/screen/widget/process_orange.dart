import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sistema_operativos/model/process.dart';

class SRTFVisualization extends StatefulWidget {
  const SRTFVisualization({super.key});

  @override
  SRTFVisualizationState createState() => SRTFVisualizationState();
}

class SRTFVisualizationState extends State<SRTFVisualization> {
  List<Process> processes = [];
  List<Process> waitingQueue = [];
  Process? currentProcess;
  int processCounter = 1;
  final Random _random = Random();
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
      
      // Ordenar la cola según el tiempo restante (menor primero)
      _sortQueueBySRT();
      
      // Verificar si este nuevo proceso debe expulsar al actual
      if (currentProcess != null && newProcess.duration < currentProcess!.duration) {
        waitingQueue.add(currentProcess!);
        currentProcess = newProcess;
        waitingQueue.remove(newProcess);
      }
      
      // Comenzar el ciclo de SRTF si no está activo
      if (!isProcessing) {
        startProcessing();
      }
    });
  }

  void _sortQueueBySRT() {
    waitingQueue.sort((a, b) => a.duration.compareTo(b.duration));
  }

  void startProcessing() {
    isProcessing = true;
    _processShortestRemainingTime();
    
    _mainTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (currentProcess != null) {
        setState(() {
          currentProcess!.duration--;
          
          // Verificar si el proceso ha terminado
          if (currentProcess!.duration <= 0) {
            processes.remove(currentProcess);
            waitingQueue.remove(currentProcess);
            currentProcess = null;
            _processShortestRemainingTime();
          } 
          // Re-evaluar si hay un proceso con menor tiempo restante
          else {
            _sortQueueBySRT();
            if (waitingQueue.isNotEmpty && waitingQueue.first.duration < currentProcess!.duration) {
              // Expulsar el proceso actual y poner el de menor tiempo
              waitingQueue.add(currentProcess!);
              currentProcess = waitingQueue.first;
              waitingQueue.remove(currentProcess);
              _sortQueueBySRT(); // Volver a ordenar la cola
            }
          }
        });
      } else {
        _processShortestRemainingTime();
      }
      
      // Si no hay más procesos, detener el timer
      if (waitingQueue.isEmpty && currentProcess == null) {
        timer.cancel();
        isProcessing = false;
      }
    });
  }

  void _processShortestRemainingTime() {
    if (waitingQueue.isNotEmpty && currentProcess == null) {
      setState(() {
        _sortQueueBySRT();
        currentProcess = waitingQueue.first;
        waitingQueue.remove(currentProcess);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Primero el menor tiempo restante (SRTF)", style: TextStyle(color: Colors.orange)),
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
                  const Text("Cola de espera (ordenada por tiempo restante)", 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: waitingQueue.length,
                      itemBuilder: (context, index) {
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
        onPressed: addProcess,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ActiveProcessWidget extends StatelessWidget {
  final Process process;

  const ActiveProcessWidget({
    super.key,
    required this.process,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.orange,
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
              color: Colors.white
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Tiempo restante: ${process.duration}",
            style: const TextStyle(fontSize: 14, color: Colors.white),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              children: [
                CircularProgressIndicator(
                  value: process.duration / 10,
                  strokeWidth: 8,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                Center(
                  child: Text(
                    "${process.duration}",
                    style: const TextStyle(
                      fontSize: 24, 
                      fontWeight: FontWeight.bold,
                      color: Colors.white
                    ),
                  ),
                ),
              ],
            ),
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
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  "${process.duration}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  "${position + 1}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}