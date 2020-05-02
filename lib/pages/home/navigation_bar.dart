import 'package:flutter/material.dart';


class NavBarItem{
  final IconData icon;
  final String title;

  NavBarItem(this.icon, this.title);
}

List<BottomNavigationBarItem> _getNavItems(List<NavBarItem> items){
  List<BottomNavigationBarItem> _items = [];
  for (int i = 0; i < items.length; i++){
    _items.add(new BottomNavigationBarItem(
      icon: Icon(items[i].icon),
      title: Text(items[i].title)
    ));
  }
  return _items;
}


BottomNavigationBar getBottomNavigationBar(List<NavBarItem> items, int selectedIndex, Function onTap){
  return BottomNavigationBar(
    items: _getNavItems(items),
    currentIndex: selectedIndex,
    onTap: onTap,
  );
}