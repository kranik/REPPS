#!/bin/bash

if [[ "$#" -eq 0 ]]; then
	echo "This program requires inputs. Type -h for help." >&2
	exit 1
fi

EV_NUM=0
DBG=0

#requires getops, but this should not be an issue since ints built in bash
while getopts ":r:s:h" opt;
do
	case $opt in
    	h)
			echo "Available flags and options:" >&1
			echo "-r [FILEPATH] -> Specify the results file to edit." >&1
			echo "-s [FILE] -> Specify the save file for the updated results file. If no save file - output to terminal." >&1
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
		                   #RESULTS_BENCH_LIST=$(awk -v SEP='\t' -v START="$RESULTS_START_LINE" -v COL="$RESULTS_BENCH_COL" -v BENCH=0 'BEGIN{FS=SEP}{ if(NR > START && $COL != BENCH){print ($COL);BENCH=$COL} }' < "$RESULTS_FILE" | sort -u | sort -R | sed 's/ /\\n/g' )
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
		               #CCYCLES_COLUMN=$(awk -v SEP='\t' -v START=$((RESULTS_START_LINE-1)) 'BEGIN{FS=SEP}{if(NR==START){ for(i=1;i<=NF;i++){ if($i ~ /time/) { print i; exit} } } }' < "$RESULTS_FILE")
		               CCYCLES_COLUMN=$(awk -v SEP='\t' -v START=$((RESULTS_START_LINE-1)) 'BEGIN{FS=SEP}{if(NR==START){ for(i=1;i<=NF;i++){ if($i ~ /Energy/) { print i+1; exit} } } }' < "$RESULTS_FILE")
		               SENS_NUM=$(awk -v SEP='\t' -v START=$((RESULTS_START_LINE-1)) -v COL_START=$((RESULTS_FREQ_COL+1)) -v COL_END="$CCYCLES_COLUMN" 'BEGIN{FS=SEP}{if(NR==START){ for(i=COL_START;i<COL_END;i++) print $i} }' < "$RESULTS_FILE" | wc -l)
		               EV_NUM=$(awk -v SEP='\t' -v START=$((RESULTS_START_LINE-1)) -v COL_START="$CCYCLES_COLUMN" 'BEGIN{FS=SEP}{if(NR==START){ for(i=COL_START;i<=NF;i++) print $i} }' < "$RESULTS_FILE" | wc -l)
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
echo -e "Extracted run list from file:" >&1
echo -e  "$RESULTS_RUN_LIST" >&1
#RUNS="${RESULTS_RUN_LIST//,/ }"
echo -e "--------------------" >&1
echo -e "Extracted benchmark list from file:">&1
echo -e "$RESULTS_BENCH_LIST" >&1
#BENCHS="${RESULTS_BENCH_LIST//,/ }"
echo -e "--------------------" >&1
echo -e "Extracted freqeuncy column from file:">&1
echo -e "$RESULTS_FREQ_COL" >&1
echo -e "--------------------" >&1
echo -e "Extracted frequency list from file:" >&1
echo -e "$RESULTS_FREQ_LIST" >&1
#FREQS="${RESULTS_FREQ_LIST//,/ }"
echo -e "--------------------" >&1
echo -e "Extracted CPU CYCLES column from file:">&1
echo -e "$CCYCLES_COLUMN" >&1
echo -e "--------------------" >&1
echo -e "Extracted number of sensors from file:">&1
echo -e "$SENS_NUM" >&1
echo -e "--------------------" >&1
echo -e "Extracted number of events from file:">&1
echo -e "$EV_NUM" >&1
echo -e "--------------------" >&1
echo -e "Extracted header from file:">&1
echo -e "$HEADER" >&1
echo -e "--------------------" >&1
#Save file sanity check
if [[ -z $SAVE_FILE ]]; then 
	echo "No save file specified! Output to terminal." >&1
else
	echo "Using user specified output save file -> $SAVE_FILE" >&1
    echo -e "$HEADER" > "$SAVE_FILE"
fi
echo -e "--------------------" >&1
echo -e "===================="

SAMPLES=0
DATAPOINT=0

#Get data for first benchmark
#TIME_BENCH_DATA=$(awk -v SEP='\t' -v START="$RESULTS_START_LINE" -v COL_START="$RESULTS_BENCH_COL" -v COL_END=$((RESULTS_FREQ_COL+1)) 'BEGIN{FS=SEP}{if(NR==START){ for(i=COL_START;i<COL_END;i++) print $i} }' < "$RESULTS_FILE" | tr "\n" " " | head -c -1)
RUN_SELECT=$(awk -v SEP='\t' -v START="$RESULTS_START_LINE" -v COL="$RESULTS_RUN_COL" 'BEGIN{FS=SEP}{if(NR==START){print $COL;exit} }' < "$RESULTS_FILE")
FREQ_SELECT=$(awk -v SEP='\t' -v START="$RESULTS_START_LINE" -v COL="$RESULTS_FREQ_COL" 'BEGIN{FS=SEP}{if(NR==START){print $COL;exit} }' < "$RESULTS_FILE")
BENCH_SELECT=$(awk -v SEP='\t' -v START="$RESULTS_START_LINE" -v COL="$RESULTS_BENCH_COL" 'BEGIN{FS=SEP}{if(NR==START){print $COL;exit} }' < "$RESULTS_FILE")
for i in $(seq 1 "$SENS_NUM")
do
    eval SENS_$i=$(awk -v SEP='\t' -v START="$RESULTS_START_LINE" -v COL=$((RESULTS_FREQ_COL+"$i")) 'BEGIN{FS=SEP}{if(NR==START){print $COL;exit} }' < "$RESULTS_FILE")
    (( $DBG )) && echo -e "SENS_$i=""$(eval echo -e "\$SENS_$i")"
done
for i in $(seq 1 "$EV_NUM")
do
    eval EV_$i=$(awk -v SEP='\t' -v START="$RESULTS_START_LINE" -v COL=$((CCYCLES_COLUMN-1+"$i")) 'BEGIN{FS=SEP}{if(NR==START){print $COL;exit} }' < "$RESULTS_FILE")
    (( $DBG )) && echo -e "EV_$i=""$(eval echo -e "\$EV_$i")"
done
((SAMPLES++))
(( $DBG )) && echo -e "$BENCH_SELECT\t$RUN_SELECT\t$FREQ_SELECT"

for LINE in $(seq $((RESULTS_START_LINE+1)) 1 "$(wc -l "$RESULTS_FILE" | awk '{print $1}')") 
do
    (( $DBG )) && echo "LINE=$LINE"
    if [[ $(awk -v SEP='\t' -v START="$LINE" -v RUN_COL="$RESULTS_RUN_COL" -v RUN="$RUN_SELECT" -v FREQ_COL="$RESULTS_FREQ_COL" -v FREQ="$FREQ_SELECT" -v BENCH_COL="$RESULTS_BENCH_COL" -v BENCH="$BENCH_SELECT" 'BEGIN{FS=SEP}{if(NR==START && $BENCH_COL==BENCH && $FREQ_COL==FREQ && $RUN_COL==RUN){print 1;exit} }' < "$RESULTS_FILE") ]]; then
        (( $DBG )) && echo "next lines"
		(( $DBG )) && echo "Sensors:"
        for i in $(seq 1 "$SENS_NUM")
        do
            SENS_val=$(eval echo -e "\$SENS_$i")
            (( $DBG )) && echo "val="$SENS_val
            SENS_new=$(awk -v SEP='\t' -v START="$LINE" -v COL=$((RESULTS_FREQ_COL+"$i")) 'BEGIN{FS=SEP}{if(NR==START){print $COL;exit} }' < "$RESULTS_FILE")
            (( $DBG )) && echo "new="$SENS_new
            SENS_sum=$(echo "$SENS_val+$SENS_new;" | bc )
            (( $DBG )) && echo "sum="$SENS_sum
            eval SENS_$i="$SENS_sum"
        done
		(( $DBG )) && echo "Events:"
        for i in $(seq 1 "$EV_NUM")
        do
            EV_val=$(eval echo -e "\$EV_$i")
            (( $DBG )) && echo "val="$EV_val
            EV_new=$(awk -v SEP='\t' -v START="$LINE" -v COL=$((CCYCLES_COLUMN-1+"$i"))  'BEGIN{FS=SEP}{if(NR==START){print $COL;exit} }' < "$RESULTS_FILE")
            (( $DBG )) && echo "new="$EV_new
            EV_sum=$(echo "$EV_val+$EV_new;" | bc )
            (( $DBG )) && echo "sum="$EV_sum
            eval EV_$i=$EV_sum
        done
        ((SAMPLES++))        
    else
        (( $DBG )) && echo "next data point"
        (( $DBG )) && echo "sens1=$SENS_1"
        (( $DBG )) && echo "samples=$SAMPLES"
        SENS_avg=$(echo "scale=10; $SENS_1/$SAMPLES;" | bc | awk '{printf "%.10f", $0}') #use awk to print leading 0 since bc fucks up
        (( $DBG )) && echo "sens1avg=$SENS_avg"
        SENSORS_DATA="$SENS_avg"
        #Output average of all samples and start next sampling point
        for i in $(seq 2 "$SENS_NUM")
        do
            SENS_val=$(eval echo -e "\$SENS_$i")
            (( $DBG )) && echo "sens$i=$SENS_val"
            SENS_avg=$(echo "scale=10; $SENS_val/$SAMPLES;" | bc | awk '{printf "%.10f", $0}') #use awk to print leading 0 since bc fucks up
            (( $DBG )) && echo "sens$i""avg=$SENS_avg"
            SENSORS_DATA="$SENSORS_DATA\t$SENS_avg"
        done
        (( $DBG )) && echo "ev1=$EV_1"
        EVENTS_DATA="$EV_1"        
        for i in $(seq 2 "$EV_NUM")
        do
            EV_val=$(eval echo -e "\$EV_$i")
            (( $DBG )) && echo "ev$i=$EV_val"
            EVENTS_DATA="$EVENTS_DATA\t$EV_val"
        done

        #Output upscaled sample data
        ((DATAPOINT++))
        if [[ -z $SAVE_FILE ]]; then 
	        echo -e "$DATAPOINT\t$BENCH_SELECT\t$RUN_SELECT\t$FREQ_SELECT\t$SENSORS_DATA\t$EVENTS_DATA" >&1
        else
            echo -e "$DATAPOINT\t$BENCH_SELECT\t$RUN_SELECT\t$FREQ_SELECT\t$SENSORS_DATA\t$EVENTS_DATA" >> "$SAVE_FILE"
        fi

        SAMPLES=0            
        #Reset Samples and set for next benchmark
        RUN_SELECT=$(awk -v SEP='\t' -v START="$LINE" -v COL="$RESULTS_RUN_COL" 'BEGIN{FS=SEP}{if(NR==START){print $COL;exit} }' < "$RESULTS_FILE")
        FREQ_SELECT=$(awk -v SEP='\t' -v START="$LINE" -v COL="$RESULTS_FREQ_COL" 'BEGIN{FS=SEP}{if(NR==START){print $COL;exit} }' < "$RESULTS_FILE")
        BENCH_SELECT=$(awk -v SEP='\t' -v START="$LINE" -v COL="$RESULTS_BENCH_COL" 'BEGIN{FS=SEP}{if(NR==START){print $COL;exit} }' < "$RESULTS_FILE")
        for i in $(seq 1 "$SENS_NUM")
        do
            eval SENS_$i=$(awk -v SEP='\t' -v START="$LINE" -v COL=$((RESULTS_FREQ_COL+"$i")) 'BEGIN{FS=SEP}{if(NR==START){print $COL;exit} }' < "$RESULTS_FILE")
            (( $DBG )) && echo -e "SENS_$i=""$(eval echo -e "\$SENS_$i")"
        done
        for i in $(seq 1 "$EV_NUM")
        do
            eval EV_$i=$(awk -v SEP='\t' -v START="$LINE" -v COL=$((CCYCLES_COLUMN-1+"$i")) 'BEGIN{FS=SEP}{if(NR==START){print $COL;exit} }' < "$RESULTS_FILE")
            (( $DBG )) && echo -e "EV_$i=""$(eval echo -e "\$EV_$i")"
        done
        ((SAMPLES++))
    fi
done
#Analyse last benchmark
SENS_avg=$(echo "scale=10; $SENS_1/$SAMPLES;" | bc | awk '{printf "%.10f", $0}') #use awk to print leading 0 since bc fucks up
SENSORS_DATA="$SENS_avg"
#Output average of all samples and start next sampling point
for i in $(seq 2 "$SENS_NUM")
do
    SENS_val=$(eval echo -e "\$SENS_$i")
    SENS_avg=$(echo "scale=10; $SENS_val/$SAMPLES;" | bc | awk '{printf "%.10f", $0}') #use awk to print leading 0 since bc fucks up
    SENSORS_DATA="$SENSORS_DATA\t$SENS_avg"
done
EVENTS_DATA="$EV_1"        
for i in $(seq 2 "$EV_NUM")
do
    EV_val=$(eval echo -e "\$EV_$i")
    EVENTS_DATA="$EVENTS_DATA\t$EV_val"
done
#Output upscaled sample data
((DATAPOINT++))
if [[ -z $SAVE_FILE ]]; then 
    echo -e "$DATAPOINT\t$BENCH_SELECT\t$RUN_SELECT\t$FREQ_SELECT\t$SENSORS_DATA\t$EVENTS_DATA" >&1
else
    echo -e "$DATAPOINT\t$BENCH_SELECT\t$RUN_SELECT\t$FREQ_SELECT\t$SENSORS_DATA\t$EVENTS_DATA" >> "$SAVE_FILE"
fi

echo -e "===================="
echo "Script Done! :)"
echo -e "===================="
exit
