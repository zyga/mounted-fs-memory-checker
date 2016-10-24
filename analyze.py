#!/usr/bin/env python3
import argparse
import glob
import os

from slabinfo import slabinfo

def collect_traces(dirname, name):
    pattern = os.path.join(dirname, "slabinfo.{}.*".format(name))
    fnames = glob.glob(pattern)
    infos = [None] * len(fnames)
    for fname in fnames:
        num = int(fname.rsplit(".")[-1]) - 1
        with open(fname, encoding='ascii') as stream:
            info = slabinfo.from_stream(stream)
        infos[num] = info
    return infos


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("id")
    parser.add_argument("version_id")
    parser.add_argument("trace_name")
    ns = parser.parse_args()
    dirname = os.path.join("traces", ns.id, ns.version_id)
    initial_fname = os.path.join(dirname, 'slabinfo.initial')
    with open(initial_fname, encoding='ascii') as stream:
        initial = slabinfo.from_stream(stream)
    infos = collect_traces(dirname, ns.trace_name)
    initial_size = initial.total_size 
    last = initial_size
    print("# num-mounted extra-memory delta")
    print("0: {:.2f}MB".format(initial_size / (1 << 20)))
    for i, info in enumerate(infos, 1):
        print("{}: {:.2f}MB (delta: {:.2f}MB)".format(
            i, info.total_size / (1 << 20),
            (info.total_size - last) / (1 << 20)))
        last = info.total_size


if __name__ == "__main__":
    main()
