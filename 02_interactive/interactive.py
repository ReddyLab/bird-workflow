import argparse
import os
import sys

import pandas as pd


def merge_counts(count_files):
    df = pd.DataFrame()
    for file_name in count_files:
        base_name = os.path.basename(file_name)
        df_tmp = pd.read_csv(
            file_name,
            sep="\t",
            index_col=0,
            names=[
                base_name.replace("counts_for_bird.txt", "ref"),
                base_name.replace("counts_for_bird.txt", "alt"),
            ],
        )
        df = df.join(df_tmp, how="outer")
    return df


def run(args):
    inputs = sorted(args.inputs)
    outputs = sorted(args.outputs)
    input_df = merge_counts(inputs)
    output_df = merge_counts(outputs)

    # FLIP INPUT AND OUTPUT ORDER
    # cat count_files/sczps_merged_counts_for_bird.tmp_merged.txt \
    # 	| awk -v OFS='\t' '{print $1,"input_count",$18,$19,$20,$21,$22,$23,$24,$25,$26,$27,$28,$29,$30,$31,$32,$33,"output_count",$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17	}' > sczps_merged_counts_for_bird_with_header.txt
    input_df.insert(0, "input_count", len(inputs))
    output_df.insert(0, "output_count", len(outputs))
    df = pd.concat([input_df, output_df], axis=1)
    df = df.fillna(0)
    df = df.astype(int)

    # FILTER OUT LOW COUNT SITES
    # tail -n +2 sczps_merged_counts_for_bird_with_header.txt \
    # | awk -v OFS='\t' '{if((($3+$4+$5+$6+$7+$8+$9+$10+$11+$12+$13+$14+$15+$16+$17+$18) >0) && (($20+$21+$22+$23+$24+$25+$26+$27+$28+$29+$30+$31+$32+$33+$34+$35)>0))
    # 	print $1,8,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,8,$20,$21,$22,$23,$24,$25,$26,$27,$28,$29,$30,$31,$32,$33,$34,$35}' >> sczps_merged_counts_for_bird_no_header.txt

    low_count_filter = pd.concat(
        [
            df[input_df.columns].agg("sum", axis=1) > 0,
            df[output_df.columns].agg("sum", axis=1) > 0,
        ],
        axis=1,
    ).all(axis="columns")
    df = df[low_count_filter]
    df.to_csv(
        sys.stdout,
        sep="\t",
        header=False
    )


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Merge counts for BIRD processing")
    parser.add_argument("--inputs", "-i", nargs="+", help="Input replicate file names")
    parser.add_argument("--outputs", "-o", nargs="+", help="Input replicate file names")

    args = parser.parse_args()
    run(args)
