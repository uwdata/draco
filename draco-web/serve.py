#!/usr/bin/env python3

import http.server
import socketserver

PORT = 8000

Handler = http.server.SimpleHTTPRequestHandler

Handler.extensions_map.update({
    '.wasm': 'application/wasm'
})

httpd = socketserver.TCPServer(("", PORT), Handler)

print(f"Serving HTTP with WASM support on 0.0.0.0 port {PORT} (http://0.0.0.0:{PORT}/) ...")
httpd.serve_forever()