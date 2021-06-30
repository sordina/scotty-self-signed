
# Scotty-Self-Signed

Example of using a self-signed certificate with scotty.

Cert created with:

> openssl req -new -newkey rsa:4096 -x509 -sha256 -days 365 -nodes -out server.csr -keyout server.key
