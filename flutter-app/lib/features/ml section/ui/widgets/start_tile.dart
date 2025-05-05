import 'package:flutter/material.dart';

class StartTile extends StatelessWidget {
  final String title;
  final String iconPath;
  final String subText;
  final bool isSpeed;
  final bool ishome;
  const StartTile({
    super.key,
    required this.title,
    required this.iconPath,
    required this.subText,
    this.isSpeed = false,
    this.ishome = true,
  });

  @override
  Widget build(BuildContext context) {
    double dh = MediaQuery.of(context).size.height;

    double dw = MediaQuery.of(context).size.width;
    return Container(
      height: dh * 0.2,
      width: dw * 0.4,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0).copyWith(left: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
                height: dh * 0.08,
                width: dh * 0.08,
                child: Image.asset(iconPath)),
            SizedBox(
              height: 10,
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            isSpeed
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Text(
                          subText,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Text(
                            'Kmph',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(fontSize: 10),
                          ),
                        )
                      ],
                    ),
                  )
                : Text(
                    subText,
                    style: Theme.of(context).textTheme.bodyLarge,
                  )
          ],
        ),
      ),
    );
  }
}
