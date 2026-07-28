import 'package:flutter/material.dart';

import '../models/drug.dart';
import '../repositories/drug_preferences_repository.dart';
import '../repositories/drug_repository.dart';
import '../repositories/nurse_mate_drug_api_repository.dart';
import '../widgets/drug_image.dart';
import 'drug_detail_screen.dart';

class DrugSearchScreen extends StatefulWidget {
  const DrugSearchScreen({
    super.key,
    this.drugRepository,
    this.preferencesRepository,
  });

  final DrugRepository? drugRepository;
  final DrugPreferencesRepository? preferencesRepository;

  @override
  State<DrugSearchScreen> createState() => _DrugSearchScreenState();
}

class _DrugSearchScreenState extends State<DrugSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  late final DrugRepository _drugRepository;
  DrugPreferencesRepository? _preferencesRepository;
  List<String> _recentSearches = const [];
  Set<String> _favoriteIds = const {};
  List<Drug> _favoriteDrugs = const [];
  List<Drug> _recentDrugs = const [];
  List<Drug> _results = const [];
  bool _didSearch = false;
  bool _isLoading = true;
  bool _isSearching = false;
  Object? _loadError;
  int _searchRequest = 0;
  DrugDataSource _dataSource = DrugDataSource.unknown;

  @override
  void initState() {
    super.initState();
    _drugRepository =
        widget.drugRepository ??
        FallbackDrugRepository(
          primary: NurseMateDrugApiRepository(),
          fallback: OfflineDrugRepository(),
        );
    _initialize();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    try {
      _preferencesRepository =
          widget.preferencesRepository ??
          await HiveDrugPreferencesRepository.open();
      await _reloadPreferences();
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error;
        _isLoading = false;
      });
    }
  }

  Future<void> _reloadPreferences() async {
    final repository = _preferencesRepository;
    if (repository == null) return;
    final recentSearches = await repository.getRecentSearches();
    final favoriteIds = await repository.getFavoriteIds();
    final recentDrugIds = await repository.getRecentDrugIds();
    final favoriteDrugs = await _resolveDrugs(favoriteIds);
    final recentDrugs = await _resolveDrugs(recentDrugIds);
    if (!mounted) return;
    setState(() {
      _recentSearches = recentSearches;
      _favoriteIds = favoriteIds;
      _favoriteDrugs = favoriteDrugs;
      _recentDrugs = recentDrugs;
      _isLoading = false;
      _loadError = null;
    });
  }

  Future<List<Drug>> _resolveDrugs(Iterable<String> ids) async {
    final drugs = <Drug>[];
    for (final id in ids) {
      final drug = await _drugRepository.getById(id);
      if (drug != null) drugs.add(drug);
    }
    return drugs;
  }

  Future<void> _runSearch(String value, {bool saveRecent = false}) async {
    final query = value.trim();
    final request = ++_searchRequest;
    if (query.isEmpty) {
      if (!mounted) return;
      setState(() {
        _results = const [];
        _didSearch = false;
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _didSearch = true;
      _isSearching = true;
    });
    final results = await _drugRepository.search(DrugSearchQuery(text: query));
    if (saveRecent) {
      await _preferencesRepository?.addRecentSearch(query);
    }
    if (!mounted || request != _searchRequest) return;
    setState(() {
      _results = results;
      _isSearching = false;
      _dataSource = _drugRepository.lastSource;
    });
    if (saveRecent) await _reloadPreferences();
  }

  Future<void> _searchRecent(String query) async {
    _searchController.text = query;
    _searchController.selection = TextSelection.collapsed(offset: query.length);
    await _runSearch(query, saveRecent: true);
  }

  Future<void> _openDrug(Drug drug) async {
    final preferences = _preferencesRepository;
    if (preferences == null) return;
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      await preferences.addRecentSearch(query);
    }
    await preferences.addRecentDrug(drug.id);
    final detailDrug = await _drugRepository.getById(drug.id) ?? drug;
    if (!mounted) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => DrugDetailScreen(
          drug: detailDrug,
          preferencesRepository: preferences,
          initiallyFavorite: _favoriteIds.contains(drug.id),
        ),
      ),
    );
    await _reloadPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text(
          '약 검색',
          style: TextStyle(
            color: Color(0xFF17324D),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
              child: Column(
                children: [
                  TextField(
                    key: const Key('drugSearchField'),
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    onChanged: _runSearch,
                    onSubmitted: (value) => _runSearch(value, saveRecent: true),
                    decoration: const InputDecoration(
                      hintText: '제품명, 성분명, 제조사를 입력하세요.',
                      prefixIcon: Icon(Icons.search_rounded),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(child: _buildBody(context)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_loadError != null) {
      return const Center(child: Text('약 검색 정보를 불러오지 못했습니다.'));
    }
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_didSearch) {
      if (_results.isEmpty) {
        return const Center(
          child: Text(
            '검색 결과가 없습니다.\n현재 검증된 샘플 의약품만 검색할 수 있습니다.',
            textAlign: TextAlign.center,
          ),
        );
      }
      return Column(
        children: [
          if (_dataSource == DrugDataSource.offlineSample) ...[
            const _OfflineDataNotice(),
            const SizedBox(height: 10),
          ],
          Expanded(
            child: ListView.separated(
              key: const Key('drugSearchResults'),
              itemCount: _results.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, index) => _DrugCard(
                drug: _results[index],
                isFavorite: _favoriteIds.contains(_results[index].id),
                onTap: () => _openDrug(_results[index]),
              ),
            ),
          ),
        ],
      );
    }

    return ListView(
      children: [
        if (_recentSearches.isNotEmpty) ...[
          Text('최근 검색', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final query in _recentSearches)
                ActionChip(
                  key: Key('recentSearch_$query'),
                  label: Text(query),
                  onPressed: () => _searchRecent(query),
                ),
            ],
          ),
          const SizedBox(height: 22),
        ],
        if (_favoriteDrugs.isNotEmpty)
          _CompactDrugSection(
            title: '즐겨찾기',
            drugs: _favoriteDrugs,
            favoriteIds: _favoriteIds,
            onTap: _openDrug,
          ),
        if (_recentDrugs.isNotEmpty)
          _CompactDrugSection(
            title: '최근 조회',
            drugs: _recentDrugs,
            favoriteIds: _favoriteIds,
            onTap: _openDrug,
          ),
        if (_recentSearches.isEmpty &&
            _favoriteDrugs.isEmpty &&
            _recentDrugs.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 70),
            child: Text(
              '제품명, 한글·영문 성분명 또는 제조사로 검색하세요.\n'
              '간호사가 자주 확인하는 핵심 정보를 먼저 보여드립니다.',
              textAlign: TextAlign.center,
            ),
          ),
        const SizedBox(height: 24),
        Text(
          '현재는 검증된 샘플 의약품 정보만 제공합니다.',
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _OfflineDataNotice extends StatelessWidget {
  const _OfflineDataNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('offlineDrugDataNotice'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6DA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE9D58A)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.cloud_off_outlined, color: Color(0xFF745400), size: 20),
          SizedBox(width: 9),
          Expanded(
            child: Text(
              '공식 데이터 연결에 실패하여 검증된 오프라인 샘플을 표시하고 있습니다.',
              style: TextStyle(color: Color(0xFF745400)),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactDrugSection extends StatelessWidget {
  const _CompactDrugSection({
    required this.title,
    required this.drugs,
    required this.favoriteIds,
    required this.onTap,
  });

  final String title;
  final List<Drug> drugs;
  final Set<String> favoriteIds;
  final ValueChanged<Drug> onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          for (final drug in drugs) ...[
            _DrugCard(
              drug: drug,
              isFavorite: favoriteIds.contains(drug.id),
              onTap: () => onTap(drug),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _DrugCard extends StatelessWidget {
  const _DrugCard({
    required this.drug,
    required this.isFavorite,
    required this.onTap,
  });

  final Drug drug;
  final bool isFavorite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: Key('drugCard_${drug.id}'),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFDCE6F0)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DrugImage(drug: drug, size: 72),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            drug.productName,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        if (isFavorite)
                          const Icon(
                            Icons.star_rounded,
                            size: 19,
                            color: Color(0xFFF1A900),
                          ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(drug.ingredientEng),
                    const SizedBox(height: 3),
                    Text(drug.manufacturer),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _MetadataChip(label: drug.prescriptionLabel),
                        _MetadataChip(label: drug.dosageForm),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF7D90A3)),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetadataChip extends StatelessWidget {
  const _MetadataChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF2FD),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}
