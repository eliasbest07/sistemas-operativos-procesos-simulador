import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sistema_operativos/model/process.dart';

class FCFSVisualization extends StatefulWidget {
  const FCFSVisualization({super.key});

  @override
  FCFSVisualizationState createState() => FCFSVisualizationState();
}

class FCFSVisualizationState extends State<FCFSVisualization> {
  List<Process> processes = [];
  int processCounter = 1;
  final Random _random = Random();
  int activeIndex = 0;

  void addProcess() {
    setState(() {
      int randomDuration = 1 + _random.nextInt(9);
      processes.add(Process(id: processCounter++, duration: randomDuration));
    });
  }

  void removeProcess() {
    setState(() {
      if (processes.isNotEmpty) {
        processes.removeAt(0); // Siempre eliminar el primero de la lista
        if (processes.isNotEmpty) {
          activeIndex = 0; // El siguiente proceso en la lista será el nuevo activo
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Primero en llegar primero en ejecutar (FCFS)', style: TextStyle(color: Colors.blue)),
      ),
     
      body: Column(
        children: [
          const SizedBox(height: 20),
          Expanded(
            child: Stack(
              children: processes.asMap().entries.map((entry) {
                int index = entry.key;
                Process process = entry.value;
                return ProcessWidget(
                  key: ValueKey(process.id),
                  process: process,
                  positionY: 100.0 + (index * 90),
                  screenWidth: screenWidth,
                  isActive: index == activeIndex, // Solo el primero se ejecuta
                  onProcessComplete: removeProcess, // Cuando termine, elimina y pasa al siguiente
                );
              }).toList(),
              
            ),
          ),
           ElevatedButton(
            onPressed: addProcess,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
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

class ProcessWidget extends StatefulWidget {
  final Process process;
  final double positionY;
  final double screenWidth;
  final bool isActive;
  final VoidCallback onProcessComplete;

  const ProcessWidget({
    super.key,
    required this.process,
    required this.positionY,
    required this.screenWidth,
    required this.isActive,
    required this.onProcessComplete,
  });

  @override
  _ProcessWidgetState createState() => _ProcessWidgetState();
}

class _ProcessWidgetState extends State<ProcessWidget> {
  late double remainingTime;
  static const int speed = 4;
  double positionX = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    remainingTime = widget.process.duration.toDouble();
    if (widget.isActive) {
      _startExecution();
    }
  }

  @override
  void didUpdateWidget(covariant ProcessWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _startExecution();
    }
  }

  void _startExecution() {
    setState(() {
      positionX = widget.screenWidth - 160;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && remainingTime > 0) {
        setState(() {
          remainingTime--;
          if (remainingTime <= 0) {
            _timer?.cancel();
            widget.onProcessComplete(); // Notificar que terminó
          }
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      left: positionX,
      top: widget.positionY,
      duration: Duration(seconds: speed),
      curve: Curves.linear,
      child: remainingTime > 0
          ? ProcessBlue(
              process: widget.process,
              remainingTime: remainingTime,
            )
          : const SizedBox(), // Oculta el proceso cuando termina
    );
  }
}

class ProcessBlue extends StatelessWidget {
  final Process process;
  final double remainingTime;

  const ProcessBlue({
    super.key,
    required this.process,
    required this.remainingTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "P${process.id} ${remainingTime.toStringAsFixed(1)}",
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 5),
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              value: remainingTime / 10,
              strokeWidth: 5,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}