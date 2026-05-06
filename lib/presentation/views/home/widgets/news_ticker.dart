import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../data/models/news_item_model.dart';
import 'horizontal_news_card.dart';

class NewsTicker extends StatefulWidget {
  final List<NewsItemModel> news;
  const NewsTicker({super.key, required this.news});

  @override
  State<NewsTicker> createState() => _NewsTickerState();
}

class _NewsTickerState extends State<NewsTicker> {
  final PageController _ctrl = PageController(viewportFraction: 0.65);
  Timer? _timer;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    if (widget.news.isEmpty) return;
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      _page = (_page + 1) % widget.news.length;
      _ctrl.animateToPage(
        _page,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void didUpdateWidget(NewsTicker old) {
    super.didUpdateWidget(old);
    if (old.news.length != widget.news.length) {
      _page = 0;
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.news.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 120,
      child: PageView.builder(
        controller: _ctrl,
        itemCount: widget.news.length,
        onPageChanged: (i) => _page = i,
        itemBuilder: (_, i) => HorizontalNewsCard(news: widget.news[i]),
      ),
    );
  }
}
