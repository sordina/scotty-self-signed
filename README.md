
# Scotty-Self-Signed

Example of using a self-signed certificate with scotty.

Cert created with:

> openssl req -new -newkey rsa:4096 -x509 -sha256 -days 365 -nodes -out server.csr -keyout server.key

By default requests should fail:

```
> curl  https://localhost:443/
curl: (60) SSL certificate problem: self signed certificate
...
```

But should succeed if insecure requests are allowed:

```
> curl -k https://localhost:443/
POST to / with req format {input {arg1 {username password}}}
```

The correct format for a request is like so:

```
> curl -k -X POST -d '{ "input": { "arg1": { "username": "user", "password": "password" } } }' https://localhost:443/
{"accessToken":"test-token"}
```

There is also a non-TLS server provided on port 8081 for sanity-checking purposes.