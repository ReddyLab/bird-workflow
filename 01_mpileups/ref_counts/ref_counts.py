import os
import sys

import pandas as pd


def programName():
    return os.path.basename(sys.argv[0])


if len(sys.argv) == 1:
    pileup = sys.stdin
elif len(sys.argv) == 2:
    pileup = open(sys.argv[1], "rt")
else:
    exit(f"{programName()} [pileup file]\n")

# THE COLUMNS IN THE MPILEUP OUTPUT ARE AS FOLLOWS
#    ID
#    CHR
#    1-BASED POSITION
#    REF BASE (1=A,2=C,3=G,4=T) THIS IS FOR EASE OF DOWNSTREAM PROCESSING
#    "A" COUNT
#    "C" COUNT
#    "G" COUNT
#    "T" COUNT
reads = pd.read_csv(
    pileup,
    sep="\t",
    header=0,
    quotechar='"',
    names=[
        "id",
        "chr",
        "position",
        "ref_base",
        "a_count",
        "c_count",
        "g_count",
        "t_count",
    ],
)


def ref_alt_count(row):
    if row["ref_base"] == 1:
        ref_count = row["a_count"]
        alt_count = row[["c_count", "g_count", "t_count"]].max()
    elif row["ref_base"] == 2:
        ref_count = row["c_count"]
        alt_count = row[["a_count", "g_count", "t_count"]].max()
    elif row["ref_base"] == 3:
        ref_count = row["g_count"]
        alt_count = row[["a_count", "c_count", "t_count"]].max()
    elif row["ref_base"] == 4:
        ref_count = row["t_count"]
        alt_count = row[["a_count", "c_count", "g_count"]].max()

    return row["id"], ref_count, alt_count


ref_counts = reads.apply(ref_alt_count, axis=1, result_type="expand")
ref_counts.to_csv(sys.stdout, sep="\t", index=False, header=None)
