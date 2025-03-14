import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sistema_operativos/model/process.dart';

// Extendemos la clase Process para incluir prioridad y tiempo de espera
class PriorityProcess extends Process {
  int priority;
  int waitTime;
  final int originalPriority;

  PriorityProcess({
    required int id,
    required int duration,
    required this.priority,
  }) : originalPriority = priority,
       waitTime = 0,
       super(id: id, duration: duration);

  // Método para aplicar envejecimiento
  void applyAging() {
    waitTime++;
    // Incrementar la prioridad cada 3 segundos de espera
    if (waitTime % 3 == 0 && waitTime > 0) {
      priority++;
    }
  }

  // Reiniciar el tiempo de espera cuando el proceso se ejecuta
  void resetWaitTime() {
    waitTime = 0;
  }
}

class PrioritySchedulingVisualization extends StatefulWidget {
  final bool preemptive; // Si es true, el planificador es expulsivo

  const PrioritySchedulingVisualization({
    super.key,
    this.preemptive = true, // Por defecto es expulsivo
  });

  @override
  PrioritySchedulingVisualizationState createState() => PrioritySchedulingVisualizationState();
}

class PrioritySchedulingVisualizationState extends State<PrioritySchedulingVisualization> {
  List<PriorityProcess> processes = [];
  List<PriorityProcess> waitingQueue = [];
  PriorityProcess? currentProcess;
  int processCounter = 1;
  final Random _random = Random();
  Timer? _mainTimer;
  bool isProcessing = false;
  bool isAgingEnabled = true; // Controla si el envejecimiento está activado

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
      int randomPriority = 1 + _random.nextInt(10); // Prioridad entre 1 y 10
      PriorityProcess newProcess = PriorityProcess(
        id: processCounter++,
        duration: randomDuration,
        priority: randomPriority,
      );
      processes.add(newProcess);
      waitingQueue.add(newProcess);
      
      // Ordenar la cola según prioridad (mayor primero)
      _sortQueueByPriority();
      
      // Si es expulsivo y hay un proceso con mayor prioridad que el actual
      if (widget.preemptive && currentProcess != null && 
          newProcess.priority > currentProcess!.priority) {
        waitingQueue.add(currentProcess!);
        currentProcess = newProcess;
        waitingQueue.remove(newProcess);
      }
      
      // Comenzar el ciclo de planificación si no está activo
      if (!isProcessing) {
        startProcessing();
      }
    });
  }

  void _sortQueueByPriority() {
    waitingQueue.sort((a, b) => b.priority.compareTo(a.priority));
  }

  void startProcessing() {
    isProcessing = true;
    _processHighestPriority();
    
    _mainTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Aplicar envejecimiento a todos los procesos en espera
      if (isAgingEnabled) {
        for (var process in waitingQueue) {
          process.applyAging();
        }
        // Reordenar la cola después de aplicar envejecimiento
        _sortQueueByPriority();
      }
      
      if (currentProcess != null) {
        setState(() {
          currentProcess!.duration--;
          currentProcess!.resetWaitTime(); // Resetear tiempo de espera mientras se ejecuta
          
          // Verificar si el proceso ha terminado
          if (currentProcess!.duration <= 0) {
            processes.remove(currentProcess);
            waitingQueue.remove(currentProcess);
            currentProcess = null;
            _processHighestPriority();
          } 
          // Si es expulsivo, verificar si hay un proceso con mayor prioridad
          else if (widget.preemptive) {
            _sortQueueByPriority();
            if (waitingQueue.isNotEmpty && 
                waitingQueue.first.priority > currentProcess!.priority) {
              // Expulsar el proceso actual y colocar el de mayor prioridad
              waitingQueue.add(currentProcess!);
              currentProcess = waitingQueue.first;
              waitingQueue.remove(currentProcess);
              _sortQueueByPriority(); // Volver a ordenar la cola
            }
          }
        });
      } else {
        _processHighestPriority();
      }
      
      // Si no hay más procesos, detener el timer
      if (waitingQueue.isEmpty && currentProcess == null) {
        timer.cancel();
        isProcessing = false;
      }
    });
  }

  void _processHighestPriority() {
    if (waitingQueue.isNotEmpty && currentProcess == null) {
      setState(() {
        _sortQueueByPriority();
        currentProcess = waitingQueue.first;
        waitingQueue.remove(currentProcess);
      });
    }
  }

  void toggleAging() {
    setState(() {
      isAgingEnabled = !isAgingEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.preemptive 
            ? "Planificación por Prioridad (Expulsiva)" 
            : "Planificación por Prioridad (No Expulsiva)",
          style: const TextStyle(color: Colors.brown),
        ),
        actions: [
          // Botón para activar/desactivar el envejecimiento
          Switch(
            value: isAgingEnabled,
            onChanged: (value) => toggleAging(),
            activeColor: Colors.brown,
          ),
          const SizedBox(width: 8),
          const Center(
            child: Text("Envejecimiento"),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Información sobre envejecimiento
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.brown.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.brown.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Envejecimiento:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Técnica que aumenta la prioridad de procesos en espera para evitar la inanición. " +
                    "Cada 3 segundos en espera, la prioridad aumenta en 1. " +
                    "Estado actual: ${isAgingEnabled ? 'Activado' : 'Desactivado'}",
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            // Mostrar el proceso actual
            Container(
              padding: const EdgeInsets.all(10),
              alignment: Alignment.center,
              child: Column(
                children: [
                  const Text(
                    "Proceso en ejecución", 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
            Container(
              height: 800,
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Cola de espera (ordenada por prioridad)", 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: waitingQueue.length,
                      itemBuilder: (context, index) {
                        return WaitingProcessWidget(
                          process: waitingQueue[index],
                          position: index,
                          isAgingEnabled: isAgingEnabled,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addProcess,
        backgroundColor: Colors.brown,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ActiveProcessWidget extends StatelessWidget {
  final PriorityProcess process;

  const ActiveProcessWidget({
    super.key,
    required this.process,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.brown,
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
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Tiempo restante: ${process.duration}",
            style: const TextStyle(fontSize: 14, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "Prioridad: ${process.priority}",
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
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
                      color: Colors.white,
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
  final PriorityProcess process;
  final int position;
  final bool isAgingEnabled;

  const WaitingProcessWidget({
    super.key,
    required this.process,
    required this.position,
    required this.isAgingEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.brown,
          child: Text(
            "${process.id}",
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text("Proceso ${process.id}"),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Tiempo restante: ${process.duration}"),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.brown.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "Prioridad: ${process.priority}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),
                ),
                if (isAgingEnabled && process.priority > process.originalPriority)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "Original: ${process.originalPriority}",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.amber[900],
                      ),
                    ),
                  ),
              ],
            ),
            if (isAgingEnabled)
              Text(
                "Tiempo espera: ${process.waitTime}s",
                style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
          ],
        ),
        trailing: Container(
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
      ),
    );
  }
}