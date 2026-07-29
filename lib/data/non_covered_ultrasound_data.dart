import '../models/non_covered_exam.dart';

/// 초음파 검사 목록
/// 실제 데이터는 병원 비급여 목록을 기준으로 순차적으로 추가한다.
const List<NonCoveredExam> ultrasoundExams = [
  NonCoveredExam(name: '단순초음파(guided)', price: 120000),
  NonCoveredExam(name: '두경부·경부초음파·갑상선·부갑상선', price: 130000),
  NonCoveredExam(name: '흉부·유방·액와부초음파', price: 100000),
  NonCoveredExam(name: '여성생식기 초음파', price: 150000),
  NonCoveredExam(name: '남성생식기 초음파', price: 150000),
  NonCoveredExam(name: '심장·경흉부 초음파', price: 253000),
  NonCoveredExam(name: 'US-Transthoracic Echo · Advanced', price: 280000),
  NonCoveredExam(name: '복부·비뇨기계 초음파·신장·부신', price: 135000),
  NonCoveredExam(name: '복부·비뇨기계 초음파·신장·부신·방광', price: 150000),
  NonCoveredExam(name: '복부 초음파(간·담낭·담도·비장·췌장)', price: 160000),
  NonCoveredExam(name: '근골격·연부조직 초음파', price: 120000),
  NonCoveredExam(name: '혈관·뇌혈류 초음파', price: 190000),
  NonCoveredExam(name: '혈관 초음파(경동맥)', price: 150000),
  NonCoveredExam(name: '혈관 초음파(상지·하지 동맥·정맥)', price: 196000),
  NonCoveredExam(name: '혈관 도플러 초음파(하지 양측)', price: 251000),
  NonCoveredExam(name: '혈관 도플러 초음파(하지정맥류)', price: 220000),
];
