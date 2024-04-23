#!/usr/bin/env python3
# coding=utf-8

import collections as col
import pandas as pd
import argparse

def join_exp_tails_on_map(f5c_summary, polya_tails, m6a):

    """
    Merge dataframes containing m6anet "probability_modified"(data.indiv_proba.csv) and tailfindr "tail_length"(polya_tails.csv) by read_id.
    :return: a pandas dataframe
    """

    merged_df = f5c_summary.merge(m6a, left_on="read_index", right_on="read_index").merge(polya_tails, left_on="read_name", right_on="read_id")

    return merged_df 

def main(m6a, polya_tails, f5c_summary, final):
    """
    Top-level function.
    Manages input, write to files.
    """
    m6a = pd.read_csv(m6a, sep=",")
    polya_tails = pd.read_csv(polya_tails, sep=",").drop(["tail_start", "tail_end", "samples_per_nt", "file_path"], 1)
    f5c_summary = pd.read_csv(f5c_summary, sep="\t").drop(["fast5_path","model_name","strand","num_events","num_steps","num_skips","num_stays","total_duration","shift","scale","drift","var"], 1)

    all = join_exp_tails_on_map(f5c_summary, polya_tails, m6a).drop(["read_id"],1)
    all.to_csv(final, sep="\t")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Join m6A data with polyA tail lengths of reads.")
    parser.add_argument("m6a", type=str, help="Path to m6Anet file.")
    parser.add_argument("polya_tails", type=str, help="Path to polya tails file.")
    parser.add_argument("f5c_summary", type=str, help="Path to f5c summary file.")
    parser.add_argument("final", type=str, help="Path to final file.")
    args = parser.parse_args()
    main(args.m6a, args.polya_tails, args.f5c_summary, args.final)
