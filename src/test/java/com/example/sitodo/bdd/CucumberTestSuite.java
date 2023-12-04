package com.example.sitodo.bdd;

import io.cucumber.junit.CucumberOptions;
import net.serenitybdd.cucumber.CucumberWithSerenity;
import org.junit.runner.RunWith;

/**
 * The test runner class that runs the executable scenarios,
 * i.e. the feature files written in Gherkin format.
 */
@RunWith(CucumberWithSerenity.class) // Runs the test suite using the test runner provided by Serenity
@CucumberOptions(
    plugin = {"pretty"},
    features = "src/test/resources/features"
)
public class CucumberTestSuite {
}
