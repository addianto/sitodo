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

// TODO Merge content from laptop

At this point, we can verify that the controller works fine as an independent unit.
The implementation of `showHello` returns the correct string value as we expected.
However, we still do not know if `showHello` will behave as intended when it has to handle an actual HTTP request.
This is where we are going to test the implementation in a mock/simulated environment.

## Test in a Mock Environment

We do know that `showHello` is an HTTP request handler implemented in a controller.
If we want to actually verify if the implementation is correct,
we can test the implementation in a simulated Web server.

Go back to the test code and update `HelloControllerTest` class with the following code snippet:

```java
// New imports
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import static java.nio.charset.StandardCharsets.UTF_8;
import static org.springframework.http.MediaType.TEXT_HTML;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

// New annotation
@WebMvcTest(HelloController.class)
class HelloControllerTest {
    
    // New instance variable
    @Autowired
    private MockMvc mockMvc;
    
    @Test
    void showHello_ok() {
        // Omitted for brevity
    } 
    
    @Test
    void showHello_okResponse() throws Exception {
        mockMvc.perform(get("/hello")).andExpectAll(
            status().isOk(),
            content().contentTypeCompatibleWith(TEXT_HTML),
            content().encoding(UTF_8),
            view().name("hello")
        );
    }
}
```

The addition of `@WebMvcTest` annotation will make the test suite
to be executed by a test runner provided by Spring framework.
It will build and run the production code in a simulated Web server.
Hence, it is possible for the test cases to run against a running application.

For example, the new test case above will use an instance of `MockMvc`,
which automatically injected by the Spring framework during runtime,
to send an HTTP GET request to `/hello` path in the application.
Then, we try to verify the HTTP response given by the application.

Try to run the test suite again, either via the shortcuts in the IDE or `mvnw test` command in the shell.
You will see that the test suite does not run instantly as they previously did.
The test runner now runs the production code on a simulated server before executing the test cases.
Once you have verified all test cases pass, save your work as a new Git commit and push it to GitHub:

```shell
# Track all changes in both production and test codes
git add src/test/java
git add src/main/java

# And commit the changes into a single commit 
git commit
```

You have gone through a single TDD cycle.
It starts with writing a test, followed by the implementation to make the test pass.
We have not covered refactoring in a TDD cycle since the production code is still quite simple.

In the next section, you will deploy the app to a Platform-as-a-Service provider and learn how to automate the deployment process.
You will also see how to ensure that the test suite is always executed whenever you pushed commits to GitHub.
Make sure you have created an account on [Heroku](https://www.heroku.com) before continuing to the next section.
