import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:image/image.dart' as img;
import 'package:myapp/src/features/dashboard/cleaner/view/duplicate_image/model/duplicate_image.dart';
import 'package:myapp/src/features/dashboard/cleaner/view/duplicate_image/model/duplicate_image_group.dart';

class ScanHelper {
  static String formatSize(int bytes) {
    if (bytes >= 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    } else if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else if (bytes >= 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    }
    return '$bytes B';
  }

  static Future<double> calculateSharpness(String imagePath) async {
    try {
      final imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        return 0.0;
      }

      final bytes = await imageFile.readAsBytes();
      return calculateFromBytes(bytes);
    } catch (e) {
      return 0.0;
    }
  }

  static double calculateFromBytes(Uint8List bytes) {
    final image = img.decodeImage(bytes);
    if (image == null) return 0.0;

    final gray = img.grayscale(image);

    const kernel = [
      [0, 1, 0],
      [1, -4, 1],
      [0, 1, 0],
    ];

    double sum = 0;
    double sumSq = 0;
    int count = 0;

    for (int y = 1; y < gray.height - 1; y++) {
      for (int x = 1; x < gray.width - 1; x++) {
        int value = 0;

        for (int ky = -1; ky <= 1; ky++) {
          for (int kx = -1; kx <= 1; kx++) {
            final pixel = gray.getPixel(x + kx, y + ky);
            final intensity = img.getLuminance(pixel).toInt();
            value += kernel[ky + 1][kx + 1] * intensity;
          }
        }

        sum += value;
        sumSq += value * value;
        count++;
      }
    }

    if (count == 0) return 0.0;

    final mean = sum / count;
    return (sumSq / count) - (mean * mean);
  }

  static Float32List preprocessImage(img.Image image) {
    final resized = img.copyResize(
      image,
      width: 224,
      height: 224,
      interpolation: img.Interpolation.linear,
    );

    final input = Float32List(1 * 224 * 224 * 3);
    int pixelIndex = 0;

    for (int y = 0; y < 224; y++) {
      for (int x = 0; x < 224; x++) {
        final pixel = resized.getPixel(x, y);
        input[pixelIndex++] = pixel.r / 255.0;
        input[pixelIndex++] = pixel.g / 255.0;
        input[pixelIndex++] = pixel.b / 255.0;
      }
    }

    return input;
  }

  static double cosineSimilarity(List<double> vec1, List<double> vec2) {
    if (vec1.length != vec2.length) return 0.0;

    double dotProduct = 0.0;
    double norm1 = 0.0;
    double norm2 = 0.0;

    for (int i = 0; i < vec1.length; i++) {
      dotProduct += vec1[i] * vec2[i];
      norm1 += vec1[i] * vec1[i];
      norm2 += vec2[i] * vec2[i];
    }

    if (norm1 == 0.0 || norm2 == 0.0) return 0.0;

    return dotProduct / (_sqrt(norm1) * _sqrt(norm2));
  }

  static double _sqrt(double value) {
    if (value <= 0) return 0.0;
    double x = value;
    double y = 1.0;
    double e = 0.000001;

    while ((x - y).abs() > e) {
      x = (x + y) / 2;
      y = value / x;
    }

    return x;
  }

  static List<MDuplicateImageGroup> findDuplicates(
    List<MDuplicateImage> images,
    double threshold,
  ) {
    final groups = <MDuplicateImageGroup>[];
    final processed = <String>{};

    for (int i = 0; i < images.length; i++) {
      if (processed.contains(images[i].id)) continue;

      final currentGroup = <MDuplicateImage>[images[i]];
      processed.add(images[i].id);

      for (int j = i + 1; j < images.length; j++) {
        if (processed.contains(images[j].id)) continue;

        final similarity = cosineSimilarity(
          images[i].features!,
          images[j].features!,
        );

        if (similarity >= threshold) {
          currentGroup.add(images[j]);
          processed.add(images[j].id);
        }
      }

      if (currentGroup.length >= 2) {
        final avgSimilarity = calculateAverageSimilarity(
          currentGroup,
          threshold,
        );

        groups.add(
          MDuplicateImageGroup(
            images: currentGroup,
            similarity: avgSimilarity,
          ),
        );
      }
    }

    groups.sort((a, b) => b.images.length.compareTo(a.images.length));

    return groups;
  }

  static double calculateAverageSimilarity(
    List<MDuplicateImage> images,
    double fallback,
  ) {
    if (images.length < 2) return fallback;

    double totalSimilarity = 0.0;
    int count = 0;

    for (int i = 0; i < images.length; i++) {
      for (int j = i + 1; j < images.length; j++) {
        totalSimilarity += cosineSimilarity(
          images[i].features!,
          images[j].features!,
        );
        count++;
      }
    }

    return count > 0 ? totalSimilarity / count : fallback;
  }

  static Color getStorageColor(double percentage) {
    if (percentage >= 90) {
      return const Color(0xFFEF4444);
    } else if (percentage >= 70) {
      return const Color(0xFFF59E0B);
    } else if (percentage >= 50) {
      return const Color(0xFFFACC15);
    } else {
      return const Color(0xFF667EEA);
    }
  }
}
