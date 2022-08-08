#!/usr/bin/env python
# =========================================================================
# This is OPEN SOURCE SOFTWARE governed by the Gnu General Public
# License (GPL) version 3, as described at www.opensource.org.
# Copyright (C)2017 William H. Majoros (martiandna@gmail.com).
#
# Adaptation by Alejandro Barrera (aebmad@gmail.com)
# Further Adaptation by Thomas Cowart (tc325@duke.edu)
# =========================================================================
import os
import re
import sys
from collections import Counter

ACGT = ["A", "C", "G", "T"]


def programName():
    return os.path.basename(sys.argv[0])


def removeIndels(bases):
    while match := re.search("(\S*)[+-](\d+)(\S*)", bases):
        left = match[1]
        indelLen = int(match[2])
        right = match[3]
        bases = f"{left}{right[indelLen:]}"

    bases = re.sub("\^.", "", bases)
    bases = re.sub("\$", "", bases)

    return bases


def parseBases(bases):
    return Counter(removeIndels(bases).upper())


# =========================================================================
# main()
# =========================================================================

if len(sys.argv) == 1:
    pileup = sys.stdin
elif len(sys.argv) == 2:
    pileup = open(sys.argv[1], "rt")
else:
    exit(f"{programName()} [pileup file]\n")

# Process the pileup file
for line in pileup:
    fields = line.split()
    if len(fields) != 6:
        continue
    (chrom, pos, ref, total, seq, _qual) = fields
    seq = seq.upper()
    pos = int(pos)
    ref = ref.upper()
    variantID = f"{chrom}@{pos}"
    for special_character in [".", ","]:
        seq = seq.replace(special_character, ref)
    counts = parseBases(seq)
    counts_str = "\t".join([str(counts[base]) for base in ACGT])
    print(variantID, chrom, pos, ACGT.index(ref) + 1, counts_str, sep="\t")
