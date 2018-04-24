package service;

import java.util.*;

public class ItemsList {
    private final List<Item> items;

    public ItemsList() {
        this.items = new ArrayList<>();
    }

    public void addItem(Item item) {
      this.items.add(item);
    }

    public List<Item> getItems() {
        return items;
    }
}
