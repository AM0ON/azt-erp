import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/app_colors.dart';
import '../../../controllers/task_controller.dart';
import 'add_category_dialog.dart';

class FilterBar extends StatelessWidget {
  const FilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TaskController>();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white10)
        )
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "FILTROS DE VISUALIZAÇÃO", 
            style: GoogleFonts.inter(
              fontSize: 11, 
              fontWeight: FontWeight.bold, 
              color: AppColors.textSecondary, 
              letterSpacing: 1.0
            )
          ),
          const SizedBox(height: 12),
          
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ...controller.categories.map((category) {
                  return _buildFilterTab(category, controller);
                }),
                
                if (controller.isManager)
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: IconButton.filled(
                      style: IconButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.05)),
                      icon: const Icon(Icons.add, color: AppColors.primary, size: 18),
                      tooltip: "Nova Categoria",
                      onPressed: () {
                        showDialog(
                          context: context, 
                          builder: (_) => const AddCategoryDialog()
                        );
                      },
                    ),
                  )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(CategoryItem cat, TaskController controller) {
    final isSelected = controller.currentFilter == cat.label;

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: () => controller.setFilter(cat.label),
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.white10
            ),
          ),
          child: Row(
            children: [
              Icon(
                cat.icon, 
                size: 16, 
                color: isSelected ? Colors.white : Colors.grey[400]
              ),
              const SizedBox(width: 8),
              Text(
                cat.label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.grey[400]
                )
              ),
            ],
          ),
        ),
      ),
    );
  }
}