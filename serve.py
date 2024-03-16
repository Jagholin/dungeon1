import http.server
import socketserver
import os

PORT = 5000

class MyHTTPHandler(http.server.SimpleHTTPRequestHandler):
    # A bit of a hack to coax SimpleHTTPRequestHandler to send our headers
    def end_headers(self) -> None:
        self.send_header("Cross-Origin-Opener-Policy", "same-origin")
        self.send_header("Cross-Origin-Embedder-Policy", "require-corp")
        return super().end_headers()

Handler = MyHTTPHandler

os.chdir("./build/web/")
with socketserver.TCPServer(("", PORT), Handler) as httpd:
    print("serving at port", PORT)
    httpd.serve_forever()
