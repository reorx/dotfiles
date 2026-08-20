#!/usr/bin/env python3
"""Generate colors.js from herdr config.toml custom.* theme colors,
then serve index.html with a save endpoint that writes colors back
to config.toml via minimal string replacement."""

import json
import re
import webbrowser
from functools import partial
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

CONFIG_PATH = Path.home() / '.config/herdr/config.toml'
HERE = Path(__file__).resolve().parent

COLOR_LINE_RE = re.compile(r'^custom\.(\w+)\s*=\s*"([^"]*)"', re.MULTILINE)


def parse_colors(text):
    return {m.group(1): m.group(2) for m in COLOR_LINE_RE.finditer(text)}


def replace_color(text, name, value):
    pattern = re.compile(r'^(custom\.%s\s*=\s*")[^"]*(")' % re.escape(name), re.MULTILINE)
    return pattern.subn(lambda m: m.group(1) + value + m.group(2), text, count=1)


def generate_colors_js():
    colors = parse_colors(CONFIG_PATH.read_text())
    js = 'window.COLORS = %s;\n' % json.dumps(colors, indent=2)
    (HERE / 'colors.js').write_text(js)
    print(f'colors.js generated with {len(colors)} colors')
    return colors


class Handler(SimpleHTTPRequestHandler):
    def do_POST(self):
        if self.path != '/update':
            self.send_error(404)
            return
        length = int(self.headers.get('Content-Length', 0))
        data = json.loads(self.rfile.read(length))
        name, value = data['name'], data['value']
        text = CONFIG_PATH.read_text()
        new_text, n = replace_color(text, name, value)
        if n:
            CONFIG_PATH.write_text(new_text)
            print(f'updated custom.{name} = {value!r}')
        else:
            print(f'no match for custom.{name}, config not changed')
        body = json.dumps({'ok': bool(n)}).encode()
        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Content-Length', str(len(body)))
        self.end_headers()
        self.wfile.write(body)


def main():
    generate_colors_js()
    server = ThreadingHTTPServer(('127.0.0.1', 0), partial(Handler, directory=str(HERE)))
    url = 'http://127.0.0.1:%d/' % server.server_address[1]
    print(f'serving at {url} (ctrl-c to stop)')
    webbrowser.open(url)
    server.serve_forever()


if __name__ == '__main__':
    main()
