#!/bin/bash
#SBATCH -c 1                               # Request one core
#SBATCH -t 0-06:00                         # Runtime in D-HH:MM format
#SBATCH -p short                           # Partition to run in
#SBATCH --mem=3G                        # Memory total in GB (for all cores)
#SBATCH --account=santagata+lsp_ss156
#SBATCH --export=SBATCH_ACCOUNT=santagata+lsp_ss156


#USER INPUTS
data_dir=/n/scratch3/users/c/ccr13/BMAL_Data/DATA/
dataset_id=1402
runtime='0-12:00'
memory='40G'
partition='short'

#Creates General Text to Be Printed in Each Job Submission File
gen_text="#!/bin/bash\n#SBATCH%1s-c%1s1\n#SBATCH%1s-t%1s"$runtime"\n#SBATCH%1s-p%1s"$partition"\n#SBATCH%1s--mem="$memory"\n"
module_text="\nmodule%1sload%1somero\n"

curr_dir=$(pwd)
cd $data_dir
folders=$(ls -d */)
cd $curr_dir

for f in $folders
do

	lsp_id=${f:0:end-1}
	echo $lsp_id

	slurm_text="#SBATCH%1s-o%1sslurm-"$lsp_id"_omero-%%j.out\n"
	import_text="omero%1simport%1s"$data_dir"*/registration/"$lsp_id".ome.tif%1s-d%1s"$dataset_id

	#Check if image already has been registered
	expected_ome_path=$data_dir$lsp_id"/registration/"$lsp_id".ome.tif"
	echo $expected_ome_path
	if ! test -f "$expected_ome_path"
	then
		echo $lsp_id" has not been registered yet."
		continue
	fi
	echo $lsp_id" has been registered. Ready to import."

	#Create job submission file for each LSPID
	job_file=$lsp_id"_omero.sh"
	printf -- $gen_text >> $job_file
	printf -- $slurm_text >> $job_file
	printf -- $module_text >> $job_file
	printf -- $import_text >> $job_file
	sbatch $job_file
done

