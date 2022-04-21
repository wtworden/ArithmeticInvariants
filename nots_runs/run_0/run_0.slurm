#!/bin/bash
#SBATCH --partition=commons
#SBATCH --ntasks=1
#SBATCH --threads-per-core=1
#SBATCH --cpus-per-task=1
#SBATCH --time=12:00:00
#SBATCH --array=1-70%20
#SBATCH -o ./job_logs/slurm-%A_%a.out

module purge
module load GCCcore/10.3.0
module load Python/3.9.5

readarray -t VARS < OC_census_100.txt
VAR=${VARS[$SLURM_ARRAY_TASK_ID]}
export VAR

mkdir ${VAR}
cd ${VAR}

srun /projects/ww34/sage-9.0/sage ../run.py ${VAR} 200 20
