import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/meal_plan_models.dart';

class AddMealBottomSheet extends ConsumerStatefulWidget {
  final MealType mealType;
  final DateTime selectedDate;
  final Meal? existingMeal;

  const AddMealBottomSheet({
    super.key,
    required this.mealType,
    required this.selectedDate,
    this.existingMeal,
  });

  @override
  ConsumerState<AddMealBottomSheet> createState() => _AddMealBottomSheetState();
}

class _AddMealBottomSheetState extends ConsumerState<AddMealBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _selectedRecipes = [];
  bool _isCustomMeal = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          _buildTabSelector(),
          Expanded(
            child: _isCustomMeal ? _buildCustomMealForm() : _buildRecipeSelector(),
          ),
          _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: widget.mealType.color.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.mealType.color,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.mealType.icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.existingMeal != null 
                        ? 'Editar ${widget.mealType.name}'
                        : 'Agregar ${widget.mealType.name}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Para el ${_formatDate(widget.selectedDate)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isCustomMeal = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_isCustomMeal 
                    ? widget.mealType.color 
                    : Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Recetas',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: !_isCustomMeal ? Colors.white : Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isCustomMeal = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _isCustomMeal 
                    ? widget.mealType.color 
                    : Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Personalizada',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _isCustomMeal ? Colors.white : Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeSelector() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar recetas...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: widget.mealType.color),
              ),
            ),
            onChanged: (value) {
              // Implement search functionality
            },
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _buildRecipeList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeList() {
    // Mock data - replace with actual recipe data from provider
    final mockRecipes = [
      {'name': 'Avena con Frutas', 'time': 10, 'calories': 250, 'difficulty': 'Fácil'},
      {'name': 'Huevos Revueltos', 'time': 15, 'calories': 180, 'difficulty': 'Fácil'},
      {'name': 'Smoothie Verde', 'time': 5, 'calories': 120, 'difficulty': 'Muy Fácil'},
      {'name': 'Tostadas de Aguacate', 'time': 8, 'calories': 200, 'difficulty': 'Fácil'},
      {'name': 'Pancakes Integrales', 'time': 20, 'calories': 300, 'difficulty': 'Media'},
    ];

    return ListView.builder(
      itemCount: mockRecipes.length,
      itemBuilder: (context, index) {
        final recipe = mockRecipes[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: widget.mealType.color.withValues(alpha: 0.1),
              child: Icon(
                Icons.restaurant,
                color: widget.mealType.color,
              ),
            ),
            title: Text(
              recipe['name'] as String,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('${recipe['time']} min'),
                const SizedBox(width: 12),
                Icon(Icons.local_fire_department, size: 14, color: Colors.orange),
                const SizedBox(width: 4),
                Text('${recipe['calories']} cal'),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    recipe['difficulty'] as String,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.green[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            trailing: Checkbox(
              value: _selectedRecipes.contains(recipe['name']),
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _selectedRecipes.add(recipe['name'] as String);
                  } else {
                    _selectedRecipes.remove(recipe['name']);
                  }
                });
              },
              activeColor: widget.mealType.color,
            ),
            onTap: () {
              setState(() {
                if (_selectedRecipes.contains(recipe['name'])) {
                  _selectedRecipes.remove(recipe['name']);
                } else {
                  _selectedRecipes.add(recipe['name'] as String);
                }
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildCustomMealForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: 'Nombre de la comida',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: widget.mealType.color),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Tiempo (min)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: widget.mealType.color),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Calorías',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: widget.mealType.color),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Ingredientes',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              hintText: 'Agregar ingrediente...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: widget.mealType.color),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  // Add ingredient logic
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Ingredient list would go here
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: const Center(
                child: Text('Los ingredientes aparecerán aquí'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: widget.mealType.color),
              ),
              child: Text(
                'Cancelar',
                style: TextStyle(color: widget.mealType.color),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _selectedRecipes.isNotEmpty || _isCustomMeal
                  ? () => _saveMeal()
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.mealType.color,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                widget.existingMeal != null ? 'Actualizar' : 'Agregar',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final days = ['lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo'];
    final months = ['enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
                   'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'];
    
    return '${days[date.weekday - 1]} ${date.day} de ${months[date.month - 1]}';
  }

  void _saveMeal() {
    // Implement save meal logic
    Navigator.pop(context);
  }
}