import '../data/non_covered_ct_data.dart';
import '../data/non_covered_etc_data.dart';
import '../data/non_covered_mri_data.dart';
import '../data/non_covered_procedure_data.dart';
import '../data/non_covered_ultrasound_data.dart';
import '../models/non_covered_exam.dart';

abstract class NonCoveredExamRepository {
  List<NonCoveredExam> getUltrasound();

  List<NonCoveredExam> getMRI();

  List<NonCoveredExam> getCT();

  List<NonCoveredExam> getProcedure();

  List<NonCoveredExam> getEtc();

  List<NonCoveredExam> getAll();
}

class LocalNonCoveredExamRepository implements NonCoveredExamRepository {
  const LocalNonCoveredExamRepository();

  static final List<NonCoveredExam> _allExams =
      List<NonCoveredExam>.unmodifiable([
        ...ultrasoundExams,
        ...mriExams,
        ...ctExams,
        ...procedureExams,
        ...etcExams,
      ]);

  @override
  List<NonCoveredExam> getUltrasound() => ultrasoundExams;

  @override
  List<NonCoveredExam> getMRI() => mriExams;

  @override
  List<NonCoveredExam> getCT() => ctExams;

  @override
  List<NonCoveredExam> getProcedure() => procedureExams;

  @override
  List<NonCoveredExam> getEtc() => etcExams;

  @override
  List<NonCoveredExam> getAll() => _allExams;
}
