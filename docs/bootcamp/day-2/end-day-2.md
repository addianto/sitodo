# End of Day 2

Congratulations! You have reached the end of Day 2.

## What's Next?

There are some topics that we cannot cover due to time constraints.
You can check the additional materials and references mentioned in the next subsections.
The solution to the exercises is available on [GitHub](https://github.com/addianto).
But first, try to complete the exercises with your own personal efforts and check the solution only to compare your solution.

## Additional Material: Static Analysis for Code Quality & Security

If you are familiar with an IDE such as IntelliJ, they usually include an automated **static analysis** in the editor.
For example, you will see some warnings in IntelliJ if there are imports that are not used in the code.
Additionally, an IDE sometimes recommends us if there is a piece of code that can be improved.
You might have experienced several occasions where your IDE recommends you to use proper visibility modifiers in Java or extract duplicated string literals into a constant variable.

We will use GitHub's CodeQL to analyse the code for us.
However, as a service provider, GitHub will need to have access to your code.
Thus, CodeQL is only available to public, open-source projects on GitHub.
Make sure your project on GitHub is already set to public and can be accessed without login.

To set up CodeQL, create a YML file named `codeql.yml` in `.github/workflows` directory and add a new GitHub Workflow that runs CodeQL.
As a reference, you can use the template [GitHub Worfklow prepared by GitHub](https://github.com/actions/starter-workflows/blob/main/code-scanning/codeql.yml).
After you added the new workflow into the repository, each new commit pushed to GitHub will be scanned by CodeQL.
If CodeQL identified issues related to possible errors and security vulnerabilities, then it will alert you as the project's maintainer.

## References

### Spring Security

To implement authentication and security in your web application, you will need [Spring Security](https://spring.io/projects/spring-security).
Some pointers on how to implement authentication and security in overall:

-  [Getting Started](https://docs.spring.io/spring-security/reference/servlet/getting-started.html)
-  [Form-based authentication](https://docs.spring.io/spring-security/reference/servlet/authentication/passwords/form.html)
-  [Security Database Schema](https://docs.spring.io/spring-security/reference/servlet/appendix/database-schema.html)
   to know the database tables generated by default Spring Security configuration.
   You can re-use it as-is or adopt the structure to your application's database schema for storing user/account information.

### Alternative PaaS: Fly.io

At the time of writing, Heroku plans to [discontinue their free-tier](https://blog.heroku.com/next-chapter) offering at the end of November 2022.
If you plan to keep your deployed application running, you can buy the cheapest tier on Heroku or move your application to a different PaaS.
Several free PaaS alternatives exist, but most of them require you to provide credit card information to use their free-tier offering.

It is reasonable for PaaS to ask for credit card information because they want to avoid their resources from being abused.
However, for those who do not have a credit card or hard to apply for a credit card, this barrier may hinder them from actual experience deploying an application to the web. 
Since then, we tried several PaaS and found out that [Fly.io](https://fly.io) can be used without providing credit card information.
Well, to be more exact, they still ask for credit card information, but **it can be skipped**.

While Fly.io is being promoted similar to Heroku, there are several major differences:

-  You need to reserve resources manually using `flyctl` command-line tool.
   They do not provide a web-based interface to reserve resources.
-  There is minimal documentation for deploying a Java-based application on Fly.io.
   You need to prepare a [Docker-based deployment](https://fly.io/docs/reference/builders/#dockerfile) by defining a container image for running the app,
   or use [buildpack](https://fly.io/docs/reference/builders/#buildpacks) to build and run your application on their server.

The overall steps to move your deployment from Heroku to Fly.io are as follows:

1.  Dump the database schema and data from Heroku Postgres to SQL files.
2.  Create a new application **and** database resources using `flyctl` on Fly.io.
    Take note the database connection information and credentials.
3.  Configure `fly.toml` in the project that defines how your app should be build and run by Fly.io.
4.  Restore the database dump to the database instance on Heroku.
5.  Deploy the application using `flyctl` locally to verify the deployment process.
6.  If it works locally, then modify the GitHub workflow for auto-deployment to use `flyctl`.
