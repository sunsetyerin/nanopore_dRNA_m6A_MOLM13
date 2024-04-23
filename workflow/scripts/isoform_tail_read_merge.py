#!/usr/bin/env python3
# coding=utf-8

import collections as col
import pandas as pd
import argparse

def main(isoform, polya_tails, final):
    """
    Top-level function.
    Manages input, write to files.
    """

    col_names = ["read_id","chr","strand","isoform_id","gene_id","assignment_type","assignment_events","exons","additional_info"]
    isoform = pd.read_csv(isoform, sep="\t", comment='#', names=col_names)

    polya_tails = pd.read_csv(polya_tails, sep=",").drop(["tail_start", "tail_end", "samples_per_nt", "file_path"], 1)

    all = polya_tails.merge(isoform, left_on="read_id", right_on="read_id") 
    all.to_csv(final, sep="\t")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Join isoform data with polyA tail lengths of reads.")
    parser.add_argument("isoform", type=str, help="Path to isoquant file.")
    parser.add_argument("polya_tails", type=str, help="Path to polya tails file.")
    parser.add_argument("final", type=str, help="Path to final file.")
    args = parser.parse_args()
    main(args.isoform, args.polya_tails, args.final)
