import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DataStore.instance.load();
  runApp(const TransformApp());
}

// ─────────────────────────────────────────────
// THEME
// ─────────────────────────────────────────────
class TransformApp extends StatelessWidget {
  const TransformApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Programa Transformação',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0a0f1e),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF60a5fa),
          secondary: Color(0xFF4ade80),
          surface: Color(0xFF111827),
        ),
        fontFamily: 'sans-serif',
      ),
      home: const HomeScreen(),
    );
  }
}

// ─────────────────────────────────────────────
// COLORS
// ─────────────────────────────────────────────
const cBg     = Color(0xFF0a0f1e);
const cSurf   = Color(0xFF111827);
const cSurf2  = Color(0xFF1a2236);
const cBorder = Color(0xFF1e293b);
const cBlue   = Color(0xFF60a5fa);
const cGreen  = Color(0xFF4ade80);
const cPurple = Color(0xFFa78bfa);
const cAmber  = Color(0xFFfbbf24);
const cRed    = Color(0xFFf87171);
const cText   = Color(0xFFf1f5f9);
const cMuted  = Color(0xFF94a3b8);
const cDim    = Color(0xFF475569);

// ─────────────────────────────────────────────
// DATA MODELS
// ─────────────────────────────────────────────
class Exercise {
  String name;
  String sets;
  String tip;
  bool done;
  Exercise(this.name, this.sets, this.tip, {this.done = false});

  Map<String, dynamic> toJson() => {
    'name': name,
    'sets': sets,
    'tip': tip,
    'done': done,
  };

  factory Exercise.fromJson(Map<String, dynamic> j) =>
      Exercise(j['name'] as String, j['sets'] as String, j['tip'] as String,
          done: (j['done'] as bool?) ?? false);
}

class WorkoutDay {
  String short;
  String name;
  final String type; // strength | bjj | rest
  String label;
  final Color color;
  List<Exercise> exercises;
  WorkoutDay(this.short, this.name, this.type, this.label, this.color, this.exercises);

  Map<String, dynamic> toJson() => {
    'short': short,
    'name': name,
    'type': type,
    'label': label,
    'colorValue': color.toARGB32(),
    'exercises': exercises.map((e) => e.toJson()).toList(),
  };

  factory WorkoutDay.fromJson(Map<String, dynamic> j) {
    final colorVal = j['colorValue'] as int;
    return WorkoutDay(
      j['short'] as String,
      j['name'] as String,
      j['type'] as String,
      j['label'] as String,
      Color(colorVal),
      (j['exercises'] as List).map((e) => Exercise.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

class Meal {
  String name;
  String kcal;
  final Color color;
  List<String> items;
  Meal(this.name, this.kcal, this.color, this.items);

  Map<String, dynamic> toJson() => {
    'name': name,
    'kcal': kcal,
    'colorValue': color.toARGB32(),
    'items': items,
  };

  factory Meal.fromJson(Map<String, dynamic> j) => Meal(
        j['name'] as String,
        j['kcal'] as String,
        Color(j['colorValue'] as int),
        List<String>.from(j['items'] as List),
      );
}

// ─────────────────────────────────────────────
// DATA STORE (singleton)
// ─────────────────────────────────────────────
class DataStore {
  DataStore._();
  static final DataStore instance = DataStore._();

  static const _keyWorkout = 'workoutDays_v1';
  static const _keyMealsA  = 'mealsA_v1';
  static const _keyMealsB  = 'mealsB_v1';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final wRaw = prefs.getString(_keyWorkout);
    if (wRaw != null) {
      try {
        final list = jsonDecode(wRaw) as List;
        workoutDays.clear();
        workoutDays.addAll(list.map((e) => WorkoutDay.fromJson(e as Map<String, dynamic>)));
      } catch (_) {}
    }

    final aRaw = prefs.getString(_keyMealsA);
    if (aRaw != null) {
      try {
        final list = jsonDecode(aRaw) as List;
        mealsA.clear();
        mealsA.addAll(list.map((e) => Meal.fromJson(e as Map<String, dynamic>)));
      } catch (_) {}
    }

    final bRaw = prefs.getString(_keyMealsB);
    if (bRaw != null) {
      try {
        final list = jsonDecode(bRaw) as List;
        mealsB.clear();
        mealsB.addAll(list.map((e) => Meal.fromJson(e as Map<String, dynamic>)));
      } catch (_) {}
    }
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyWorkout, jsonEncode(workoutDays.map((d) => d.toJson()).toList()));
    await prefs.setString(_keyMealsA,  jsonEncode(mealsA.map((m) => m.toJson()).toList()));
    await prefs.setString(_keyMealsB,  jsonEncode(mealsB.map((m) => m.toJson()).toList()));
  }
}

// ─────────────────────────────────────────────
// DATA
// ─────────────────────────────────────────────
final List<WorkoutDay> workoutDays = [
  WorkoutDay('Seg', 'Segunda', 'strength', 'Push', cBlue, [
    Exercise('Supino reto com barra', '4×8–10', 'Descida 2s. Peso onde sobram 1–2 reps.'),
    Exercise('Desenvolvimento halteres', '5×10–12', 'PRIORIDADE. Ombro largo = shape masculino.'),
    Exercise('Elevação lateral', '5×15', 'Peso leve, forma perfeita. 5 séries sempre.'),
    Exercise('Crucifixo inclinado', '3×12–15', 'Abra bem no fundo, sinta o peitoral superior.'),
    Exercise('Tríceps corda no pulley', '3×12', 'Cotovelo fixo. Extensão total.'),
    Exercise('Core: prancha + abdominal', '3×45s + 3×15', 'Prancha isométrica + elevação de pernas.'),
  ]),
  WorkoutDay('Ter', 'Terça', 'bjj', 'BJJ', cPurple, [
    Exercise('Aquecimento BJJ', '15 min', 'Ginga, rolamento frontal/lateral, shrimping.'),
    Exercise('Técnica do dia', '20 min', 'Preste atenção na instrução. Pergunte sempre.'),
    Exercise('Drilling com parceiro', '15 min', 'Repetição sem resistência. Volume é ouro.'),
    Exercise('Rolamento leve', '3×5 min', 'Foco em posição, não em ganhar. Respire.'),
  ]),
  WorkoutDay('Qua', 'Quarta', 'strength', 'Pull + LISS', cGreen, [
    Exercise('Puxada frente no pulley', '5×8–10', 'PRIORIDADE. Dorsal largo cria shape V.'),
    Exercise('Remada curvada com barra', '4×8', 'Espessura do dorsal. Coluna neutra sempre.'),
    Exercise('Remada cavalinho', '3×12', 'Dorsal médio. Essencial para postura.'),
    Exercise('Pullover com halter', '3×12', 'Expande caixa torácica. Ótimo para shape.'),
    Exercise('Rosca direta + martelo', '3×10 cada', 'Bíceps. Sem swing, forma sempre.'),
    Exercise('LISS — caminhada inclinada', '40 min', '6–8%, 5–6 km/h. FC 120–135 bpm.'),
  ]),
  WorkoutDay('Qui', 'Quinta', 'strength', 'Legs', cBlue, [
    Exercise('Agachamento livre', '4×8–10', 'Profundidade full. Joelho sobre o pé.'),
    Exercise('Leg press 45°', '3×12', 'Pés no meio. Não trave o joelho no topo.'),
    Exercise('Cadeira extensora', '3×15', 'Isométrico no topo. Ativação de quadríceps.'),
    Exercise('Stiff com halteres', '3×10', 'Ísquio e glúteo. Firma sem inflar muito.'),
    Exercise('Core circuito', '4 rounds', 'Prancha 45s + bicicleta 20 + elevação pernas 15.'),
  ]),
  WorkoutDay('Sex', 'Sexta', 'strength', 'Push + HIIT', cAmber, [
    Exercise('Supino inclinado halteres', '4×10', 'Peitoral superior + ombro anterior.'),
    Exercise('Desenvolvimento militar', '5×6–8', 'PESADO. Força máxima em ombros.'),
    Exercise('Elevação lateral parcial', '4×20', 'Séries longas com peso leve. Queima o deltóide.'),
    Exercise('Elevação posterior', '3×15', 'Deltóide posterior. Ombro 3D, postura melhor.'),
    Exercise('Mergulho nas paralelas', '3×falha', 'Peitoral e tríceps. Use lastro se possível.'),
    Exercise('HIIT — bike ou esteira', '8 rounds', '20s sprint + 40s recuperação. Total 20 min.'),
  ]),
  WorkoutDay('Sáb', 'Sábado', 'bjj', 'BJJ Sparring', cPurple, [
    Exercise('Aquecimento geral', '15 min', 'Movimentação BJJ, rolamentos, grip.'),
    Exercise('Técnica com professor', '20 min', 'Absorva. Não force o ego.'),
    Exercise('Sparring livre', '5–6×5 min', 'Aplique o que aprendeu. Respire sempre.'),
    Exercise('Cool down e alongamento', '10 min', 'Fundamental para recuperação e mobilidade.'),
  ]),
  WorkoutDay('Dom', 'Domingo', 'rest', 'Descanso', cDim, [
    Exercise('Caminhada leve (opcional)', '20–30 min', 'Sem pressão. Só se quiser.'),
    Exercise('Mobilidade e alongamento', '15 min', 'Hip flexor, ombro, coluna torácica.'),
    Exercise('Sono', '8h alvo', 'É aqui que o músculo cresce. Priorize.'),
  ]),
];

final List<Meal> mealsA = [
  Meal('☀️ Café da manhã (9h–10h)', '~300 kcal', cAmber, [
    '2 ovos mexidos ou cozidos',
    '1 fatia de pão integral com requeijão light',
    'Café preto ou chá verde sem açúcar',
    '1 fruta pequena (kiwi, maçã, morango)',
  ]),
  Meal('🍽️ Almoço (12h30–13h)', '~580 kcal', cGreen, [
    '150g de frango grelhado, tilápia ou atum',
    '120g de arroz integral cozido',
    '130g de feijão ou lentilha',
    'Salada verde à vontade com limão e azeite',
  ]),
  Meal('💪 Pré-treino (15h30)', '~280 kcal', cBlue, [
    'Whey protein 30g com água ou leite desnatado',
    '1 banana média OU 2 torradas integrais',
    'Creatina 5g',
  ]),
  Meal('🌙 Jantar (19h–20h)', '~480 kcal', cPurple, [
    '160g de carne magra (patinho, frango, ovo)',
    '1 batata doce média (150g)',
    'Legumes refogados à vontade',
    '1 col. sopa de azeite no preparo',
  ]),
  Meal('🌛 Ceia opcional (22h)', '~160 kcal', cDim, [
    '200g de iogurte grego natural sem açúcar',
    'OU 1 ovo cozido + 1 fatia de queijo branco',
    'OU 1 scoop de caseína',
  ]),
];

final List<Meal> mealsB = [
  Meal('☕ Manhã (7h–12h) — só líquidos', 'sem kcal', cDim, [
    'Café preto, chá verde ou chá de gengibre',
    'Água com limão',
    'Pelo menos 500ml antes do almoço',
  ]),
  Meal('🍽️ Almoço reforçado (12h–13h)', '~680 kcal', cGreen, [
    '180g de frango, tilápia ou carne magra',
    '150g de arroz integral + 130g de feijão',
    'Salada verde à vontade com azeite',
    '1 fruta de sobremesa',
  ]),
  Meal('💪 Pré-treino (15h30)', '~320 kcal', cBlue, [
    'Whey 30g + banana (batido ou separado)',
    '1 punhado de castanhas (20g)',
    'Creatina 5g + água',
  ]),
  Meal('🌙 Jantar (19h–20h)', '~550 kcal', cPurple, [
    '180g de proteína (frango, ovo, carne magra)',
    '1 batata doce média (180g)',
    'Legumes refogados à vontade',
    '1 col. sopa de azeite',
  ]),
  Meal('🌛 Ceia (22h) — recomendada', '~180 kcal', cAmber, [
    '200g iogurte grego + 1 col. chá de mel',
    'OU 2 ovos cozidos',
    'OU whey 20g com água',
  ]),
];

// ─────────────────────────────────────────────
// HOME SCREEN
// ─────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      TreinoScreen(onDataChanged: () => setState(() {})),
      DietaScreen(onDataChanged: () => setState(() {})),
      const BjjScreen(),
      const ProgressaoScreen(),
    ];

    return Scaffold(
      backgroundColor: cBg,
      body: screens[_tab],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: cSurf,
          border: Border(top: BorderSide(color: cBorder, width: 1)),
        ),
        child: SafeArea(
          child: NavigationBar(
            backgroundColor: Colors.transparent,
            indicatorColor: cBlue.withValues(alpha: 0.15),
            selectedIndex: _tab,
            onDestinationSelected: (i) => setState(() => _tab = i),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: const [
              NavigationDestination(icon: Icon(Icons.fitness_center), label: 'Treino'),
              NavigationDestination(icon: Icon(Icons.restaurant), label: 'Dieta'),
              NavigationDestination(icon: Icon(Icons.sports_martial_arts), label: 'BJJ'),
              NavigationDestination(icon: Icon(Icons.trending_up), label: 'Progresso'),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// WIDGETS REUTILIZÁVEIS
// ─────────────────────────────────────────────
class AppHeader extends StatelessWidget {
  final String tag;
  final String title;
  final String subtitle;
  const AppHeader({super.key, required this.tag, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: cSurf,
      padding: const EdgeInsets.fromLTRB(16, 52, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tag, style: const TextStyle(fontSize: 10, color: cBlue, letterSpacing: 2, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: cText)),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(fontSize: 13, color: cMuted)),
        ],
      ),
    );
  }
}

class InfoBox extends StatelessWidget {
  final String text;
  final Color bg;
  final Color border;
  final Color textColor;
  const InfoBox({super.key, required this.text, required this.bg, required this.border, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border, width: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(text, style: TextStyle(fontSize: 13, color: textColor, height: 1.6)),
    );
  }
}

class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(text, style: const TextStyle(fontSize: 10, color: cDim, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
    );
  }
}

// ─────────────────────────────────────────────
// DIALOG HELPERS
// ─────────────────────────────────────────────
Future<void> showEditExerciseDialog(
  BuildContext context, {
  required Exercise exercise,
  required VoidCallback onSaved,
  required VoidCallback? onDelete,
}) async {
  final nameCtrl = TextEditingController(text: exercise.name);
  final setsCtrl = TextEditingController(text: exercise.sets);
  final tipCtrl  = TextEditingController(text: exercise.tip);
  final formKey  = GlobalKey<FormState>();

  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: cSurf,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: const Text('Editar exercício', style: TextStyle(color: cText, fontSize: 16)),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildField(nameCtrl, 'Nome', required: true),
              const SizedBox(height: 12),
              _buildField(setsCtrl, 'Séries', required: true),
              const SizedBox(height: 12),
              _buildField(tipCtrl, 'Dica', maxLines: 3),
            ],
          ),
        ),
      ),
      actions: [
        if (onDelete != null)
          TextButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              onDelete();
            },
            icon: const Icon(Icons.delete_outline, color: cRed, size: 18),
            label: const Text('Remover', style: TextStyle(color: cRed)),
          ),
        const Spacer(),
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancelar', style: TextStyle(color: cDim)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: cBlue.withValues(alpha: 0.2),
            foregroundColor: cBlue,
            elevation: 0,
          ),
          onPressed: () {
            if (formKey.currentState!.validate()) {
              exercise.name = nameCtrl.text.trim();
              exercise.sets = setsCtrl.text.trim();
              exercise.tip  = tipCtrl.text.trim();
              Navigator.pop(ctx);
              onSaved();
            }
          },
          child: const Text('Salvar'),
        ),
      ],
    ),
  );
}

Future<void> showAddExerciseDialog(
  BuildContext context, {
  required void Function(Exercise) onAdded,
}) async {
  final nameCtrl = TextEditingController();
  final setsCtrl = TextEditingController();
  final tipCtrl  = TextEditingController();
  final formKey  = GlobalKey<FormState>();

  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: cSurf,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: const Text('Adicionar exercício', style: TextStyle(color: cText, fontSize: 16)),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildField(nameCtrl, 'Nome', required: true),
              const SizedBox(height: 12),
              _buildField(setsCtrl, 'Séries', required: true),
              const SizedBox(height: 12),
              _buildField(tipCtrl, 'Dica', maxLines: 3),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancelar', style: TextStyle(color: cDim)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: cGreen.withValues(alpha: 0.2),
            foregroundColor: cGreen,
            elevation: 0,
          ),
          onPressed: () {
            if (formKey.currentState!.validate()) {
              Navigator.pop(ctx);
              onAdded(Exercise(
                nameCtrl.text.trim(),
                setsCtrl.text.trim(),
                tipCtrl.text.trim(),
              ));
            }
          },
          child: const Text('Adicionar'),
        ),
      ],
    ),
  );
}

Future<void> showEditMealDialog(
  BuildContext context, {
  required Meal meal,
  required VoidCallback onSaved,
}) async {
  final nameCtrl = TextEditingController(text: meal.name);
  final kcalCtrl = TextEditingController(text: meal.kcal);
  final formKey  = GlobalKey<FormState>();

  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: cSurf,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: const Text('Editar refeição', style: TextStyle(color: cText, fontSize: 16)),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildField(nameCtrl, 'Nome', required: true),
            const SizedBox(height: 12),
            _buildField(kcalCtrl, 'Calorias (ex: ~300 kcal)', required: true),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancelar', style: TextStyle(color: cDim)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: cBlue.withValues(alpha: 0.2),
            foregroundColor: cBlue,
            elevation: 0,
          ),
          onPressed: () {
            if (formKey.currentState!.validate()) {
              meal.name = nameCtrl.text.trim();
              meal.kcal = kcalCtrl.text.trim();
              Navigator.pop(ctx);
              onSaved();
            }
          },
          child: const Text('Salvar'),
        ),
      ],
    ),
  );
}

Future<void> showEditItemDialog(
  BuildContext context, {
  required String current,
  required void Function(String) onSaved,
  required VoidCallback onDelete,
}) async {
  final ctrl    = TextEditingController(text: current);
  final formKey = GlobalKey<FormState>();

  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: cSurf,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: const Text('Editar item', style: TextStyle(color: cText, fontSize: 16)),
      content: Form(
        key: formKey,
        child: _buildField(ctrl, 'Item', required: true, maxLines: 2),
      ),
      actions: [
        TextButton.icon(
          onPressed: () {
            Navigator.pop(ctx);
            onDelete();
          },
          icon: const Icon(Icons.delete_outline, color: cRed, size: 18),
          label: const Text('Remover', style: TextStyle(color: cRed)),
        ),
        const Spacer(),
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancelar', style: TextStyle(color: cDim)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: cBlue.withValues(alpha: 0.2),
            foregroundColor: cBlue,
            elevation: 0,
          ),
          onPressed: () {
            if (formKey.currentState!.validate()) {
              Navigator.pop(ctx);
              onSaved(ctrl.text.trim());
            }
          },
          child: const Text('Salvar'),
        ),
      ],
    ),
  );
}

Future<void> showAddItemDialog(
  BuildContext context, {
  required void Function(String) onAdded,
}) async {
  final ctrl    = TextEditingController();
  final formKey = GlobalKey<FormState>();

  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: cSurf,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: const Text('Adicionar item', style: TextStyle(color: cText, fontSize: 16)),
      content: Form(
        key: formKey,
        child: _buildField(ctrl, 'Descrição do item', required: true, maxLines: 2),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancelar', style: TextStyle(color: cDim)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: cGreen.withValues(alpha: 0.2),
            foregroundColor: cGreen,
            elevation: 0,
          ),
          onPressed: () {
            if (formKey.currentState!.validate()) {
              Navigator.pop(ctx);
              onAdded(ctrl.text.trim());
            }
          },
          child: const Text('Adicionar'),
        ),
      ],
    ),
  );
}

Widget _buildField(TextEditingController ctrl, String label,
    {bool required = false, int maxLines = 1}) {
  return TextFormField(
    controller: ctrl,
    maxLines: maxLines,
    style: const TextStyle(color: cText, fontSize: 14),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: cMuted, fontSize: 13),
      filled: true,
      fillColor: cSurf2,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: cBorder, width: 0.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: cBorder, width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: cBlue, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    ),
    validator: required ? (v) => (v == null || v.trim().isEmpty) ? 'Campo obrigatório' : null : null,
  );
}

// ─────────────────────────────────────────────
// TREINO SCREEN
// ─────────────────────────────────────────────
class TreinoScreen extends StatefulWidget {
  final VoidCallback? onDataChanged;
  const TreinoScreen({super.key, this.onDataChanged});

  @override
  State<TreinoScreen> createState() => _TreinoScreenState();
}

class _TreinoScreenState extends State<TreinoScreen> {
  int _selectedDay = DateTime.now().weekday - 1 < 7 ? DateTime.now().weekday - 1 : 0;

  String _chipLabel(String type) {
    switch (type) {
      case 'bjj': return 'BJJ';
      case 'rest': return 'Descanso';
      default: return 'Musculação';
    }
  }

  void _saveAndRefresh() {
    DataStore.instance.save();
    setState(() {});
    widget.onDataChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    final day = workoutDays[_selectedDay];
    return Column(
      children: [
        const AppHeader(
          tag: 'TREINO',
          title: 'Push / Pull / Legs',
          subtitle: '5x musculação • 2x BJJ • foco em shape V',
        ),
        Expanded(
          child: ListView(
            children: [
              // Day selector
              SizedBox(
                height: 72,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: workoutDays.length,
                  itemBuilder: (_, i) {
                    final d = workoutDays[i];
                    final selected = i == _selectedDay;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedDay = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected ? d.color.withValues(alpha: 0.15) : cSurf,
                          border: Border.all(color: selected ? d.color : cBorder, width: selected ? 1 : 0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(d.short, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: selected ? d.color : cText)),
                            Text(d.label, style: TextStyle(fontSize: 9, color: selected ? d.color : cMuted)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Workout card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: cSurf,
                  border: Border.all(color: cBorder, width: 0.5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: day.color.withValues(alpha: 0.3), width: 1)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(day.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: cText)),
                              Text(day.label, style: TextStyle(fontSize: 12, color: day.color)),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: day.color.withValues(alpha: 0.12),
                                  border: Border.all(color: day.color.withValues(alpha: 0.4), width: 0.5),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(_chipLabel(day.type), style: TextStyle(fontSize: 10, color: day.color, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 4),
                              // Botão adicionar exercício
                              IconButton(
                                icon: Icon(Icons.add_circle_outline, color: day.color, size: 20),
                                tooltip: 'Adicionar exercício',
                                onPressed: () async {
                                  await showAddExerciseDialog(context, onAdded: (ex) {
                                    day.exercises.add(ex);
                                    _saveAndRefresh();
                                  });
                                },
                              ),
                              TextButton(
                                onPressed: () => setState(() {
                                  for (final e in day.exercises) { e.done = false; }
                                }),
                                child: const Text('Limpar', style: TextStyle(fontSize: 11, color: cDim)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Exercises
                    ...day.exercises.asMap().entries.map((entry) {
                      final i = entry.key;
                      final ex = entry.value;
                      return GestureDetector(
                        onTap: () => setState(() => ex.done = !ex.done),
                        onLongPress: () async {
                          await showEditExerciseDialog(
                            context,
                            exercise: ex,
                            onSaved: _saveAndRefresh,
                            onDelete: () {
                              day.exercises.removeAt(i);
                              _saveAndRefresh();
                            },
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: ex.done ? day.color.withValues(alpha: 0.06) : (i % 2 == 0 ? cSurf : cSurf2),
                            border: Border(bottom: BorderSide(color: cBorder, width: 0.3)),
                          ),
                          child: Row(
                            children: [
                              // Number / check
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: ex.done ? day.color : day.color.withValues(alpha: 0.12),
                                ),
                                child: Center(
                                  child: ex.done
                                      ? const Icon(Icons.check, size: 14, color: cBg)
                                      : Text('${i + 1}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: day.color)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(ex.name, style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: ex.done ? cDim : cText,
                                      decoration: ex.done ? TextDecoration.lineThrough : null,
                                    )),
                                    Text(ex.tip, style: const TextStyle(fontSize: 11, color: cDim, height: 1.4)),
                                  ],
                                ),
                              ),
                              // Sets + timer
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(ex.sets, style: const TextStyle(fontSize: 11, color: cMuted, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  GestureDetector(
                                    onTap: () => _showTimer(context),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: cGreen.withValues(alpha: 0.1),
                                        border: Border.all(color: cGreen.withValues(alpha: 0.3), width: 0.5),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.timer_outlined, size: 10, color: cGreen),
                                          SizedBox(width: 2),
                                          Text('Rest', style: TextStyle(fontSize: 9, color: cGreen)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                    // Progress bar
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${day.exercises.where((e) => e.done).length}/${day.exercises.length} exercícios',
                                style: const TextStyle(fontSize: 12, color: cMuted),
                              ),
                              Text(
                                day.exercises.isEmpty
                                    ? '0%'
                                    : '${((day.exercises.where((e) => e.done).length / day.exercises.length) * 100).round()}%',
                                style: TextStyle(fontSize: 12, color: day.color, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: day.exercises.isEmpty
                                  ? 0
                                  : day.exercises.where((e) => e.done).length / day.exercises.length,
                              backgroundColor: cSurf2,
                              valueColor: AlwaysStoppedAnimation<Color>(day.color),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Dica de toque longo
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Toque longo em um exercício para editar ou remover.',
                  style: TextStyle(fontSize: 11, color: cDim),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  void _showTimer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: cSurf,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => const RestTimerSheet(),
    );
  }
}

// ─────────────────────────────────────────────
// REST TIMER
// ─────────────────────────────────────────────
class RestTimerSheet extends StatefulWidget {
  const RestTimerSheet({super.key});

  @override
  State<RestTimerSheet> createState() => _RestTimerSheetState();
}

class _RestTimerSheetState extends State<RestTimerSheet> {
  int _selected = 60;
  int _remaining = 60;
  bool _running = false;
  Timer? _timer;

  final List<int> _presets = [30, 45, 60, 90, 120, 180];

  void _start() {
    setState(() { _running = true; _remaining = _selected; });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remaining <= 0) {
        t.cancel();
        setState(() => _running = false);
      } else {
        setState(() => _remaining--);
      }
    });
  }

  void _reset() {
    _timer?.cancel();
    setState(() { _running = false; _remaining = _selected; });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _fmt(int s) => '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final progress = _selected > 0 ? (_selected - _remaining) / _selected : 0.0;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: cBorder, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          const Text('Timer de Descanso', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: cText)),
          const SizedBox(height: 20),
          SizedBox(
            width: 140,
            height: 140,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 140,
                  height: 140,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 8,
                    backgroundColor: cSurf2,
                    valueColor: AlwaysStoppedAnimation<Color>(_remaining <= 10 ? cRed : cGreen),
                  ),
                ),
                Text(_fmt(_remaining), style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: cText)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            children: _presets.map((s) {
              final sel = s == _selected;
              return GestureDetector(
                onTap: () { if (!_running) setState(() { _selected = s; _remaining = s; }); },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: sel ? cBlue.withValues(alpha: 0.15) : cSurf2,
                    border: Border.all(color: sel ? cBlue : cBorder, width: 0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('${s}s', style: TextStyle(fontSize: 12, color: sel ? cBlue : cMuted, fontWeight: FontWeight.bold)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _running ? _reset : _start,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _running ? cRed.withValues(alpha: 0.2) : cGreen.withValues(alpha: 0.2),
                  foregroundColor: _running ? cRed : cGreen,
                  side: BorderSide(color: _running ? cRed : cGreen, width: 0.5),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: Text(_running ? 'Resetar' : 'Iniciar', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// DIETA SCREEN
// ─────────────────────────────────────────────
class DietaScreen extends StatefulWidget {
  final VoidCallback? onDataChanged;
  const DietaScreen({super.key, this.onDataChanged});

  @override
  State<DietaScreen> createState() => _DietaScreenState();
}

class _DietaScreenState extends State<DietaScreen> {
  bool _opcaoA = true;

  void _saveAndRefresh() {
    DataStore.instance.save();
    setState(() {});
    widget.onDataChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    final meals = _opcaoA ? mealsA : mealsB;
    return Column(
      children: [
        const AppHeader(
          tag: 'DIETA',
          title: 'Secagem com Preservação Muscular',
          subtitle: '1.800 kcal • 160g proteína • janela flexível',
        ),
        Expanded(
          child: ListView(
            children: [
              // Macros
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  children: [
                    _macroCard('1.800', 'kcal', cBlue),
                    const SizedBox(width: 8),
                    _macroCard('160g', 'proteína', cGreen),
                    const SizedBox(width: 8),
                    _macroCard('160g', 'carbs', cAmber),
                    const SizedBox(width: 8),
                    _macroCard('50g', 'gordura', cRed),
                  ],
                ),
              ),

              const SectionLabel('PLANO ALIMENTAR'),

              // Toggle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: cSurf2,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: cBorder, width: 0.5),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: GestureDetector(
                        onTap: () => setState(() => _opcaoA = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _opcaoA ? cBlue.withValues(alpha: 0.15) : Colors.transparent,
                            border: _opcaoA ? Border.all(color: cBlue, width: 0.5) : null,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text('Com apetite de manhã', textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: _opcaoA ? cBlue : cMuted, fontWeight: FontWeight.bold)),
                        ),
                      )),
                      Expanded(child: GestureDetector(
                        onTap: () => setState(() => _opcaoA = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: !_opcaoA ? cPurple.withValues(alpha: 0.15) : Colors.transparent,
                            border: !_opcaoA ? Border.all(color: cPurple, width: 0.5) : null,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text('Sem apetite de manhã', textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: !_opcaoA ? cPurple : cMuted, fontWeight: FontWeight.bold)),
                        ),
                      )),
                    ],
                  ),
                ),
              ),

              if (!_opcaoA)
                const InfoBox(
                  text: 'Nos dias sem fome de manhã: não force. Só líquidos até o almoço. É jejum intermitente natural — funciona muito bem para secagem.',
                  bg: Color(0xFF2e1065),
                  border: cPurple,
                  textColor: Color(0xFFc4b5fd),
                ),

              const SizedBox(height: 8),

              ...meals.map((m) => _mealCard(m, meals)),

              const SectionLabel('SUPLEMENTAÇÃO'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _suppCard('Essenciais', ['Creatina 5g/dia', 'Whey 30g pós-treino', 'Vitamina D3 4.000 UI', 'Ômega-3 2g/dia'])),
                    const SizedBox(width: 8),
                    Expanded(child: _suppCard('Opcionais', ['Cafeína 200mg pré', 'ZMA antes de dormir', 'Magnésio 350mg', 'Caseína noturna'])),
                  ],
                ),
              ),

              const InfoBox(
                text: 'Proteína primeiro: em toda refeição, a proteína é o primeiro item. Sem TH, a proteína alta é ainda mais crítica para preservar músculo durante a secagem.',
                bg: Color(0xFF052e16),
                border: cGreen,
                textColor: Color(0xFF86efac),
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Toque longo no nome da refeição para editar. Toque longo em um item para editar ou remover.',
                  style: TextStyle(fontSize: 11, color: cDim),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  Widget _macroCard(String val, String lbl, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: cSurf2,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: cBorder, width: 0.5),
        ),
        child: Column(
          children: [
            Text(val, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
            Text(lbl, style: const TextStyle(fontSize: 10, color: cMuted)),
          ],
        ),
      ),
    );
  }

  Widget _mealCard(Meal m, List<Meal> mealList) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      decoration: BoxDecoration(
        color: cSurf,
        border: Border.all(color: cBorder, width: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Header — toque longo edita nome/kcal da refeição
          GestureDetector(
            onLongPress: () async {
              await showEditMealDialog(context, meal: m, onSaved: _saveAndRefresh);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: m.color.withValues(alpha: 0.3), width: 1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(m.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: cText)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: m.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(m.kcal, style: TextStyle(fontSize: 11, color: m.color, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
          // Items
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Column(
              children: [
                ...m.items.asMap().entries.map((entry) {
                  final idx  = entry.key;
                  final item = entry.value;
                  return GestureDetector(
                    onLongPress: () async {
                      await showEditItemDialog(
                        context,
                        current: item,
                        onSaved: (newVal) {
                          m.items[idx] = newVal;
                          _saveAndRefresh();
                        },
                        onDelete: () {
                          m.items.removeAt(idx);
                          _saveAndRefresh();
                        },
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('· ', style: TextStyle(color: cDim, fontSize: 13)),
                          Expanded(child: Text(item, style: const TextStyle(fontSize: 12, color: cMuted, height: 1.4))),
                        ],
                      ),
                    ),
                  );
                }),
                // Botão adicionar item
                GestureDetector(
                  onTap: () async {
                    await showAddItemDialog(context, onAdded: (newItem) {
                      m.items.add(newItem);
                      _saveAndRefresh();
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Icon(Icons.add_circle_outline, size: 14, color: m.color.withValues(alpha: 0.7)),
                        const SizedBox(width: 4),
                        Text('Adicionar item', style: TextStyle(fontSize: 11, color: m.color.withValues(alpha: 0.7))),
                      ],
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

  Widget _suppCard(String title, List<String> items) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cSurf2,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: cText)),
          const SizedBox(height: 8),
          ...items.map((i) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(i, style: const TextStyle(fontSize: 11, color: cMuted, height: 1.5)),
          )),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// BJJ SCREEN
// ─────────────────────────────────────────────
class BjjScreen extends StatelessWidget {
  const BjjScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const AppHeader(
          tag: 'BJJ & CARDIO',
          title: 'Jiu-Jitsu + Cardio Estratégico',
          subtitle: '500–800 kcal/h • queima gordura total',
        ),
        Expanded(
          child: ListView(
            children: [
              const InfoBox(
                text: 'BJJ acelera a perda de gordura nos seios e quadril, treina o corpo inteiro e constrói disciplina mental. O ambiente do BJJ também é um espaço de pertencimento e construção de identidade.',
                bg: Color(0xFF2e1065),
                border: cPurple,
                textColor: Color(0xFFc4b5fd),
              ),

              const SectionLabel('SESSÕES SEMANAIS'),

              _bjjCard('🟣 Terça — Técnica (60–75 min)', cPurple,
                'Foco em posições de guarda, raspagens e finalizações. Drilling 20 min + rolamento leve 3×5 min. Sem ego — absorva os movimentos.'),
              _bjjCard('🟣 Sábado — Sparring livre (90 min)', cPurple,
                'Aquecimento 15 min → técnica 20 min → sparring 4–6 rounds de 5 min. Dia mais intenso, conta como HIIT pesado.'),
              _bjjCard('🟢 Quarta — LISS (40 min pós treino)', cGreen,
                'Caminhada inclinada 6–8% a 5–6 km/h. FC alvo: 120–135 bpm. Ideal para queima de gordura sem comprometer recuperação muscular.'),
              _bjjCard('🟡 Sexta — HIIT (20 min pós treino)', cAmber,
                '8 rounds: 20s sprint (13–16 km/h) + 40s caminhada. Se estiver destruído, substitua por LISS. Não force recuperação.'),

              const SectionLabel('ROADMAP BJJ — 16 SEMANAS'),

              _tlItem('Sem 1–4', 'Fundação', cPurple,
                'Posições básicas: guarda fechada, meia guarda, montada. Aprenda a cair (ukemi). Não force sparring — foque em absorver.', false),
              _tlItem('Sem 5–8', 'Defesa e escape', const Color(0xFF7c3aed),
                'Escape do lado, escape da montada, defesa de kimura e americana. Rolamentos leves com parceiros mais graduados.', false),
              _tlItem('Sem 9–12', 'Ataque', const Color(0xFF8b5cf6),
                'Raspagens básicas, passagem de guarda, kimura, americana, triângulo. Aumente intensidade gradualmente.', false),
              _tlItem('Sem 13–16', 'Fluência', const Color(0xFFa78bfa),
                'Encadeamento de movimentos. Sparring regular. Condicionamento físico e coordenação visivelmente diferentes.', true),

              const SectionLabel('CORE DIÁRIO — 10 MIN'),
              const InfoBox(
                text: 'Core forte comprime a região abdominal, melhora postura e cria a aparência de cintura mais estreita. O vacuum abdominal com consistência reduz visualmente a circunferência da cintura.',
                bg: Color(0xFF052e16),
                border: cGreen,
                textColor: Color(0xFF86efac),
              ),
              _coreCard(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  Widget _bjjCard(String title, Color color, String desc) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cSurf,
            border: Border(left: BorderSide(color: color, width: 3), top: BorderSide(color: cBorder, width: 0.5), right: BorderSide(color: cBorder, width: 0.5), bottom: BorderSide(color: cBorder, width: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
              const SizedBox(height: 6),
              Text(desc, style: const TextStyle(fontSize: 12, color: cMuted, height: 1.6)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tlItem(String week, String phase, Color color, String desc, bool last) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
              if (!last) Container(width: 1, height: 60, color: cBorder),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(week, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
                      const SizedBox(width: 8),
                      Text('— $phase', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: cText)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(desc, style: const TextStyle(fontSize: 12, color: cMuted, height: 1.5)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _coreCard() {
    final exercises = [
      ('Prancha isométrica', '3×45s', 'Corpo reto. Respire normalmente.'),
      ('Abdominal bicicleta', '3×20', 'Cotovelo no joelho oposto. Lento.'),
      ('Elevação de pernas', '3×15', 'Lombar no chão. Desce devagar.'),
      ('Vacuum abdominal', '3×30s', 'Suga umbigo, segura. Afina cintura.'),
      ('Prancha lateral', '2×30s cada', 'Quadril alinhado. Trabalha oblíquo.'),
    ];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: cSurf,
        border: Border.all(color: cBorder, width: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: exercises.asMap().entries.map((e) {
          final ex = e.value;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: e.key % 2 == 0 ? cSurf : cSurf2,
              border: e.key < exercises.length - 1 ? const Border(bottom: BorderSide(color: cBorder, width: 0.3)) : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 26, height: 26,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: cGreen.withValues(alpha: 0.12)),
                  child: Center(child: Text('${e.key + 1}', style: const TextStyle(fontSize: 11, color: cGreen, fontWeight: FontWeight.bold))),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ex.$1, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: cText)),
                      Text(ex.$3, style: const TextStyle(fontSize: 11, color: cDim)),
                    ],
                  ),
                ),
                Text(ex.$2, style: const TextStyle(fontSize: 11, color: cMuted, fontWeight: FontWeight.bold)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PROGRESSÃO SCREEN
// ─────────────────────────────────────────────
class ProgressaoScreen extends StatelessWidget {
  const ProgressaoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final phases = [
      ('Sem 1–4', 'Adaptação neural', cRed, 0.25,
        'Força sobe rápido (neurológico). Cintura começa a afinar. Seios reduzem levemente com secagem. −1 a −2 kg de gordura.'),
      ('Sem 5–8', 'Mudança visual', const Color(0xFFfb923c), 0.5,
        'Ombros aparecem. Cintura mais estreita visualmente. Dorsal mais largo. Seios visivelmente menores. −2 a −3 kg adicionais.'),
      ('Sem 9–12', 'Recomposição', cGreen, 0.75,
        'Músculos mais densos. Shape V começa a ficar evidente. Postura completamente diferente. Core definido afina o abdômen.'),
      ('Sem 13–16', 'Consolidação', cBlue, 1.0,
        'Shape masculino estabelecido. Força 30–50% acima do início. Silhueta visivelmente mais masculina. Fundação sólida para o TH.'),
    ];

    return Column(
      children: [
        const AppHeader(
          tag: 'PROGRESSÃO',
          title: 'O que esperar nas 16 semanas',
          subtitle: 'Secagem + shape V + fundação para o TH',
        ),
        Expanded(
          child: ListView(
            children: [
              const InfoBox(
                text: 'Sem TH, não é possível redistribuir gordura hormonalmente — mas é possível SECAR e CONSTRUIR massa muscular que muda completamente a silhueta. Ombros largos criam ilusão de cintura estreita.',
                bg: Color(0xFF172554),
                border: cBlue,
                textColor: Color(0xFF93c5fd),
              ),

              const SectionLabel('FASES DO PROGRAMA'),

              ...phases.map((p) => _phaseCard(p.$1, p.$2, p.$3, p.$4, p.$5)),

              const SectionLabel('O QUE MUDA EM CADA ÁREA'),

              _areaCard('Seios', cRed, [
                'Sem 1–4: Redução leve com secagem geral',
                'Sem 5–8: Visivelmente menores com gordura corporal caindo',
                'Sem 9–16: Resultado mais pronunciado quanto mais seca',
                'Use binder no dia a dia para conforto e passabilidade',
              ]),
              _areaCard('Quadril', cAmber, [
                'Sem 1–4: Início da perda de gordura na região',
                'Sem 5–8: Redução visível de volume',
                'Sem 9–16: Stiff e agachamento firmam sem inflar muito',
                'Ombros largos criam proporção mais masculina',
              ]),
              _areaCard('Cintura', cGreen, [
                'Vacuum abdominal: reduz circunferência com consistência',
                'Dorsal largo + ombros = ilusão V imediata',
                'Core forte comprime a região abdominais',
                'Deficit calorico afina progressivamente',
              ]),

              const SectionLabel('INDICADORES PARA ACOMPANHAR'),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _metricCard('📏 Medidas (quinzenal)', [
                      'Ombro',
                      'Cintura (umbigo)',
                      'Quadril',
                      'Peito / busto',
                      'Braço flexionado',
                      'Coxa',
                    ])),
                    const SizedBox(width: 8),
                    Expanded(child: _metricCard('🏋️ Performance (semanal)', [
                      'Carga no supino',
                      'Carga desenvolvimento',
                      'Carga na puxada',
                      'Peso corporal',
                      'Rounds BJJ',
                      'Fotos progresso',
                    ])),
                  ],
                ),
              ),

              const InfoBox(
                text: 'Quando iniciar TH: tudo que você construiu vai reagir de forma acelerada. Músculos crescem mais rápido, gordura redistribui do quadril pro abdômen, seios reduzem naturalmente. Chegar ao TH já nessa forma faz diferença enorme.',
                bg: Color(0xFF052e16),
                border: cGreen,
                textColor: Color(0xFF86efac),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  Widget _phaseCard(String week, String name, Color color, double progress, String desc) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cSurf,
        border: Border.all(color: cBorder, width: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
                  const SizedBox(width: 8),
                  Text(week, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 6),
                  Text('— $name', style: const TextStyle(fontSize: 12, color: cText, fontWeight: FontWeight.bold)),
                ],
              ),
              Text('${(progress * 100).round()}%', style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: cSurf2,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 8),
          Text(desc, style: const TextStyle(fontSize: 12, color: cMuted, height: 1.5)),
        ],
      ),
    );
  }

  Widget _areaCard(String title, Color color, List<String> items) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            color: cSurf,
            border: Border(left: BorderSide(color: color, width: 3), top: BorderSide(color: cBorder, width: 0.5), right: BorderSide(color: cBorder, width: 0.5), bottom: BorderSide(color: cBorder, width: 0.5)),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
              const SizedBox(height: 8),
              ...items.map((i) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('· ', style: TextStyle(color: cDim)),
                    Expanded(child: Text(i, style: const TextStyle(fontSize: 12, color: cMuted, height: 1.4))),
                  ],
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metricCard(String title, List<String> items) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cSurf2,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: cText)),
          const SizedBox(height: 8),
          ...items.map((i) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(i, style: const TextStyle(fontSize: 11, color: cMuted, height: 1.6)),
          )),
        ],
      ),
    );
  }
}

