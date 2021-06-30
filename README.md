
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
<h1>404: File Not Found!</h1>
```