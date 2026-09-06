#!/usr/bin/env python3
import argparse
import json
import pathlib
import sys

try:
    import yaml
    import jsonschema
except ImportError as exc:
    print(f"missing dependency: {exc.name}", file=sys.stderr)
    raise SystemExit(2)


def get_path(obj, dotted):
    cur = obj
    for part in dotted.split('.'):
        if not isinstance(cur, dict) or part not in cur:
            raise KeyError(dotted)
        cur = cur[part]
    return cur


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--manifest', required=True)
    p.add_argument('--schema', required=True)
    p.add_argument('--get')
    args = p.parse_args()

    try:
        manifest = yaml.safe_load(pathlib.Path(args.manifest).read_text())
        schema = json.loads(pathlib.Path(args.schema).read_text())
        jsonschema.Draft202012Validator.check_schema(schema)
        jsonschema.validate(manifest, schema)
    except (OSError, ValueError, yaml.YAMLError, jsonschema.ValidationError, jsonschema.SchemaError) as exc:
        print(f"invalid manifest: {exc}", file=sys.stderr)
        return 1

    if args.get:
        try:
            value = get_path(manifest, args.get)
        except KeyError:
            print(f"manifest key not found: {args.get}", file=sys.stderr)
            return 1
        if isinstance(value, (dict, list)):
            print(json.dumps(value, separators=(',', ':')))
        elif isinstance(value, bool):
            print('true' if value else 'false')
        else:
            print(value)
    else:
        print('valid')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
