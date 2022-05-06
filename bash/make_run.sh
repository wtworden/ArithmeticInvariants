#!/bin/bash

# arguments for this executable
RUN_NUMBER=$1    #index of this run
CENSUS_FILE=$2   # the census file to work on
PARTITION=$3     # commons or scavenge
TIME=$4          # HH:MM:SS
PREC=$5          #precision
DEG=$6           # degree
MAX_JOBS=$7      # maximum number of jobs to run at once. For serial jobs, set to 1.
MEM=$8           # amount of memory per job

# cd into the directory containing all run directories
cd nots_runs

# make the directory for this run
mkdir run_${RUN_NUMBER}

#copy the census file and python files to the run directory
cp ../$CENSUS_FILE run_${RUN_NUMBER}
cp ../python/hpc_function.py run_${RUN_NUMBER}
cp ../python/run.py run_${RUN_NUMBER}

cd run_${RUN_NUMBER}

# in the run directory, create directory data for computed arithmetic info, and job_logs for the output logs
mkdir data
mkdir job_logs

# make a temporary file completed.txt, and write to it a list containing the names of all census manifolds
# whose arithmetic invariants have already been computed in earlier runs.
touch completed.txt
for RUN_DIR in ../*
do 
    RUN_DIR_BASE=$( basename $RUN_DIR )
    if [ $RUN_DIR_BASE != run_${RUN_NUMBER} ]
    then 
        for NAME in ../$RUN_DIR_BASE/data/*
        do
            NAME_BASE=$( basename $NAME )
            echo "$NAME_BASE" >> completed.txt
        done
    fi
done

# create a file mflds_attempted.txt, which will be a list of all manifold names from $CENSUS_FILE 
# whose arithmetic invariants will be computed (or attempted) during this run. This is created
# by adding all names from $CENSUS_FILE that are not in completed.txt
touch mflds_attempted.txt
while read NAME_TO_DO
do
    if ! grep -q $NAME_TO_DO "completed.txt"
    then
        echo "$NAME_TO_DO" >> mflds_attempted.txt
    fi
done < ${CENSUS_FILE}

# delete completed.txt, as we won't need it anymore.
rm completed.txt

#get the total number of census manifolds to be computed
N=$(wc -l mflds_attempted.txt | awk '{ print $1 }')
N=$(( $N - 1 ))

#make the slurm file
touch run_${RUN_NUMBER}.slurm
SLURM=$(echo "run_${RUN_NUMBER}.slurm")

# write sbatch settings to the slurm file
echo "#!/bin/bash" >> $SLURM

# partition is either "commons" (for most jobs) or "scavenge" (for jobs less than 4 hours long)
echo "#SBATCH --partition=${PARTITION}" >> $SLURM

# for serial jobs or job arrays, these can be left as is.
echo "#SBATCH --ntasks=1" >> $SLURM
echo "#SBATCH --threads-per-core=1" >> $SLURM
echo "#SBATCH --cpus-per-task=1" >> $SLURM

# duration of job. Format is DAYS-HH:MM:SS. Can just be HH:MM:SS if days omitted.
echo "#SBATCH --time=${TIME}" >> $SLURM

# if max jobs is > 1, this will be a job array run, and $MAX_JOBS is the maximum number 
# of CPU cores that will be used at a time. If $MAX_JOBS == 1, then this will be a serial job,
# and all computations will be done one at a time on a single cpu.
if [[ $MAX_JOBS -gt 1 ]]
then
    echo "#SBATCH --array=1-${N}%${MAX_JOBS}" >> $SLURM
fi

# send output logs to ./job_logs
echo "#SBATCH -o ./job_logs/slurm-%A_%a.out" >> $SLURM

# make sure all environment variable are exported
echo "#SBATCH --export=ALL" >> $SLURM

# how much memory is needed per CPU.
echo "#SBATCH --mem-per-cpu=${MEM}G" >> $SLURM

echo "" >> $SLURM

# to get sage to work, we need to first purge, then load Anaconda, then activate sage.
echo "ml purge" >> $SLURM
echo "module load Anaconda3/2020.11" >> $SLURM
echo "source activate sage" >> $SLURM

echo "" >> $SLURM

# if $MAX_JOBS > 1, then this is a job-array run, and we split the mflds_attempted.txt file
# into an array of variables, each of which is a census manifold name. Each of these is passed 
# to run.py.
if [[ $MAX_JOBS -gt 1 ]]
then
    echo "readarray -t VARS < mflds_attempted.txt" >> $SLURM
    echo "VAR=\${VARS[\$SLURM_ARRAY_TASK_ID]}" >> $SLURM
    echo "export VAR" >> $SLURM
    echo "" >> $SLURM
    echo "srun sage run.py ${VAR} ${PREC} ${DEG}" >> $SLURM
# if $MAX_JOBS ==1, then this is a serial job, and in this case we pass the whole 
# mflds_attempted.txt file to run.py
else
    echo "srun sage run.py mflds_attempted.txt ${PREC} ${DEG}" >> $SLURM
fi


