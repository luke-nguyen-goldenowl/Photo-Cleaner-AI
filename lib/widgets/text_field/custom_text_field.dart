import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class XCustomTextField extends StatefulWidget {
  final String hintText;
  final IconData prefixIcon;
  final bool isPassword;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final String? errorText;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;

  const XCustomTextField({
    super.key,
    required this.hintText,
    required this.prefixIcon,
    this.isPassword = false, // Mặc định không phải password
    this.controller,
    this.onChanged,
    this.keyboardType,
    this.errorText,
    this.maxLength,
    this.inputFormatters,
  });

  @override
  State<XCustomTextField> createState() => _XCustomTextFieldState();
}

class _XCustomTextFieldState extends State<XCustomTextField> {
  // Biến trạng thái để kiểm soát việc ẩn/hiện text
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    // Khởi tạo trạng thái ban đầu dựa trên việc có phải password hay không
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(        controller: widget.controller,
        onChanged: widget.onChanged,
        // Nếu là password thì dùng biến _obscureText, nếu không thì luôn hiện
        obscureText: widget.isPassword ? _obscureText : false,
        keyboardType: widget.keyboardType,
        maxLength: widget.maxLength,
        inputFormatters: widget.inputFormatters,
        decoration: InputDecoration(
          counterText: widget.maxLength != null ? '' : null, // Ẩn counter text khi có maxLength
          hintText: widget.hintText,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: Icon(
            widget.prefixIcon,
            // Sử dụng mã màu tím chủ đạo của app (0xFF6C63FF)
            color: const Color(0xFF6C63FF).withOpacity(0.7),
          ),
          // Logic hiển thị icon mắt (Suffix Icon)
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    // Nếu đang ẩn (_obscureText = true) -> Hiện icon mắt mở để bấm vào xem
                    // Nếu đang hiện -> Hiện icon mắt gạch chéo để bấm vào ẩn
                    _obscureText
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      // Đảo ngược trạng thái khi bấm
                      _obscureText = !_obscureText;
                    });
                  },
                )
              : null, // Nếu không phải password thì không hiện icon cuối
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          errorText: widget.errorText,
        ),
      ),
    );
  }
}
