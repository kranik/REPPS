#!/bin/bash

if [[ "$#" -eq 0 ]]; then
	echo "This program requires inputs. Type -h for help." >&2
	exit 1
fi

EV_NUM=0
DBG=0

#requires getops, but this should not be an issue since ints built in bash
while getopts ":r:s:a:t:h" opt;
do
	case $opt in
    	h)
			echo "Available flags and options:" >&1
			echo "-r [FILEPATH] -> Specify the results file to edit." >&1
			echo "-s [FILE] -> Specify the save file for the updated results file. If no save file - output to terminal." >&1
			echo "-a [NUMBER LIST] -> Specify events(sensors) to be averaged." >&1
			echo "-t [NUMBER LIST] -> Specify events(PMU) to be totalled." >&1
			echo "Mandatory options are: -r [FILE]" >&1
			exit 0 
    		;;
		#Specify the results file
		r)
			if [[ -n $RESULTS_FILE ]]; then
				echo "Invalid input: option -r has already been used!" >&2
				echo -e "===================="
				exit 1                
			fi
			#Make sure the benchmark directory selected exists
			if [[ ! -e "$OPTARG" ]]; then
				echo "-r $OPTARG does not exist. Please enter the results file to be analyzed!" >&2 
				echo -e "===================="
				exit 1
	    		else
				RESULTS_FILE="$OPTARG"
				RESULTS_START_LINE=$(awk -v SEP='\t' 'BEGIN{FS=SEP}{ if($1 !~ /#/){print (NR);exit} }' < "$RESULTS_FILE")
				#Check if results file contains data
			    	if [[ -z $RESULTS_START_LINE ]]; then 
					echo "Results file contains no data!" >&2
					echo -e "===================="
					exit 1
				else
		               #Exctract bench column and list
		           	RESULTS_BENCH_COL=$(awk -v SEP='\t' -v START=$((RESULTS_START_LINE-1)) 'BEGIN{FS=SEP}{if(NR==START){ for(i=1;i<=NF;i++){ if($i ~ /Benchmark/) { print i; exit} } } }' < "$RESULTS_FILE")
		           	if [[ -z $RESULTS_BENCH_COL ]]; then
		           		echo "Results file contains no benchmark column!" >&2
		           		echo -e "===================="
						exit 1
		               else
		                   RESULTS_BENCH_LIST=$(awk -v SEP='\t' -v START="$RESULTS_START_LINE" -v COL="$RESULTS_BENCH_COL" -v BENCH=0 'BEGIN{FS=SEP}{ if(NR > START && $COL != BENCH){print ($COL);BENCH=$COL} }' < "$RESULTS_FILE" | sort -u | tr "\n" "," | head -c -1 )
		                   if [[ -z $RESULTS_BENCH_LIST ]]; then
				               echo "Unable to extract benchmarks from result file!" >&2
				               echo -e "===================="
				               exit 1
			               fi
		               fi
		           	
		              	#Exctract freq column and list
		           	RESULTS_FREQ_COL=$(awk -v SEP='\t' -v START=$((RESULTS_START_LINE-1)) 'BEGIN{FS=SEP}{if(NR==START){ for(i=1;i<=NF;i++){ if($i ~ /Frequency/) { print i; exit} } } }' < "$RESULTS_FILE")
	          	 	if [[ -z $RESULTS_FREQ_COL ]]; then
						echo "Results file contains no freqeuncy column!" >&2
			           	echo -e "===================="
	          	 		exit 1
			          else
			               RESULTS_FREQ_LIST=$(awk -v SEP='\t' -v START="$RESULTS_START_LINE" -v DATA=0 -v COL="$RESULTS_FREQ_COL" 'BEGIN{FS=SEP}{ if(NR >= START && $COL != DATA){print ($COL);DATA=$COL} }' < "$RESULTS_FILE" | sort -u | tr "\n" "," | head -c -1 )
			               if [[ -z $RESULTS_FREQ_LIST ]]; then
			               	echo "Unable to extract freqeuncy list from result file!" >&2
				               echo -e "===================="
			                   	exit 1
		                   fi
			           fi
			           
		       	    	#Exctract run column and list
	          	 	RESULTS_RUN_COL=$(awk -v SEP='\t' -v START=$((RESULTS_START_LINE-1)) 'BEGIN{FS=SEP}{if(NR==START){ for(i=1;i<=NF;i++){ if($i ~ /Run/) { print i; exit} } } }' < "$RESULTS_FILE")
      				if [[ -z $RESULTS_RUN_COL ]]; then
		           		echo "Results file contains no run column!" >&2
			           	echo -e "===================="
			           	exit 1
		           	else
		          	     RESULTS_RUN_LIST=$(awk -v SEP='\t' -v START="$RESULTS_START_LINE" -v DATA=0 -v COL="$RESULTS_RUN_COL" 'BEGIN{FS=SEP}{ if(NR >= START && $COL != DATA){print ($COL);DATA=$COL} }' < "$RESULTS_FILE" | sort -u | sort -g | tr "\n" "," | head -c -1 )
			               if [[ -z $RESULTS_RUN_LIST ]]; then
				               echo "Unable to extract run list from result file!" >&2
				               echo -e "===================="
				               exit 1
			               fi
		               fi
		               
		               HEADER=$(awk -v SEP='\t' -v START=$((RESULTS_START_LINE-1)) 'BEGIN{FS=SEP}{if(NR==START){ print $0; exit} }' < "$RESULTS_FILE" )
					#Extract events columns from result file
					RESULTS_EVENTS_COL_START=$RESULTS_FREQ_COL
					RESULTS_EVENTS_COL_END=$(awk -v SEP='\t' -v START=$((RESULTS_START_LINE-1)) 'BEGIN{FS=SEP}{if(NR==START){ print NF; exit } }' < "$RESULTS_FILE")
					if [[ "$RESULTS_EVENTS_COL_START" -eq "$RESULTS_EVENTS_COL_END" ]]; then
						echo "No events present in result files!" >&2
						echo -e "===================="
						exit 1
					fi
          		fi
			fi
			;;
		s)
			if [[ -n $SAVE_FILE ]]; then
			    	echo "Invalid input: option -s has already been used!" >&2
				echo -e "===================="
			    	exit 1                
			fi
			if [[ -e "$OPTARG" ]]; then
			    	#wait on user input here (Y/N)
			    	#if user says Y set writing directory to that
			    	#if no then exit and ask for better input parameters
			    	echo "-s $OPTARG already exists. Continue writing in file? (Y/N)" >&1
			    	while true;
			    	do
					read -r USER_INPUT
					if [[ "$USER_INPUT" == Y || "$USER_INPUT" == y ]]; then
				    		echo "Using existing file $OPTARG" >&1
				    		break
					elif [[ "$USER_INPUT" == N || "$USER_INPUT" == n ]]; then
				    		echo "Cancelled using save file $OPTARG Program exiting." >&1
				    		exit 0                            
					else
				    		echo "Invalid input: $USER_INPUT !(Expected Y/N)" >&2
						echo "Please enter correct input: " >&2
					fi
			    	done
			    	SAVE_FILE="$OPTARG"
			else
		    		#file does not exist, set mkdir flag.
		    		SAVE_FILE="$OPTARG"
			fi
			;;   
		a)
			if [[ -n  $EVENTS_AVERAGES_LIST ]]; then
		    		echo "Invalid input: option -a has already been used!" >&2
				echo -e "===================="
		    		exit 1
			else
				EVENTS_AVERAGES_LIST="$OPTARG"
                	fi
		    	;;
		t)
			if [[ -n  $EVENTS_TOTALS_LIST ]]; then
		    		echo "Invalid input: option -t has already been used!" >&2
				echo -e "===================="
		    		exit 1
			else
				EVENTS_TOTALS_LIST="$OPTARG"
                	fi
		    	;;
		:)
			echo "Option: -$OPTARG requires an argument" >&2
			echo -e "===================="
			exit 1
			;;
		\?)
			echo "Invalid option: -$OPTARG" >&2
			echo -e "===================="
			exit 1
			;;
	esac
done

#Critical Checks
#-a flag
if [[ -n $EVENTS_AVERAGES_LIST ]]; then
	spaced_EVENTS_AVERAGES_LIST="${EVENTS_AVERAGES_LIST//,/ }"
	for EVENT in $spaced_EVENTS_AVERAGES_LIST
	do
		#Check if events list is in bounds
		if [[ "$EVENT" -gt $RESULTS_EVENTS_COL_END || "$EVENT" -lt $RESULTS_EVENTS_COL_START ]]; then 
			echo "Selected event -e $EVENT is out of bounds/invalid to result file events. Needs to be an integer value betweeen [$RESULTS_EVENTS_COL_START:$RESULTS_EVENTS_COL_END]." >&2
			echo -e "===================="
			exit 1
		fi
	done
fi

#Checkif events string contains duplicates
if [[ $(echo "$EVENTS_AVERAGES_LIST" | tr "," "\n" | wc -l) -gt $(echo "$EVENTS_AVERAGES_LIST" | tr "," "\n" | sort | uniq | wc -l) ]]; then
	echo "Selected event list -e $EVENTS_AVERAGES_LIST contains duplicates." >&2
	echo -e "===================="
	exit 1
fi

#-t flag
if [[ -n $EVENTS_TOTALS_LIST ]]; then
	spaced_EVENTS_TOTALS_LIST="${EVENTS_TOTALS_LIST//,/ }"
	for EVENT in $spaced_EVENTS_TOTALS_LIST
	do
		#Check if events list is in bounds
		if [[ "$EVENT" -gt $RESULTS_EVENTS_COL_END || "$EVENT" -lt $RESULTS_EVENTS_COL_START ]]; then 
			echo "Selected event -e $EVENT is out of bounds/invalid to result file events. Needs to be an integer value betweeen [$RESULTS_EVENTS_COL_START:$RESULTS_EVENTS_COL_END]." >&2
			echo -e "===================="
			exit 1
		fi
	done
fi

#Checkif events string contains duplicates
if [[ $(echo "$EVENTS_TOTALS_LIST" | tr "," "\n" | wc -l) -gt $(echo "$EVENTS_TOTALS_LIST" | tr "," "\n" | sort | uniq | wc -l) ]]; then
	echo "Selected event list -e $EVENTS_TOTALS_LIST contains duplicates." >&2
	echo -e "===================="
	exit 1
fi

if [[ -z $EVENTS_AVERAGES_LIST && -z $EVENTS_TOTALS_LIST ]]; then
    	echo "No events list specified! Expected -a and/or -t flag to select what to do with which data columns." >&2
    	echo -e "====================" >&1
    	exit 1
fi

#Check if event operations lists contain duplicates
if [[ -n $EVENTS_AVERAGES_LIST && -n $EVENTS_TOTALS_LIST ]]; then
	for EVENT in $spaced_EVENTS_AVERAGES_LIST
	do
		for EVENT2 in $spaced_EVENTS_TOTALS_LIST
		do
			if [[ "$EVENT" == "$EVENT2" ]]; then 
				echo "Selected event -a $EVENT is also present in totals list -t $EVENTS_TOTALS_LIST. Please use either averages ot totals for each event (you should not need two metrics)." >&2
				echo -e "===================="
				exit 1
			fi
		done
	done
fi

#Check if all benchmarks have all runs and frequencies
IFS="," read -a bencharr <<< "$RESULTS_BENCH_LIST"
IFS="," read -a runarr <<< "$RESULTS_RUN_LIST"
IFS="," read -a freqarr <<< "$RESULTS_FREQ_LIST"
IFS="," read -a evavgarr <<< "$EVENTS_AVERAGES_LIST"
IFS="," read -a evtotarr <<< "$EVENTS_TOTALS_LIST"

for bench in $(seq 0 $((${#bencharr[@]}-1)) )
do 
	#echo ${bencharr[$bench]}
	for run in $(seq 0 $((${#runarr[@]}-1)) )
	do 
		#echo ${runarr[$run]}
		for freq in $(seq 0 $((${#freqarr[@]}-1)) )
		do 
			#echo ${freqarr[$freq]};
			FLAG=$(awk -v START=$RESULTS_START_LINE -v SEP='\t' -v BENCH_COL="$RESULTS_BENCH_COL" -v BENCH_TEST=${bencharr[$bench]} -v RUN_COL="$RESULTS_RUN_COL" -v RUN_TEST=${runarr[$run]} -v FREQ_COL="$RESULTS_FREQ_COL" -v FREQ_TEST=${freqarr[$freq]} 'BEGIN{FS = SEP;}{ if (NR >= START && $BENCH_COL == BENCH_TEST && $RUN_COL == RUN_TEST && $FREQ_COL == FREQ_TEST ){print "Y";exit}}' < "$RESULTS_FILE")
			if [[ $FLAG != "Y" ]]; then 
				echo "WARNING: Data for ${bencharr[$bench]} ${runarr[$run]} ${freqarr[$freq]} not present in results file!"
				DATAMISSING_FLAG=1
			fi
		done
	done
done

if [[ $DATAMISSING_FLAG == 1 ]]; then
    	echo -e "Possibly incomplete data in results file -> $RESULTS_FILE" >&1
	echo -e "Several warnings have been issued when processing." >&1
	echo -e "Continue with data processing? (Y/N)" >&1
    	while true;
    	do
		read -r USER_INPUT
		if [[ "$USER_INPUT" == Y || "$USER_INPUT" == y ]]; then
	    		echo "Using existing file $OPTARG" >&1
	    		break
		elif [[ "$USER_INPUT" == N || "$USER_INPUT" == n ]]; then
	    		echo "Cancelled using save file $OPTARG Program exiting." >&1
	    		exit 0                            
		else
	    		echo "Invalid input: $USER_INPUT !(Expected Y/N)" >&2
			echo "Please enter correct input: " >&2
		fi
    	done
fi

#Sanity checks
echo -e "===================="
if [[ -z $RESULTS_FILE ]]; then
    	echo "Nothing to run! Expected -r flag." >&2
    	echo -e "====================" >&1
    	exit 1
fi
echo -e "Critical checks passed!"  >&1
echo -e "===================="
echo -e "--------------------" >&1
#Add program sanity checks (filename;mode;event list;header)
#Results file sanito check
echo -e "Using specified results file -> $RESULTS_FILE" >&1
echo -e "--------------------" >&1
echo -e "Extracted benchmark column from file:">&1
echo -e "$RESULTS_BENCH_COL" >&1
echo -e "Extracted benchmark list from file:">&1
echo -e "$RESULTS_BENCH_LIST" >&1
#BENCHS="${RESULTS_BENCH_LIST//,/ }"
echo -e "--------------------" >&1
echo -e "Extracted run column from file:">&1
echo -e "$RESULTS_RUN_COL" >&1
echo -e "Extracted run list from file:" >&1
echo -e  "$RESULTS_RUN_LIST" >&1
#RUNS="${RESULTS_RUN_LIST//,/ }"
echo -e "--------------------" >&1
echo -e "Extracted freqeuncy column from file:">&1
echo -e "$RESULTS_FREQ_COL" >&1
echo -e "Extracted frequency list from file:" >&1
echo -e "$RESULTS_FREQ_LIST" >&1
#FREQS="${RESULTS_FREQ_LIST//,/ }"
echo -e "--------------------" >&1
if [[ -n $EVENTS_AVERAGES_LIST ]]; then
	EVENTS_AVERAGES_LIST_LABELS=$(awk -v SEP='\t' -v START=$((RESULTS_START_LINE-1)) -v COLUMNS="$EVENTS_AVERAGES_LIST" 'BEGIN{FS = SEP;len=split(COLUMNS,ARRAY,",")}{if (NR == START){for (i = 1; i <= len; i++){print $ARRAY[i]"(avg)"}}}' < "$RESULTS_FILE" | tr "\n" "," | head -c -1)
	echo -e "Extracted averages list from file:" >&1
	echo -e  "$EVENTS_AVERAGES_LIST -> $EVENTS_AVERAGES_LIST_LABELS" >&1
	echo -e "--------------------" >&1
fi
if [[ -n $EVENTS_TOTALS_LIST ]]; then
	EVENTS_TOTALS_LIST_LABELS=$(awk -v SEP='\t' -v START=$((RESULTS_START_LINE-1)) -v COLUMNS="$EVENTS_TOTALS_LIST" 'BEGIN{FS = SEP;len=split(COLUMNS,ARRAY,",")}{if (NR == START){for (i = 1; i <= len; i++){print $ARRAY[i]"(tot)"}}}' < "$RESULTS_FILE" | tr "\n" "," | head -c -1)
	echo -e "Extracted totals list from file:" >&1
	echo -e  "$EVENTS_TOTALS_LIST -> $EVENTS_TOTALS_LIST_LABELS" >&1
	echo -e "--------------------" >&1
fi
echo -e "Extracted header from file:">&1
echo -e "$HEADER" >&1
echo -e "Constructing new header:" >&1
[[ -n $EVENTS_AVERAGES_LIST ]] && EVENTS_AVERAGES_LIST_LABELS="\t"$EVENTS_AVERAGES_LIST_LABELS
[[ -n $EVENTS_TOTALS_LIST ]] && EVENTS_TOTALS_LIST_LABELS="\t"$EVENTS_TOTALS_LIST_LABELS
BETTER_HEADER=$(echo "#Timestamp\tBenchmark\tRun(#)\tCPU Frequency(MHz)\tSamples(#)$EVENTS_AVERAGES_LIST_LABELS$EVENTS_TOTALS_LIST_LABELS" | tr "," "\t")
echo -e "$BETTER_HEADER" >&1
echo -e "--------------------" >&1
#Save file sanity check
if [[ -z $SAVE_FILE ]]; then 
	echo "No save file specified! Output to terminal." >&1
	echo -e "--------------------" >&1
	echo -e "====================" >&1
	echo -e "$BETTER_HEADER" >&1
else
	echo "Using user specified output save file -> $SAVE_FILE" >&1
	echo -e "--------------------" >&1
	echo -e "====================" >&1
    	echo -e "$BETTER_HEADER" > "$SAVE_FILE"
fi

TIMESTAMP=1
for freq in $(seq 0 $((${#freqarr[@]}-1)) )
do 
	for run in $(seq 0 $((${#runarr[@]}-1)) )
	do 
		for bench in $(seq 0 $((${#bencharr[@]}-1)) )
		do 
			SAMPLECOUNT=$(awk -v START=$RESULTS_START_LINE -v SEP='\t' -v FREQ_COL="$RESULTS_FREQ_COL" -v FREQ_TEST=${freqarr[$freq]} -v RUN_COL="$RESULTS_RUN_COL" -v RUN_TEST=${runarr[$run]} -v BENCH_COL="$RESULTS_BENCH_COL" -v BENCH_TEST=${bencharr[$bench]} 'BEGIN{FS = SEP; LINES = 0}{ if (NR >= START && $FREQ_COL == FREQ_TEST && $RUN_COL == RUN_TEST && $BENCH_COL == BENCH_TEST){LINES++}}END{print LINES}' < "$RESULTS_FILE")
			#echo $SAMPLECOUNT
			if [[ $SAMPLECOUNT == 0 ]]; then
				continue
			else
				LINEDATA=""
				for colavg in $(seq 0 $((${#evavgarr[@]}-1)) )
				do 
					EVTOT=$(awk -v START=$RESULTS_START_LINE -v SEP='\t' -v FREQ_COL="$RESULTS_FREQ_COL" -v FREQ_TEST=${freqarr[$freq]} -v RUN_COL="$RESULTS_RUN_COL" -v RUN_TEST=${runarr[$run]} -v BENCH_COL="$RESULTS_BENCH_COL" -v BENCH_TEST=${bencharr[$bench]} -v DATA_COL=${evavgarr[$colavg]} 'BEGIN{FS = SEP; OFMT = "%.0f"; DATA = 0}{ if (NR >= START && $FREQ_COL == FREQ_TEST && $RUN_COL == RUN_TEST && $BENCH_COL == BENCH_TEST){DATA+=$DATA_COL}}END{print DATA}' < "$RESULTS_FILE")
					EVAVG=$(echo "scale=10; $EVTOT/$SAMPLECOUNT;" | bc | awk '{printf "%.10f", $0}') #use awk to print leading 0 since bc fucks up
					#echo $EVAVG
					LINEDATA="$LINEDATA\t$EVAVG"
				done
				for coltot in $(seq 0 $((${#evtotarr[@]}-1)) )
				do 
					EVTOT=$(awk -v START=$RESULTS_START_LINE -v SEP='\t' -v FREQ_COL="$RESULTS_FREQ_COL" -v FREQ_TEST=${freqarr[$freq]} -v RUN_COL="$RESULTS_RUN_COL" -v RUN_TEST=${runarr[$run]} -v BENCH_COL="$RESULTS_BENCH_COL" -v BENCH_TEST=${bencharr[$bench]} -v DATA_COL=${evtotarr[$coltot]} 'BEGIN{FS = SEP; OFMT = "%.0f"; DATA = 0}{ if (NR >= START && $FREQ_COL == FREQ_TEST && $RUN_COL == RUN_TEST && $BENCH_COL == BENCH_TEST){DATA+=$DATA_COL}}END{print DATA}' < "$RESULTS_FILE")
					LINEDATA="$LINEDATA\t$EVTOT"
				done
				PROCDATA="$TIMESTAMP\t${bencharr[$bench]}\t${runarr[$run]}\t${freqarr[$freq]}\t$SAMPLECOUNT$LINEDATA"
				if [[ -z $SAVE_FILE ]]; then 
				    echo -e "$PROCDATA" >&1
				else
				    echo -e "$PROCDATA" >> "$SAVE_FILE"
				fi
		  		((TIMESTAMP++))
			fi
		done
	done
done

echo -e "===================="
echo "Script Done! :)"
echo -e "===================="
exit
