
To launch a debug session when running DoSomething.java 

```bash
$ java -agentlib:jdwp=transport=dt_socket,address=jdbconn,server=y,suspend=y,address=4000 -cp .:target/HelloWorld-1.0-SNAPSHOT.jar pkg.DoSomething
```