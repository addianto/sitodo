# Table of Contents

1. Course Setup
   1. Install Git
   2. Install Java
   3. Install PostgreSQL
   4. Install IDE (IntelliJ)
   5. Setup GitHub
   6. Setup Fly.io and install `flyctl`
   7. At the end, verify all tools have been installed, e.g. `git --version`
2. Project Scaffolding
   1. Use [Spring Initializr](https://start.spring.io/)
   2. Initialise Git repository in local development environment
   3. Create a new online Git repository on GitHub
   4. Update README.md
   5. Create a first commit
   6. Set up a new Git remote from local repository to online repository on GitHub
   7. Push local Git history to the online repository
3. Implement stateless feature: landing page
   1. Create a HTML page for the landing page with custom greeting from GET request
   2. Introduction to test-driven development
   3. Outside-in TDD part 1: functional test (Selenium)
   4. Make Selenium/Selenide test pass (HTML, controller)
   5. Outside-in TDD part 2: unit test in mocked environment (@MockMvc + @SpringBootTest)
   6. Make unit tests implemented with Spring Boot test client pass (@MockMvc)
   7. Outside-in TDD part 3: purely isolated unit test (@Test)
   8. Make simple JUnit 5 unit tests pass
   9. Recap
4. Implement basic authentication (username & password)
   1. Security in Spring
   2. https://stackoverflow.com/questions/42148257/unit-testing-methods-using-principal-from-spring-secucrity?noredirect=1&lq=1
   3. Define user model
   4. Create database migration scripts (changelogs in Liquibase speak)
   5. Basic user view, start from tests (@MockMvc and basic unit tests)
   6. Implement basic user view, login, logout to pass the tests
5. Implement stateful feature: todo list of a user
   1. TBD.
