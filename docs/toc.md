# Table of Contents

## Course Setup

1. Install Git
   1. Reminder about newlines, i.e. `git config --global auto.crlf input`,
      and install EditorConfig
2. Install Java
   1. Ensure JAVA_HOME and PATH configured properly
3. Install PostgreSQL
   1. Set up database from 0, i.e. `CREATE DATABASE`, `CREATE ROLE`, etc.
4. Install IDE (IntelliJ)
5. Set up GitHub account
6. Set up Fly.io account and install `flyctl`
7. At the end, verify all tools have been installed, e.g. `git --version`

## Project Scaffolding

1. Use [Spring Initializr](https://start.spring.io/)
2. Initialise Git repository in local development environment
3. Create a new online Git repository on GitHub
4. Update README.md
5. Create a first commit
6. Set up a new Git remote from local repository to online repository on GitHub
7. Push local Git history to the online repository

## Implement Landing Page
<!-- Implement stateless feature: landing page -->

1. Introduction to test-driven development
2. Outside-in TDD part 1: functional test (Selenium)
3. Create an HTML page for the landing page with custom greeting from GET request
4. Make Selenium/Selenide test pass (HTML, controller)
5. Outside-in TDD part 2: unit test in mocked environment (@MockMvc + @SpringBootTest)
6. Make unit tests implemented with Spring Boot test client pass (@MockMvc)
7. Outside-in TDD part 3: purely isolated unit test (@Test)
8. Make simple JUnit 5 unit tests pass
9. Recap

## Implement Todo List
<!-- Implement stateful feature: public todo list -->

1. Create data persistence model using JPA
2. Create data migration using Liquibase

## Implement Personalised Todo List
<!-- User authentication -->

1. Security in Spring
   1. https://stackoverflow.com/questions/42148257/unit-testing-methods-using-principal-from-spring-secucrity?noredirect=1&lq=1
2. Define user authentication model
3. Update database schema via database migration
4. Secure the existing todo list behind authentication
   1. Implement basic user view, login, logout to pass the tests
