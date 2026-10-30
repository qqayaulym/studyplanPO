/// Бірегей идентификатор (String) жасайды: уақыт белгісі + есептегіш.
class IdGen {
  IdGen._();

  static int _counter = 0;

  static String next() {
    _counter = (_counter + 1) % 1000;
    return '${DateTime.now().microsecondsSinceEpoch}${_counter.toString().padLeft(3, '0')}';
  }
}
