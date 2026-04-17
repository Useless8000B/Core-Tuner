import 'package:core_tuner/colors.dart';
import 'package:flutter/material.dart';

class TweakButton extends StatefulWidget {
  final String title;
  final Future<void> Function() onAction;

  const TweakButton({
    super.key,
    required this.title,
    required this.onAction,
  });

  @override
  State<TweakButton> createState() => _TweakButtonState();
}

class _TweakButtonState extends State<TweakButton> {
  bool _isExecuting = false;

  Future<void> _handlePress() async {
    if (_isExecuting) return;

    setState(() => _isExecuting = true);
    
    try {
      await widget.onAction();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${widget.title} executed!", style: TextStyle(
            color: AppColors.white
          ),),backgroundColor: AppColors.lightBlack,),
        );
      }
    } finally {
      if (mounted) setState(() => _isExecuting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.lightBlack,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: _isExecuting ? null : _handlePress,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.title, 
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              _isExecuting 
                ? const SizedBox(
                    height: 20, 
                    width: 20, 
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.royalBlue)
                  )
                : const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}