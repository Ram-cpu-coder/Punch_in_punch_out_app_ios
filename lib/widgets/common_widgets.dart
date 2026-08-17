part of '../main.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color,
    this.tinted = false,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color? color;
  final bool tinted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? (tinted ? const Color(0xffedf9f4) : Colors.white),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xffdbe7e4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class AppStateBanner extends StatelessWidget {
  const AppStateBanner({
    super.key,
    required this.syncing,
    required this.slow,
    required this.error,
    required this.message,
    required this.onRetry,
    required this.onDismiss,
  });

  final bool syncing;
  final bool slow;
  final String? error;
  final String message;
  final VoidCallback? onRetry;
  final VoidCallback onDismiss;

  bool get visible => syncing || slow || error != null;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    final isError = error != null;
    final bg = isError
        ? const Color(0xfffff2ee)
        : slow
            ? const Color(0xfffff7ed)
            : const Color(0xffedf7f4);
    final fg = isError
        ? const Color(0xffa1432f)
        : slow
            ? const Color(0xff8a5a15)
            : const Color(0xff1d6f68);
    final icon = isError
        ? Icons.wifi_off_outlined
        : slow
            ? Icons.network_check_outlined
            : Icons.sync;
    final text = isError
        ? error!
        : slow
            ? 'Slow connection. Still trying...'
            : message;

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      color: bg,
      child: Row(
        children: [
          syncing && !isError
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: fg),
                )
              : Icon(icon, color: fg),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: fg, fontWeight: FontWeight.w900),
            ),
          ),
          if (isError && onRetry != null)
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          if (isError)
            IconButton(
              tooltip: 'Dismiss',
              onPressed: onDismiss,
              icon: Icon(Icons.close, color: fg),
            ),
        ],
      ),
    );
  }
}

class LoadingStateScreen extends StatelessWidget {
  const LoadingStateScreen({super.key, required this.slow});

  final bool slow;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffedf5f3),
      body: SafeArea(
        child: Center(
          child: AppCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 42,
                  height: 42,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
                const SizedBox(height: 16),
                Text(
                  slow ? 'Connection is slow...' : 'Loading your workspace...',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  slow
                      ? 'Still trying to reach the server.'
                      : 'Getting your rate, timer, and weeks.',
                  style: const TextStyle(
                    color: Color(0xff66737b),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    this.green = false,
    this.animate = false,
  });

  final String label;
  final String value;
  final bool green;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Eyebrow(label),
          const SizedBox(height: 24),
          RollingText(
            value,
            color: green ? const Color(0xff178a53) : const Color(0xff17212b),
            active: animate,
            size: 30,
          ),
        ],
      ),
    );
  }
}

class SmallMetric extends StatelessWidget {
  const SmallMetric({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xff66737b),
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class DetailChip extends StatelessWidget {
  const DetailChip({
    super.key,
    required this.label,
    required this.value,
    this.animate = false,
  });

  final String label;
  final String value;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: Color(0xff66737b),
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          RollingText(value, active: animate, size: 14),
        ],
      ),
    );
  }
}

class RollingText extends StatelessWidget {
  const RollingText(
    this.value, {
    super.key,
    this.color = const Color(0xff17212b),
    this.active = false,
    this.size = 16,
  });

  final String value;
  final Color color;
  final bool active;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 0,
      children: [
        for (var i = 0; i < value.length; i++)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            transitionBuilder: (child, animation) => SlideTransition(
              position:
                  Tween(begin: const Offset(0, 0.7), end: Offset.zero).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                ),
              ),
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: Text(
              value[i],
              key: active ? ValueKey('${value[i]}-$i') : null,
              style: TextStyle(
                color: color,
                fontSize: size,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
          ),
      ],
    );
  }
}

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.icon,
    required this.hint,
    this.keyboardType,
    this.obscureText = false,
    this.suffix,
  });

  final TextEditingController controller;
  final IconData icon;
  final String hint;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          suffixIcon: suffix,
          hintText: hint,
          filled: true,
          fillColor: const Color(0xfff8fbfa),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xffdbe7e4)),
          ),
        ),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.loading = false,
    this.inverted = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool loading;
  final bool inverted;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: FilledButton.icon(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: inverted ? Colors.white : const Color(0xff17212b),
          foregroundColor: inverted ? const Color(0xffa1432f) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        icon: loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(icon),
        label: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
        ),
      ),
    );
  }
}

class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: Color(0xff1d6f68),
        fontSize: 11,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class StatusText extends StatelessWidget {
  const StatusText(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Text(
        message,
        style: const TextStyle(
          color: Color(0xff66737b),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
