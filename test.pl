for fastafile in $(find . -mindepth 1 -maxdepth 2 -name "*.fas"); do  #by MF

	#Search for all *.fas in current folder, look for name of file until _Map_ and replace all deflines in that fasta file with that name


	fastabasename=$(basename $fastafile .fas)
	fastadefline=${fastabasename%%_Map_*}
	echo "Starting work on file with basename $fastabasename"
	echo "New defline is: $fastadefline"
	#run sed to change file contents
	sed -i "s/>.\+/>$fastadefline/g" $fastafile

done 
