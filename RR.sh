#!/bin/bash

#Variable declaration
INPUT_FILE=$1
TIME_SLICE=0
QUANTA_VAL=1
ISNUM='^[0-9]+$'
PROCESS_QUEUE=true
P=() #Process list
AT=() #Arrival time list
NUT=() #NUT list
ADDED=() #add flag
TEMP_QUEUE=() #Temporary process queue

#Set output file name based on the input file name
F="${INPUT_FILE##*/}"
NAME="${F%.*}"
OUTPUT_FILE="./$NAME-out.txt"

if [ "$#" == 0 ]; then
	#Print help guidelines if the input data file is empty
	printf '\e[91mError:\e[0m %s\n' "Path to input data file cannot be empty."
	printf '\e[32m%s\e[0m ' "Sample usage:"
	printf '\e[1m%s\e[0m ' "bash ./RR.sh"
	printf '\e[3m%s\e[0m\n' "path/to/input/data/file.txt"
	exit 1

elif [ ! -f "$INPUT_FILE" ]; then
	#Print file does not exist error if file cannot be found
    printf '\e[91mError:\e[0m %s\n' "$INPUT_FILE does not exist."
	exit 1
fi

#Get quanta value form user input
printf '\n\e[1m%s\e[0m' "Enter quanta value: "
read USER_QT

if [ ! -z "$USER_QT" ]; then
	if [[ $USER_QT =~ $ISNUM ]] ; then
		QUANTA_VAL=$USER_QT
	else
		printf '\n\e[33m%s\e[0m\n\n' "Given quanta value is invalid, the default value will be applied."
	fi
else
	printf '\n\e[3m%s\e[0m\n\n' "The default quanta value of $QUANTA_VAL will be used."
fi


# Output the index of a given element within the given array.
# @param ELEM - Element to find and return the index of, within the array.
# @param ARR - The array to search for.

function GetIndex(){
	local ELEM=$1
	shift
	local ARR=("$@")
	local RESULT=""

	for index in "${!ARR[@]}"
	do
		if [ ${ARR[$index]} == $ELEM ]; then
			RESULT=$index
		fi
	done

	echo $RESULT
}

#inArray function to check whether a value exists or not
# @param STR - Element to check whether contains in the array.
# @param ARR - The array to search for.
function inArray(){
	local STR=$1
	shift
	local ARR=("$@")
	local RESULT=0

	for i in "${ARR[@]}";
	do
		if [ $i == $STR ]; then
			RESULT=1
			break
		fi
	done

	echo $RESULT
}

#Read input data file and fill arrays
while read line; do
	P+=($(echo $line | awk '{print $1}')) #Set process list
	AT+=($(echo $line | awk '{print $2}')) #Set arrival time list
	NUT+=($(echo $line | awk '{print $3}')) #Set NUT list
	ADDED+=("0") #Set add flag to zero
done < <(sort $INPUT_FILE)

#Print applied quanta value
printf '%s\n'
printf "Applied Quanta value is $QUANTA_VAL" | tee -a $OUTPUT_FILE
printf '%s\n\n' | tee -a $OUTPUT_FILE

#Print header section
printf '\t%s' ${P[@]} | tee -a $OUTPUT_FILE
printf '%s\n' | tee -a $OUTPUT_FILE

while [ $PROCESS_QUEUE == true ]; do
	QUEUE=()
	printf '%s' $TIME_SLICE | tee -a $OUTPUT_FILE
	
	#Check if there are any waiting processes in the "TEMP_QUEUE" and add them to the "QUEUE".
	if [ ${#TEMP_QUEUE[@]} -gt 0 ]; then
	
		IDX0=$(GetIndex "${TEMP_QUEUE[0]}" "${P[@]}")

		if [ ${NUT[$IDX0]} -gt 0 ]; then
			TEMP=${TEMP_QUEUE[0]}

			CURR_NUT=${NUT[$IDX0]}
			if [ $CURR_NUT -lt $QUANTA_VAL ]; then
				CURR_NUT=$QUANTA_VAL
			fi

			#Remove first element of the TEMP_QUEUE
			unset TEMP_QUEUE[0]

			#Update the QUEUE.
			QUEUE=("${TEMP_QUEUE[@]}" "$TEMP")

			#Update the NUT value.
			NUT[$IDX0]=$(($CURR_NUT-$QUANTA_VAL))
		else
			#Remove first element of the TEMP_QUEUE
			unset TEMP_QUEUE[0]
		
			#Update the QUEUE.
			QUEUE=("${TEMP_QUEUE[@]}")
		fi
				
	fi

	#Go through the arrival time list and add process to the QUEUE.
	for at_idx in ${!AT[@]}
	do
		if [[ "${ADDED[$at_idx]}" == 0 && ${AT[$at_idx]} == $TIME_SLICE ]]; then

			#Update the QUEUE.
			QUEUE+=(${P[$at_idx]})
			ADDED[$at_idx]=1

			CURR_NUT=${NUT[$at_idx]}
			if [ $CURR_NUT -lt $QUANTA_VAL ]; then
				CURR_NUT=$QUANTA_VAL
			fi

			#Update the NUT value.
			NUT[$at_idx]=$(($CURR_NUT-$QUANTA_VAL))

		elif [[ "${ADDED[$at_idx]}" == 0 && ${AT[$at_idx]} != $TIME_SLICE ]]; then
			printf '%s' | tee -a $OUTPUT_FILE
		fi
	done

	#Set data to the "TEMP_QUEUE".
	TEMP_QUEUE=(${QUEUE[@]})
	NUT_CHECK=0

	#Go through the process list and print status.
	for p_idx in ${!P[@]}
	do
		CURRENT_P=${P[$p_idx]}
		IN_QUEUE=$(inArray "${P[$p_idx]}" "${QUEUE[@]}")
		isFinished=0
		
		#If NUT is empty, set the "isFinished" flag.
		if [ ${NUT[$p_idx]} == 0 ]; then 
			isFinished=1
		else
			NUT_CHECK=${NUT[$p_idx]}
		fi 

		#Check if the process is still running.
		if [ $IN_QUEUE == 0 ]; then
			if [ $isFinished == 0 ]; then
				#If the process is not still started print "-".
				printf '\t%s' '-' | tee -a $OUTPUT_FILE
			else
				#If the process is already finished print "F".
				printf '\t%s' 'F' | tee -a $OUTPUT_FILE
			fi			
		fi

		#Go through the process QUEUE and print status.
		for q_idx in ${!QUEUE[@]}
		do
			if [ ${QUEUE[$q_idx]} == $CURRENT_P ]; then

				if [ $q_idx == 0 ]; then
					#If the process is in the front of the "QUEUE" print "R"
					printf '\t%s' 'R' | tee -a $OUTPUT_FILE
				else
					#If not print "W"
					printf '\t%s' 'W' | tee -a $OUTPUT_FILE
				fi
			
			fi
	
		done
	done
	
	#Check QUEUE and the NUT value to stop process.
	if [[ "${#QUEUE[@]}" == 0 && $NUT_CHECK == 0 ]]; then
		PROCESS_QUEUE=false
	fi

	printf '%s\n' | tee -a $OUTPUT_FILE

	#Update the TimeSlice
	let TIME_SLICE++
done

printf '%s\n' | tee -a $OUTPUT_FILE