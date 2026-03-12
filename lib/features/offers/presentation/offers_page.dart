import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grand_stay/features/map_navigation/presentation/map_navigation_page.dart';

import '../../../di.dart';
import '../data/offers_repository.dart';
import '../domain/offer.dart';

class OffersPage extends StatefulWidget {
  const OffersPage({super.key});

  @override
  State<OffersPage> createState() => _OffersPageState();
}

class _OffersPageState extends State<OffersPage> {
  late final OffersRepository _repo;
  List<Offer> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _repo = getIt<OffersRepository>();
    _load();
  }

  Future<void> _load() async {
    final data = await _repo.fetchOffers();
    setState(() {
      _items = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          surfaceTintColor: Colors.white,
          toolbarHeight: 80,
          titleSpacing: 5,
          backgroundColor: Colors.white,
          shadowColor: Colors.black,
          elevation: 3,
          leading: backButton(context),
          title: Text(
            'Exclusive deals & packages',
            style: Theme.of(
              context,
            ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                itemCount: _items.length,
                itemBuilder: (context, index) =>
                    _OfferCard(offer: _items[index]),
              ),
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  const _OfferCard({required this.offer});
  final Offer offer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            child: Image.asset(
              offer.image,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  offer.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  maxLines: 2,

                  offer.subtitle,
                  style: theme.textTheme.bodyMedium!.copyWith(
                    overflow: TextOverflow.clip,

                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  offer.validUntil,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    SizedBox(
                      width: 20,
                      child: Image.asset(
                        'assets/images/entertainment/page/tag.png',
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      offer.tag,
                      style: theme.textTheme.bodyMedium!.copyWith(
                        color: Colors.black,
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      height: 28,
                      width: 60,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () =>
                            context.push('/offers/detail', extra: offer),
                        child: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
