import argparse
import os
import sys

import pandas as pd


def merge_counts(count_files):
    base_names = [os.path.basename(file_name) for file_name in count_files]
    return [
        pd.read_csv(
            file_name,
            sep="\t",
            index_col=0,
            names=[
                base_name.replace("counts_for_bird.txt", "ref"),
                base_name.replace("counts_for_bird.txt", "alt"),
            ],
        )
        for file_name, base_name in zip(count_files, base_names)
    ]


def run(args):
    inputs = sorted(args.inputs)
    outputs = sorted(args.outputs)
    input_df = pd.concat(merge_counts(inputs), axis=1).sort_index()
    output_df = pd.concat(merge_counts(outputs), axis=1).sort_index()

    input_df.insert(0, "input_count", len(inputs))
    output_df.insert(0, "output_count", len(outputs))
    df = pd.concat([input_df, output_df], axis=1).fillna(0).astype(int)

    # Filter any positions where there are no input reads or output reads
    # I suspect there's a better way to do this.
    low_count_filter = pd.concat(
        [
            df[input_df.columns].agg("sum", axis=1) > 0,
            df[output_df.columns].agg("sum", axis=1) > 0,
        ],
        axis=1,
    ).all(axis="columns")
    df[low_count_filter].to_csv(sys.stdout, sep="\t", header=False)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Merge counts for BIRD processing")
    parser.add_argument("--inputs", "-i", nargs="+", help="Input replicate file names")
    parser.add_argument("--outputs", "-o", nargs="+", help="Output replicate file names")

    args = parser.parse_args()
    run(args)
