#!/usr/bin/env python3
import argparse
import glob
import os
import re


class slabinfo:

    def __init__(self, entries, version):
        self.entries = entries
        self.version = version

    @property
    def total_size(self):
        return sum(entry.total_size for entry in self.entries)

    @classmethod
    def from_stream(cls, stream):
        header = stream.readline()
        m = re.match("^slabinfo - version: (\d+\.\d+)$", header)
        if m is None:
            raise ValueError("cannot parse slabinfo header: {!a}".format(
                header))
        version = m.group(1)
        hint = stream.readline()
        if not hint.startswith("#"):
            raise ValueError("cannot parse slabinfo hint: {!a}".format(hint))
        entries = []
        for line in stream.readlines():
            entry = slabinfo_entry.from_string(line)
            entries.append(entry)
        return cls(entries, version)


class slabinfo_entry:

    def __init__(self, name, active_objs, num_objs, objsize):
        self.name = name
        self.active_objs = active_objs
        self.num_objs = num_objs
        self.objsize = objsize

    @property
    def total_size(self):
        # NOTE: ignoring active_objs and using num_objs a this feels more
        # representative of the actual memory requirements.
        return self.num_objs * self.objsize

    @classmethod
    def from_string(cls, string):
        m = re.match("^([a-zA-Z0-9_-]+)\s+(\d+)\s+(\d+)\s+(\d+)", string)
        if m is None:
            raise ValueError("cannot parse slabinfo entry: {!a}", string)
        return cls(m.group(1), int(m.group(2)), int(m.group(3)),
                   int(m.group(4)))

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
