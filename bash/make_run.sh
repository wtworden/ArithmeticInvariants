#!/bin/bash

RUN_NUMBER=$1
CENSUS_FILE=$2
PARTITION=$3
TIME=$4
PREC=$5
DEG=$6
MAX_JOBS=$7


N=$(wc -l $CENSUS_FILE | awk '{ print $1 }')

cd nots_runs

mkdir run_${RUN_NUMBER}

cp ../$CENSUS_FILE run_${RUN_NUMBER}
cp ../python/hpc_function.py run_${RUN_NUMBER}
cp ../python/run.py run_${RUN_NUMBER}

cd run_${RUN_NUMBER}

mkdir job_logs

touch run_${RUN_NUMBER}.slurm

SLURM=$(echo "run_${RUN_NUMBER}.slurm")

echo "#!/bin/bash" >> $SLURM
echo "#SBATCH --partition=${PARTITION}" >> $SLURM
echo "#SBATCH --ntasks=1" >> $SLURM
echo "#SBATCH --threads-per-core=1" >> $SLURM
echo "#SBATCH --cpus-per-task=1" >> $SLURM
echo "#SBATCH --time=${TIME}" >> $SLURM
echo "#SBATCH --array=1-${N}%${MAX_JOBS}" >> $SLURM
echo "#SBATCH -o ./job_logs/slurm-%A_%a.out" >> $SLURM
echo "" >> $SLURM

echo "module purge" >> $SLURM
echo "module load GCCcore/10.3.0" >> $SLURM
echo "module load Python/3.9.5" >> $SLURM
echo "" >> $SLURM

echo "readarray -t VARS < $CENSUS_FILE" >> $SLURM
echo "VAR=\${VARS[\$SLURM_ARRAY_TASK_ID]}" >> $SLURM
echo "export VAR" >> $SLURM
echo "" >> $SLURM

echo "mkdir \${VAR}" >> $SLURM
echo "cd \${VAR}" >> $SLURM
echo "" >> $SLURM

echo "srun /projects/ww34/sage-9.0/sage ../run.py \${VAR} ${PREC} ${DEG}" >> $SLURM



