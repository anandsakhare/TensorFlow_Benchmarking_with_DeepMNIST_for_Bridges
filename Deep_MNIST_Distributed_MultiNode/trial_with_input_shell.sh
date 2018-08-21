#!/bin/sh

cd $SCRATCH/DistTF/

echo "**********************Environment Variables**********************"
env ##> ${SLURM_NODEID}_${SLURM_PROCID}.env 
echo "*****************************************************************"
num_nodes=$SLURM_JOB_NUM_NODES
echo $SLURM_NODEID

proc_id=$SLURM_PROCID

echo "Executing Deep_Mnist_MultiGPU_Per_Node.py" 
 
node_id=$SLURM_NODEID


a=$SLURM_JOB_GPUS
b=${a//[^[:digit:]]/}
num_gpu="${#b}"

num_gpu=$((num_gpu - 1))

module load tensorflow/1.7_py2_gpu
source activate

if [ $node_id -eq 0 ]; then
	if [ $proc_id -eq 0 ]; then
		task_index=$proc_id
		echo "Executing PS on  Node : $SLURM_NODEID on host : $(hostname) "
		python trial_with_input.py --batch_size=128 --num_gpu=2 --job_name='ps' --task_index=$task_index --ps_hosts='gpu017.pvt.bridges.psc.edu:2223' --worker_hosts='gpu022.pvt.bridges.psc.edu:2223,gpu022.pvt.bridges.psc.edu:2224, gpu028.pvt.bridges.psc.edu:2223,gpu028.pvt.bridges.psc.edu:2224' --data_dir='.' --proc_id=$proc_id >& ps_${task_index}.out
	else 
		continue
	fi
else		
		task_index=$(($proc_id-2))
		echo "Executing Worker on Node : $SLURM_NODEID on host : $(hostname): Taks $task_index "
		python trial_with_input.py --batch_size=128 --job_name='worker' --num_gpu=2 --ps_hosts='gpu017.pvt.bridges.psc.edu:2223' --worker_hosts='gpu022.pvt.bridges.psc.edu:2223,gpu022.pvt.bridges.psc.edu:2224, gpu028.pvt.bridges.psc.edu:2223,gpu028.pvt.bridges.psc.edu:2224' --task_index=$task_index --data_dir='.' --proc_id=$proc_id >& worker_${task_index}.out
fi
