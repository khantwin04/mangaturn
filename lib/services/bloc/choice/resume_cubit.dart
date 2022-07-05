import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:mangaturn/models/your_choice_models/resume_model.dart';

part 'resume_state.dart';

class ResumeCubit extends Cubit<ResumeState> {
  final Box<ResumeModel> box;
  ResumeCubit(this.box) : super(ResumeInitial()) {
    getResumeList();
  }

  void getResumeList() async {
    emit(ResumeLoading());
    try {
      List<ResumeModel> items = box.values.toList();
      items.sort((a, b) => b.timeStamp.compareTo(a.timeStamp));

      print(items.length);
      if (items.length > 20) {
        box.delete(items[items.length - 1].key.toString());
        print("${items[items.length - 1].chapterName}");
      }
      items = box.values.toList();

      emit(ResumeSuccess(Map.fromIterable(items,
          key: (v) => v.key.toString(), value: (v) => v)));
    } catch (e) {
      emit(ResumeFail(e.toString()));
    }
  }

  void saveResume(ResumeModel model) async {
    var exist = box.containsKey(model.key);
    if (!exist) {
      box.put(model.key.toString(), model);
    } else {
      box.put(model.key, model);
    }
    getResumeList();
  }

  void remove(ResumeModel model) async {
    box.delete(model.key);
    getResumeList();
  }

  void removeAll() async {
    box.clear();
    getResumeList();
  }
}
