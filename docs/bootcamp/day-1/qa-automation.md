# Quality Assurance & Automation

In order to make the production code can be built and deployed on Heroku,
we have to follow the rules dictated by the service provider (i.e. Heroku).

Create a new file called `Procfile` in the root project directory.
It defines one or more processes that can run on Heroku's environment.
For our purpose today, you only need to define a single process called `web` that runs the application.
The content can be seen in the following snippet:

```procfile
web: java -Dserver.port=$PORT $JAVA_OPTS -jar target/*.jar
```

You also need to create a new file named `system.properties` in the root project directory.
It will be used to bind a specific version of Java to the deployment environment.
The content can be seen in the following snippet:

```properties
java.runtime.version=17
```

Add new files into local Git history and push the commit to GitHub:

```shell
git add Procfile system.properties
git commit
git push origin main
```
