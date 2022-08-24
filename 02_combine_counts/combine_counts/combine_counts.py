import argparse
import os
import sys

import pandas as pd


def read_csvs(count_files):
    for file_name in count_files:
        yield pd.read_csv(
            file_name,
            sep="\t",
            index_col=0,
            names=[
                os.path.basename(file_name).replace("_counts.txt", ""),
                os.path.basename(file_name).replace("ref_counts.txt", "alt"),
            ],
        )


def run(args):
    inputs = sorted(args.inputs)
    outputs = sorted(args.outputs)

    df = pd.concat(read_csvs(inputs + outputs), axis=1).fillna(0).astype(int)

    # Filter out low count sites
    df = df[df.agg("sum", axis=1) > 0]

    df.insert(0, "input_count", len(inputs))
    df.insert(len(inputs) * 2 + 1, "output_count", len(outputs))

    df.to_csv(sys.stdout, sep="\t", header=False)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Merge counts for BIRD processing")
    parser.add_argument("--inputs", "-i", nargs="+", help="Input replicate file names")
    parser.add_argument(
        "--outputs", "-o", nargs="+", help="Output replicate file names"
    )

    args = parser.parse_args()
    run(args)
