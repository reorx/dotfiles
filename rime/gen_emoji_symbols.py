# Usage: python gen_emoji_symbols.py en_emoji ~code/unicode-emoji-json/data-by-emoji.json ~/Library/Rime/en_dicts
import oyaml as yaml
import sys
import json
from pathlib import Path
from collections import OrderedDict


class IndentDumper(yaml.Dumper):
    def increase_indent(self, flow=False, indentless=False):
        return super(IndentDumper, self).increase_indent(flow, False)


def yaml_dump(d, f):
    yaml.dump(d, f, Dumper=IndentDumper, default_flow_style=False, sort_keys=False, allow_unicode=True)




def main():
    name = sys.argv[1]
    json_file = sys.argv[2]
    outdir = Path(sys.argv[3])
    with open(json_file, 'r') as f:
        emojis = json.load(f)

    lines = []
    for emoji, d in emojis.items():
        line = f'{emoji}\t{d["slug"]}'
        lines.append(line)

    header = f"""\
---
name: {name}
version: "2023-12-10"
sort: by_weight
...
"""

    outfile = outdir.joinpath(f'{name}.dict.yaml')
    print(f'write to: {outfile}')
    with open(outfile, 'w') as f:
        f.write(header + '\n'.join(lines))


if __name__ == '__main__':
    main()
