#!/bin/bash
#SBATCH -p upgrade
#SBATCH --job-name='m6a'
#SBATCH --mail-type=ALL
#SBATCH --mail-user=yekim@bcgsc.ca
#SBATCH --output=logs/numbers/m6a.%j.%x.%N.log
#SBATCH --mem=250G
#SBATCH -n 15

eval "$(conda shell.bash hook)"

# activate a specific conda environment, if you so choose
conda activate /home/yekim/miniconda3/envs/MetaCompore

# go to a particular directory
cd /projects/ly_vu_direct_rna/MetaCompore

export HDF5_PLUGIN_PATH=/projects/yekim_prj/scratch/direct_rna/ont-vbz-hdf-plugin-1.0.1-Linux/usr/local/hdf5/lib/plugin

### run your commands here!
snakemake \
--cores 38 \
--singularity-args "-B /home,/projects" --use-singularity 
#--profile ./config_numbers.yaml \
#--rerun-incomplete
