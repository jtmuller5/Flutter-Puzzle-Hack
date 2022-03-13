import 'package:flutter/material.dart';
import 'package:puzzle/services/services.dart';
import 'package:puzzle/ui/home/home_view_model.dart';
import 'package:stacked/stacked.dart';
import 'package:transparent_image/transparent_image.dart';

class Setup extends ViewModelWidget<HomeViewModel> {
  const Setup({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, HomeViewModel model) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if(puzzleService.imageBytes != null)Center(
          child:
            PhysicalModel(
              color: Colors.black12,
              elevation: 8,
              child: SizedBox(
                height: puzzleService.sideLength * puzzleService.sideCount,
                width: puzzleService.sideLength * puzzleService.sideCount,
                child: FadeInImage(
                  image: MemoryImage(puzzleService.imageBytes),
                  height: puzzleService.sideLength * puzzleService.sideCount,
                  width: puzzleService.sideLength * puzzleService.sideCount,
                  fit: BoxFit.cover, placeholder: MemoryImage(kTransparentImage),
                ),
              ),
            ),
        ),
      ],
    );
  }
}
