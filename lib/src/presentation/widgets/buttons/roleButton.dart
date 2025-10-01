import 'package:flutter/material.dart';

class RoleButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final VoidCallback onTap;

  const RoleButton({
    super.key,
    required this.icon,
    required this.label,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        backgroundColor: Colors.white,
      
        foregroundColor: Colors.black87,
        elevation: 4,
        
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          
        ),
      ),
      onPressed: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            size: 36,
            color: Colors.red,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Icon(
            Icons.arrow_forward_ios,
            color: Colors.red,
          )
        ],
      ),
    );
  }
}
