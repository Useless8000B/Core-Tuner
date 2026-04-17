import 'package:core_tuner/colors.dart';
import 'package:core_tuner/services/system_services.dart';
import 'package:core_tuner/widgets/core_snack_widget.dart';
import 'package:flutter/material.dart';

class ScalingGovernorWidget extends StatefulWidget {
  const ScalingGovernorWidget({super.key});

  @override
  State<ScalingGovernorWidget> createState() => _ScalingGovernorWidgetState();
}

class _ScalingGovernorWidgetState extends State<ScalingGovernorWidget> {
  String? _selectedGovernor;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentGovernor();
  }

  Future<void> _loadCurrentGovernor() async {
    final governor = await SystemService.getCurrentGovernor();
    if (mounted) {
      setState(() {
        _selectedGovernor = governor;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 65,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.lightBlack,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "SCALING GOVERNOR",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: AppColors.gray.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          DropdownMenu<String>(
            initialSelection: _selectedGovernor,
            expandedInsets: EdgeInsets.zero,
            inputDecorationTheme: const InputDecorationTheme(
              filled: false,
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'SpaceGrotesk',
            ),
            menuStyle: MenuStyle(
              backgroundColor: WidgetStateProperty.all(AppColors.lightBlack),
            ),
            onSelected: (String? value) async {
              if (value != null) {
                try {
                  await SystemService.setGlobalGovernor(value);

                  setState(() => _selectedGovernor = value);

                  if (!context.mounted) return;
                  CoreSnack.show(context, 'Governor set to $value');
                } catch (e) {
                  if (!context.mounted) return;
                  CoreSnack.show(context, 'Error applying: $e', isError: true);
                }
              }
            },
            dropdownMenuEntries: const [
              DropdownMenuEntry(
                value: 'performance',
                label: 'performance',
                leadingIcon: Icon(
                  Icons.bolt,
                  color: AppColors.orange,
                  size: 18,
                ),
              ),
              DropdownMenuEntry(
                value: 'schedutil',
                label: 'schedutil',
                leadingIcon: Icon(
                  Icons.auto_awesome,
                  color: AppColors.royalBlue,
                  size: 18,
                ),
              ),
              DropdownMenuEntry(
                value: 'powersave',
                label: 'powersave',
                leadingIcon: Icon(
                  Icons.eco,
                  color: AppColors.green,
                  size: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
