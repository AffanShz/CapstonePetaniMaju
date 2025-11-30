import 'package:flutter/material.dart';
import 'package:petani_maju/features/home/widgets/tip_item.dart';

class TipsList extends StatelessWidget {
  const TipsList({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          TipItem(
            image:
                'https://images.unsplash.com/photo-1586771107445-d3ca888129ff?auto=format&fit=crop&q=80&w=300',
            category: 'Padi',
            title: 'Cara Menanam Padi',
          ),
          TipItem(
            image:
                'https://images.unsplash.com/photo-1551754655-cd27e38d2076?auto=format&fit=crop&q=80&w=300',
            category: 'Nutrisi',
            title: 'Pemupukan Efektif',
          ),
          TipItem(
            image:
                'https://images.unsplash.com/photo-1625246333195-78d9c38ad449?auto=format&fit=crop&q=80&w=300',
            category: 'Pengairan',
            title: 'Irigasi Modern',
          ),
        ],
      ),
    );
  }
}
