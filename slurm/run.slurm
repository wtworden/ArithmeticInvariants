#!/bin/bash
# This value can be adjusted to run in a condo if applicable
# or commons if the max walltime is more than 4 hours
#SBATCH --partition=scavenge
# MATLAB is an SMP application and will only use one task
# leave this value as is
#SBATCH --ntasks=1
# Tell SLURM to only place threads on physical cores, leave this value as is
#SBATCH --threads-per-core=1
# This value can be adjusted if the MATLAB code can take advantage of
# additional cores
#SBATCH --cpus-per-task=1
# This value can be adjusted if a different maximum wall time is required
#SBATCH --time=0:30:00
# This value can be adjusted to match the required range of array jobs
#SBATCH --array=1-10

# purge any modules that might be automatically loaded
module purge
# load the default MATLAB module
module load GCCcore/10.3.0
module load Python/3.9.5

readarray -t VARS < OC_census_100.txt
VAR=${VARS[$SLURM_ARRAY_TASK_ID]}
export VAR


# Change to a specific array task directory
# The SLURM_ARRAY_TASK_ID variable will be set to the current task number
cd A_${SLURM_ARRAY_TASK_ID}

# launch a matlab script
srun python test.py 30