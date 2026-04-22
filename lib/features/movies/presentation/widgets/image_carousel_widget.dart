import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:flutter/material.dart';
import 'package:the_movie_db/core/env/app_flavor.dart';

class ImageCarouselWidget extends StatefulWidget {
  const ImageCarouselWidget({required this.paths, super.key});

  final List<String> paths;

  @override
  State<ImageCarouselWidget> createState() => _ImageCarouselWidgetState();
}

class _ImageCarouselWidgetState extends State<ImageCarouselWidget> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            autoPlay: widget.paths.length > 1,
            onPageChanged: (index, _) => setState(() => _current = index),
          ),
          items: widget.paths.map((path) {
            final url = path.isNotEmpty
                ? '${AppConfig.tmdbBackdropBaseUrl}$path'
                : '';
            return CachedNetworkImage(
              imageUrl: url,
              width: double.infinity,
              fit: BoxFit.cover,
              errorWidget: (_, _, _) => Container(color: Colors.grey[800]),
              placeholder: (_, _) => Container(color: Colors.grey[800]),
            );
          }).toList(),
        ),
        if (widget.paths.length > 1)
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.paths.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _current == i ? 16 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _current == i ? Colors.white : Colors.white54,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
