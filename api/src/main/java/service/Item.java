package service;

public class Item {

    private final long id;
    private final String name;
    private final String price;

    public Item(long id, String name, String price) {
        this.id = id;
        this.name = name;
        this.price = price;
    }

    public long getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public String getPrice() {
        return price;
    }
}
