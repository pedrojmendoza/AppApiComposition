package service;

import java.util.*;
import org.springframework.boot.*;
import org.springframework.boot.autoconfigure.*;
import org.springframework.stereotype.*;
import org.springframework.web.bind.annotation.*;

@CrossOrigin(origins = "*")
@Controller
@EnableAutoConfiguration
public class ItemsController {

  //@RequestMapping("/api")
  @RequestMapping("/app1/api")
  public @ResponseBody ItemsList produceItems() {
      ItemsList items = new ItemsList();
      items.addItem(new Item(1, "Apples", "$2"));
      items.addItem(new Item(2, "Peaches", "$5"));
      return items;
  }

  public static void main(String[] args) throws Exception {
      SpringApplication.run(ItemsController.class, args);
  }
}
