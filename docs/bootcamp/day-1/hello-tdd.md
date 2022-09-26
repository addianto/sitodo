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

If the return value of a method in a controller class is a string,
then the framework expects the return value contains the name of a Web page template.

Notice there are two directories in `src` directory: `main` and `test`.
The `main` directory contains the actual code for implementing the application.
We often call the actual code as the **production code**.
In contrast, the `test` directory contains the code for testing the application.
It is also known as the **test code**.

## My First Test Case

Create a new class named `HelloControllerTest` in `controller` package of the test code.
The class will contain one or more instance methods that will execute the test cases.
Let us start with a test case that verifies `showHello` method uses a Web page template named `hello`.
Create a method named `showHello_ok` in `HelloControllerTest`:

```java
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

public class HelloControllerTest {
    
    @Test
    void showHello_ok() {
        // [Setup]
        HelloController helloController = new HelloController();
        
        // [Exercise]
        String result = helloController.showHello();
        
        // [Verify]
        assertEquals("hello", result);
        
        // [Teardown]
        // Do nothing
    }
}
```

The method that implements a test case can be structured into four sections:
**Setup**, **Exercise**, **Verify**, and **Teardown** sections.

Run the test suite via the shortcut in the editor or use Maven command `mvnw test`.
If you implement the method exactly as written in this document, the test case execution will fail.
That is the way how test-driven development is conducted.
We always (or, strive to) start with writing a test case that initially fails.

## Pass the First Test

According to the first test case, it expects the controller to use a Web page template named `hello` to generate the HTML response.
