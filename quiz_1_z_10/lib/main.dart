import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz 1z10',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const MyHomePage(title: 'Music quiz'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _OneOutOfTenState();
}

class _OneOutOfTenState extends State<MyHomePage> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  late ListModel<int> _list;
  int? _selectedItem;
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    _list = ListModel<int>(
      listKey: _listKey,
      initialItems: <int>[0, 1, 2, 4],
      initialLabels: <String>['Basia', 'Łucja', 'Nina', 'Ingaś'],
      removedItemBuilder: _buildRemovedItem,
    );
  }

  Widget _buildItem(
    BuildContext context, int index, Animation<double> animation) {
    return CardItem(
      animation: animation,
      item: _list[index],
      label: _list.labelAt(index),
      selected: _selectedItem == _list[index],
      onTap: () {
        setState(() {
          _selectedItem = _selectedItem == _list[index] ? null : _list[index];
        });
      },
    );
  }

  Widget _buildRemovedItem(
    int item, BuildContext context, Animation<double> animation) {
    return CardItem(
      animation: animation,
      item: item,
      selected: false,
      // No gesture detector here: we don't want removed items to be interactive.
    );
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Row(
          children: [
            Expanded(
              child: AnimatedList(
              key: _listKey,
              initialItemCount: _list.length,
              itemBuilder: _buildItem,
            ),),
            Expanded(
              child: 
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'You have clicked the button this many times:',
                  ),
                  Text(
                    '$_counter',
                    style: Theme.of(context).textTheme.headline4,
                  ),
                  const Text(
                    '1',
                  ),
                ],
              ),
            ),
          ],)
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton.large(
            onPressed: _incrementCounter,
            tooltip: 'OK',
            child: const Icon(Icons.thumb_up_off_alt_rounded),
            backgroundColor: Colors.green,
          ),
          const SizedBox(
            width: 400 ,
          ),
          FloatingActionButton.large(
            onPressed: _incrementCounter,
            tooltip: 'Not ok',
            child: const Icon(Icons.thumb_down_off_alt_rounded),
            backgroundColor: Colors.red,
          ),
        ]
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
typedef RemovedItemBuilder<T> = Widget Function(
    T item, BuildContext context, Animation<double> animation);

class ListModel<E> {
  ListModel({
    required this.listKey,
    required this.removedItemBuilder,
    Iterable<E>? initialItems,
    Iterable<String>? initialLabels,
  }) : _items = List<E>.from(initialItems ?? <E>[]), 
  _labels = List<String>.from(initialLabels ?? <String>[]);

  final GlobalKey<AnimatedListState> listKey;
  final RemovedItemBuilder<E> removedItemBuilder;
  final List<E> _items;
  final List<String> _labels;

  AnimatedListState? get _animatedList => listKey.currentState;

  void insert(int index, E item, String label) {
    _items.insert(index, item);
    _labels.insert(index, label);
    _animatedList!.insertItem(index);
  }

  E removeAt(int index) {
    final E removedItem = _items.removeAt(index);
    _labels.removeAt(index);
    if (removedItem != null) {
      _animatedList!.removeItem(
        index,
        (BuildContext context, Animation<double> animation) {
          return removedItemBuilder(removedItem, context, animation);
        },
      );
    }
    return removedItem;
  }

  int get length => _items.length;

  E operator [](int index) => _items[index];
  String labelAt(int index) => _labels[index];
  int indexOf(E item) => _items.indexOf(item);
}

class CardItem extends StatelessWidget {
  const CardItem({
    Key? key,
    this.onTap,
    this.selected = false,
    required this.animation,
    required this.item,
    this.label = 'error',
  })  : assert(item >= 0),
        super(key: key);

  final Animation<double> animation;
  final VoidCallback? onTap;
  final int item;
  final bool selected;
  final String label;

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.headline4!;
    Color buttonColor = Colors.grey;
    if (selected) {
      textStyle = textStyle.copyWith(color: Colors.lightGreenAccent[400]);
      buttonColor = Colors.lightGreen;
    }
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: SizeTransition(
        axis: Axis.vertical,
        sizeFactor: animation,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: SizedBox(
            height: 80.0,
            width: 150.0,
            child: Card(
              color: buttonColor,
              child: Center(
                child: Text(label, style: textStyle),
              ),
            ),
          ),
        ),
      ),
    );
  }
}