# Yet Another Hello World

```java
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class HelloController {

    @GetMapping("/hello")
    public String showHello() {
        return "";
    }
}
```

We call this stubbing or creating an empty implementation.

If the return value of a method in a controller class is `String`,
then the framework expects the return value contains the name of a Web page template.

```java
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

public class HelloControllerTest {
    
    @Test
    void showHello_ok() {
        // Setup
        HelloController helloController = new HelloController();
        
        // Exercise
        String result = helloController.showHello();
        
        // Verify
        assertEquals("hello", result);
        
        // Cleanup
    }
}
```
