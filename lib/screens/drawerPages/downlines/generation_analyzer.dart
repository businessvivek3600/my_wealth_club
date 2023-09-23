import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mycarclub/utils/color.dart';
import '../../../utils/picture_utils.dart';
import '../../../utils/text.dart';

class GenerationAnalyzerPage extends StatefulWidget {
  const GenerationAnalyzerPage({super.key});

  @override
  State<GenerationAnalyzerPage> createState() => _GenerationAnalyzerPageState();
}

class _GenerationAnalyzerPageState extends State<GenerationAnalyzerPage> {
  int? selectedIndex;
  final ScrollController generationScoll = ScrollController();
  List<GlobalKey> generationKeys =
      List.generate(10, (index) => GlobalKey(debugLabel: 'generation_$index'));

  initState() {
    super.initState();
    generationScoll.addListener(() {
      if (selectedIndex != null && selectedIndex != -1) {
        generationScoll.position.ensureVisible(
            generationKeys[selectedIndex!].currentContext!.findRenderObject()!);
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            titleLargeText('Generation Analyzer', context, useGradient: true),
      ),
      body: Container(
        height: double.maxFinite,
        width: double.maxFinite,
        decoration: BoxDecoration(
          image: DecorationImage(
              image: userAppBgImageProvider(context),
              fit: BoxFit.cover,
              opacity: 1),
        ),
        child: Column(children: [
          ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 50),
              child: ListView(
                controller: generationScoll,
                scrollDirection: Axis.horizontal,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _GenerationChip(
                        key: generationKeys[0],
                        title: 'All',
                        selected: selectedIndex == null || selectedIndex == -1,
                        index: -1,
                        onCancel: (index) => {
                          setState(() {
                            selectedIndex = null;
                          })
                        },
                        onSelect: (index) => {
                          setState(() {
                            selectedIndex = index;
                          })
                        },
                      ),
                    ],
                  ),
                  ...List.generate(
                      9,
                      (index) => Builder(builder: (context) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _GenerationChip(
                                  key: generationKeys[index + 1],
                                  title: 'Generation $index',
                                  selected: selectedIndex == index,
                                  index: index,
                                  onCancel: (index) => {
                                    setState(() {
                                      selectedIndex = -1;
                                    })
                                  },
                                  onSelect: (index) => {
                                    setState(() {
                                      selectedIndex = index;
                                    })
                                  },
                                ),
                              ],
                            );
                          }))
                ],
              )),
        ]),
      ),
    );
  }
}

class _GenerationChip extends StatelessWidget {
  const _GenerationChip({
    super.key,
    this.selected = false,
    required this.index,
    required this.onCancel,
    required this.onSelect,
    required this.title,
  });
  final bool selected;
  final int index;
  final Function(int) onSelect;
  final Function(int) onCancel;
  final String title;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onSelect(index),
      child: Container(
        // width: 100,
        constraints: BoxConstraints(maxHeight: 30),
        margin: EdgeInsets.symmetric(horizontal: 5),
        padding: EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: fadeTextColor, width: 1),
          gradient: selected
              ? LinearGradient(
                  colors: [Color.fromARGB(138, 186, 243, 105), appLogoColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
                child: capText(
              title,
              context,
              color: selected ? Colors.white : fadeTextColor,
            )),
            if (selected)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: GestureDetector(
                  onTap: () => onCancel(index),
                  child: Icon(CupertinoIcons.clear_circled_solid,
                      color: Colors.white, size: 15),
                ),
              )
          ],
        ),
      ),
    );
  }
}
