import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math';

class Process {
  int id;
  int executionTime;
  int remainingTime;
  int priority;
  int arrivalTime;

  Process({
    required this.id,
    required this.executionTime,
    required this.priority,
    required this.arrivalTime,
  }) : remainingTime = executionTime;
}

class PerformanceGraph extends StatefulWidget {
  const PerformanceGraph({super.key});

  @override
  PerformanceGraphState createState() => PerformanceGraphState();
}

class PerformanceGraphState extends State<PerformanceGraph> {
  // Listas separadas para cada algoritmo
  List<Process> fcfsProcesses = [];
  List<Process> sjfProcesses = [];
  List<Process> randomProcesses = [];
  List<Process> priorityProcesses = [];
  List<Process> rrProcesses = [];
  List<Process> srtfProcesses = [];
  List<Process> priorityExpProcesses = [];
  
  // Procesos en ejecución actual para cada algoritmo
  Process? currentFCFSProcess;
  Process? currentSJFProcess;
  Process? currentRandomProcess;
  Process? currentPriorityProcess;
  Process? currentRRProcess;
  Process? currentSRTFProcess;
  Process? currentPriorityExpProcess;
  
  // Contadores de procesos completados
  int fcfsCompleted = 0;
  int sjfCompleted = 0;
  int randomCompleted = 0;
  int priorityCompleted = 0;
  int rrCompleted = 0;
  int srtfCompleted = 0;
  int priorityExpCompleted = 0;
  
  // Puntos para graficar (tiempo, procesos completados)
  List<Offset> fcfsPoints = [];
  List<Offset> sjfPoints = [];
  List<Offset> randomPoints = [];
  List<Offset> priorityPoints = [];
  List<Offset> rrPoints = [];
  List<Offset> srtfPoints = [];
  List<Offset> priorityExpPoints = [];
  
  int timeElapsed = 0;
  int processIdCounter = 1;
  Random random = Random();
  late Timer timer;
  int rrQuantum = 2; // Quantum para Round Robin
  int rrTimeLeft = 0; // Tiempo restante del quantum actual

  @override
  void initState() {
    super.initState();
    _startSimulation();
  }

  void _generateNewProcess() {
    Process newProcess = Process(
      id: processIdCounter++,
      executionTime: 4 + random.nextInt(6), // Tiempo entre 4 y 9
      priority: random.nextInt(5), // Prioridad entre 0 y 4
      arrivalTime: timeElapsed,
    );
    
    // Añadir el nuevo proceso a todas las listas de procesos
    fcfsProcesses.add(Process(
      id: newProcess.id,
      executionTime: newProcess.executionTime,
      priority: newProcess.priority,
      arrivalTime: newProcess.arrivalTime,
    ));
    
    sjfProcesses.add(Process(
      id: newProcess.id,
      executionTime: newProcess.executionTime,
      priority: newProcess.priority,
      arrivalTime: newProcess.arrivalTime,
    ));
    
    randomProcesses.add(Process(
      id: newProcess.id,
      executionTime: newProcess.executionTime,
      priority: newProcess.priority,
      arrivalTime: newProcess.arrivalTime,
    ));
    
    priorityProcesses.add(Process(
      id: newProcess.id,
      executionTime: newProcess.executionTime,
      priority: newProcess.priority,
      arrivalTime: newProcess.arrivalTime,
    ));
    
    rrProcesses.add(Process(
      id: newProcess.id,
      executionTime: newProcess.executionTime,
      priority: newProcess.priority,
      arrivalTime: newProcess.arrivalTime,
    ));
    
    srtfProcesses.add(Process(
      id: newProcess.id,
      executionTime: newProcess.executionTime,
      priority: newProcess.priority,
      arrivalTime: newProcess.arrivalTime,
    ));
    
    priorityExpProcesses.add(Process(
      id: newProcess.id,
      executionTime: newProcess.executionTime,
      priority: newProcess.priority,
      arrivalTime: newProcess.arrivalTime,
    ));
  }

  void _startSimulation() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeElapsed >= 100) {
        timer.cancel();
        return;
      }

      setState(() {
        timeElapsed++;
        _generateNewProcess(); // Generar nuevo proceso cada segundo
        _executeProcesses();
        _updateGraphPoints();
      });
    });
  }

  void _updateGraphPoints() {
    fcfsPoints.add(Offset(timeElapsed.toDouble(), fcfsCompleted.toDouble()));
    sjfPoints.add(Offset(timeElapsed.toDouble(), sjfCompleted.toDouble()));
    randomPoints.add(Offset(timeElapsed.toDouble(), randomCompleted.toDouble()));
    priorityPoints.add(Offset(timeElapsed.toDouble(), priorityCompleted.toDouble()));
    rrPoints.add(Offset(timeElapsed.toDouble(), rrCompleted.toDouble()));
    srtfPoints.add(Offset(timeElapsed.toDouble(), srtfCompleted.toDouble()));
    priorityExpPoints.add(Offset(timeElapsed.toDouble(), priorityExpCompleted.toDouble()));
  }

  void _executeProcesses() {
    // FCFS - First Come First Served
    _executeFCFS();
    
    // SJF - Shortest Job First (No preemptive)
    _executeSJF();
    
    // Random Selection
    _executeRandom();
    
    // Priority Based (No preemptive)
    _executePriority();
    
    // Round Robin
    _executeRoundRobin();
    
    // SRTF - Shortest Remaining Time First (Preemptive)
    _executeSRTF();
    
    // Priority Based (Preemptive)
    _executePriorityPreemptive();
  }

  void _executeFCFS() {
    // Si no hay proceso actual, tomar el primero de la cola (el más antiguo)
    if (currentFCFSProcess == null && fcfsProcesses.isNotEmpty) {
      fcfsProcesses.sort((a, b) => a.arrivalTime.compareTo(b.arrivalTime));
      currentFCFSProcess = fcfsProcesses.removeAt(0);
    }
    
    // Si hay un proceso en ejecución, reducir su tiempo restante
    if (currentFCFSProcess != null) {
      currentFCFSProcess!.remainingTime--;
      
      // Si el proceso ha terminado, incrementar contador y liberar
      if (currentFCFSProcess!.remainingTime <= 0) {
        fcfsCompleted++;
        currentFCFSProcess = null;
      }
    }
  }

  void _executeSJF() {
    // Si no hay proceso actual, elegir el proceso con menor tiempo de ejecución
    if (currentSJFProcess == null && sjfProcesses.isNotEmpty) {
      sjfProcesses.sort((a, b) => a.executionTime.compareTo(b.executionTime));
      currentSJFProcess = sjfProcesses.removeAt(0);
    }
    
    // Si hay un proceso en ejecución, reducir su tiempo restante
    if (currentSJFProcess != null) {
      currentSJFProcess!.remainingTime--;
      
      // Si el proceso ha terminado, incrementar contador y liberar
      if (currentSJFProcess!.remainingTime <= 0) {
        sjfCompleted++;
        currentSJFProcess = null;
      }
    }
  }

  void _executeRandom() {
    // Si no hay proceso actual, elegir uno aleatoriamente
    if (currentRandomProcess == null && randomProcesses.isNotEmpty) {
      int randomIndex = random.nextInt(randomProcesses.length);
      currentRandomProcess = randomProcesses.removeAt(randomIndex);
    }
    
    // Si hay un proceso en ejecución, reducir su tiempo restante
    if (currentRandomProcess != null) {
      currentRandomProcess!.remainingTime--;
      
      // Si el proceso ha terminado, incrementar contador y liberar
      if (currentRandomProcess!.remainingTime <= 0) {
        randomCompleted++;
        currentRandomProcess = null;
      }
    }
  }

  void _executePriority() {
    // Si no hay proceso actual, elegir el de mayor prioridad
    if (currentPriorityProcess == null && priorityProcesses.isNotEmpty) {
      priorityProcesses.sort((a, b) => b.priority.compareTo(a.priority));
      currentPriorityProcess = priorityProcesses.removeAt(0);
    }
    
    // Si hay un proceso en ejecución, reducir su tiempo restante
    if (currentPriorityProcess != null) {
      currentPriorityProcess!.remainingTime--;
      
      // Si el proceso ha terminado, incrementar contador y liberar
      if (currentPriorityProcess!.remainingTime <= 0) {
        priorityCompleted++;
        currentPriorityProcess = null;
      }
    }
  }

  void _executeRoundRobin() {
    // Si no hay proceso actual o se acabó el quantum, obtener siguiente proceso
    if ((currentRRProcess == null || rrTimeLeft <= 0) && rrProcesses.isNotEmpty) {
      // Si hay un proceso actual que no ha terminado, volver a ponerlo al final de la cola
      if (currentRRProcess != null && currentRRProcess!.remainingTime > 0) {
        rrProcesses.add(currentRRProcess!);
      }
      
      // Obtener el siguiente proceso
      currentRRProcess = rrProcesses.removeAt(0);
      rrTimeLeft = rrQuantum;
    }
    
    // Si hay un proceso en ejecución, reducir su tiempo restante y el quantum
    if (currentRRProcess != null) {
      currentRRProcess!.remainingTime--;
      rrTimeLeft--;
      
      // Si el proceso ha terminado, incrementar contador y liberar
      if (currentRRProcess!.remainingTime <= 0) {
        rrCompleted++;
        currentRRProcess = null;
        rrTimeLeft = 0;
      }
    }
  }

  void _executeSRTF() {
    // Verificar si hay un proceso de menor tiempo restante disponible
    if (srtfProcesses.isNotEmpty) {
      srtfProcesses.sort((a, b) => a.remainingTime.compareTo(b.remainingTime));
      
      // Si no hay proceso actual o hay uno con menor tiempo restante, hacer el cambio
      if (currentSRTFProcess == null || 
          (srtfProcesses.isNotEmpty && srtfProcesses[0].remainingTime < currentSRTFProcess!.remainingTime)) {
        
        // Si ya teníamos un proceso, devolverlo a la lista
        if (currentSRTFProcess != null) {
          srtfProcesses.add(currentSRTFProcess!);
          srtfProcesses.sort((a, b) => a.remainingTime.compareTo(b.remainingTime));
        }
        
        // Tomar el proceso con menor tiempo restante
        currentSRTFProcess = srtfProcesses.removeAt(0);
      }
    }
    
    // Si hay un proceso en ejecución, reducir su tiempo restante
    if (currentSRTFProcess != null) {
      currentSRTFProcess!.remainingTime--;
      
      // Si el proceso ha terminado, incrementar contador y liberar
      if (currentSRTFProcess!.remainingTime <= 0) {
        srtfCompleted++;
        currentSRTFProcess = null;
      }
    }
  }

  void _executePriorityPreemptive() {
    // Verificar si hay un proceso de mayor prioridad disponible
    if (priorityExpProcesses.isNotEmpty) {
      priorityExpProcesses.sort((a, b) => b.priority.compareTo(a.priority));
      
      // Si no hay proceso actual o hay uno con mayor prioridad, hacer el cambio
      if (currentPriorityExpProcess == null || 
          (priorityExpProcesses.isNotEmpty && priorityExpProcesses[0].priority > currentPriorityExpProcess!.priority)) {
        
        // Si ya teníamos un proceso, devolverlo a la lista
        if (currentPriorityExpProcess != null) {
          priorityExpProcesses.add(currentPriorityExpProcess!);
          priorityExpProcesses.sort((a, b) => b.priority.compareTo(a.priority));
        }
        
        // Tomar el proceso con mayor prioridad
        currentPriorityExpProcess = priorityExpProcesses.removeAt(0);
      }
    }
    
    // Si hay un proceso en ejecución, reducir su tiempo restante
    if (currentPriorityExpProcess != null) {
      currentPriorityExpProcess!.remainingTime--;
      
      // Si el proceso ha terminado, incrementar contador y liberar
      if (currentPriorityExpProcess!.remainingTime <= 0) {
        priorityExpCompleted++;
        currentPriorityExpProcess = null;
      }
    }
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Rendimiento de Algoritmos"),
      actions: [
        IconButton(onPressed: (){
          showDialog(context: context, builder: (context) => const Dialog(
            child: SizedBox(
              width: 300,
              height: 200,
              child: Center(child: Text('Esta grafica muestra en horizontal el tiempo en segundo, miesntras que la vertical la cantidad de procesos completados para cada algoritmo, todos toman los mismo procesos de la misma lista', textAlign: TextAlign.center,)),
            ),
          ),);
        }, icon: const Icon(Icons.lightbulb_circle))
      ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Tiempo: $timeElapsed | Procesos completados: FCFS: $fcfsCompleted, SJF: $sjfCompleted, "
              "Random: $randomCompleted, Priority: $priorityCompleted, RR: $rrCompleted, "
              "SRTF: $srtfCompleted, PrioExp: $priorityExpCompleted",
              style: const TextStyle(fontSize: 12),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: CustomPaint(
                size: Size(MediaQuery.of(context).size.width, 300),
                painter: GraphPainter(fcfsPoints, sjfPoints, randomPoints, priorityPoints, rrPoints, srtfPoints, priorityExpPoints),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildColorIndicator(Colors.blue, "FCFS"),
                  const SizedBox(width: 10),
                  _buildColorIndicator(Colors.red, "SJF"),
                  const SizedBox(width: 10),
                  _buildColorIndicator(Colors.orange, "Random"),
                  const SizedBox(width: 10),
                  _buildColorIndicator(Colors.purple, "Priority"),
const SizedBox(width: 10),
_buildColorIndicator(Colors.green, "Round Robin"),
const SizedBox(width: 10),
_buildColorIndicator(Colors.black, "SRTF"),
const SizedBox(width: 10),
_buildColorIndicator(Colors.yellow, "Priority Exp"),
],
),
),
),
],
),
);
}

Widget _buildColorIndicator(Color color, String label) {
return Row(
children: [
Container(
width: 20,
height: 10,
color: color,
),
const SizedBox(width: 5),
Text(label, style: const TextStyle(fontSize: 12)),
],
);
}
}

class GraphPainter extends CustomPainter {
final List<Offset> fcfsPoints, sjfPoints, randomPoints, priorityPoints, rrPoints, srtfPoints, priorityExpPoints;

GraphPainter(this.fcfsPoints, this.sjfPoints, this.randomPoints, this.priorityPoints, this.rrPoints, this.srtfPoints, this.priorityExpPoints);

@override
void paint(Canvas canvas, Size size) {
  final Paint gridPaint = Paint()
    ..color = Colors.grey.withOpacity(0.3)
    ..strokeWidth = 1;
    
  final Paint axisPaint = Paint()
    ..color = Colors.black
    ..strokeWidth = 2;
    
  final Paint fcfsPaint = Paint()
    ..color = Colors.blue
    ..strokeWidth = 2
    ..style = PaintingStyle.stroke;
    
  final Paint sjfPaint = Paint()
    ..color = Colors.red
    ..strokeWidth = 2
    ..style = PaintingStyle.stroke;
    
  final Paint randomPaint = Paint()
    ..color = Colors.orange
    ..strokeWidth = 2
    ..style = PaintingStyle.stroke;
    
  final Paint priorityPaint = Paint()
    ..color = Colors.purple
    ..strokeWidth = 2
    ..style = PaintingStyle.stroke;
    
  final Paint rrPaint = Paint()
    ..color = Colors.green
    ..strokeWidth = 2
    ..style = PaintingStyle.stroke;
    
  final Paint srtfPaint = Paint()
    ..color = Colors.black
    ..strokeWidth = 2
    ..style = PaintingStyle.stroke;
    
  final Paint priorityExpPaint = Paint()
    ..color = Colors.yellow
    ..strokeWidth = 2
    ..style = PaintingStyle.stroke;

  // Dibujar cuadrícula
  for (int i = 0; i < 10; i++) {
    double y = (i * size.height / 10);
    canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    
    double x = (i * size.width / 10);
    canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
  }

  // Dibujar ejes
  canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), axisPaint); // Eje X
  canvas.drawLine(const Offset(0, 0), Offset(0, size.height), axisPaint); // Eje Y

  // Dibujar etiquetas de ejes
  const textStyle =  TextStyle(color: Colors.black, fontSize: 12);
  final textPainter = TextPainter(
    textDirection: TextDirection.ltr,
    textAlign: TextAlign.center,
  );
  
  // Etiquetas del eje X
  for (int i = 0; i <= 100; i += 10) {
    textPainter.text = TextSpan(text: '$i', style: textStyle);
    textPainter.layout();
    textPainter.paint(canvas, Offset(i * size.width / 100 - textPainter.width / 2, size.height + 5));
  }
  
  // Etiquetas del eje Y
  int maxCompleted = 0;
  if (fcfsPoints.isNotEmpty) maxCompleted = max(maxCompleted, fcfsPoints.last.dy.toInt());
  if (sjfPoints.isNotEmpty) maxCompleted = max(maxCompleted, sjfPoints.last.dy.toInt());
  if (randomPoints.isNotEmpty) maxCompleted = max(maxCompleted, randomPoints.last.dy.toInt());
  if (priorityPoints.isNotEmpty) maxCompleted = max(maxCompleted, priorityPoints.last.dy.toInt());
  if (rrPoints.isNotEmpty) maxCompleted = max(maxCompleted, rrPoints.last.dy.toInt());
  if (srtfPoints.isNotEmpty) maxCompleted = max(maxCompleted, srtfPoints.last.dy.toInt());
  if (priorityExpPoints.isNotEmpty) maxCompleted = max(maxCompleted, priorityExpPoints.last.dy.toInt());
  
  maxCompleted = max(maxCompleted, 10); // Mostrar al menos 10 en el eje Y
  
  for (int i = 0; i <= maxCompleted; i += maxCompleted ~/ 10) {
    textPainter.text = TextSpan(text: '$i', style: textStyle);
    textPainter.layout();
    textPainter.paint(canvas, Offset(-textPainter.width - 5, size.height - (i * size.height / maxCompleted) - textPainter.height / 2));
  }

  // Dibujar líneas de datos
  _drawDataLine(canvas, fcfsPoints, fcfsPaint, size, maxCompleted);
  _drawDataLine(canvas, sjfPoints, sjfPaint, size, maxCompleted);
  _drawDataLine(canvas, randomPoints, randomPaint, size, maxCompleted);
  _drawDataLine(canvas, priorityPoints, priorityPaint, size, maxCompleted);
  _drawDataLine(canvas, rrPoints, rrPaint, size, maxCompleted);
  _drawDataLine(canvas, srtfPoints, srtfPaint, size, maxCompleted);
  _drawDataLine(canvas, priorityExpPoints, priorityExpPaint, size, maxCompleted);
}

void _drawDataLine(Canvas canvas, List<Offset> points, Paint paint, Size size, int maxCompleted) {
  if (points.isEmpty) return;
  
  final path = Path();
  final scaledPoints = points.map((point) => 
    Offset(
      point.dx * size.width / 100,
      size.height - (point.dy * size.height / maxCompleted)
    )
  ).toList();
  
  path.moveTo(scaledPoints.first.dx, scaledPoints.first.dy);
  
  for (int i = 1; i < scaledPoints.length; i++) {
    path.lineTo(scaledPoints[i].dx, scaledPoints[i].dy);
  }
  
  canvas.drawPath(path, paint);
}

@override
bool shouldRepaint(GraphPainter oldDelegate) => true;
}