#!/bin/bash

INPUT_FILE=$1
TIME_SLICE=0
PROCESS_QUEUE=true
P=()
AT=()
NUT=()
ADDED=()
TEMP_QUEUE=()

if [ "$#" == 0 ]; then

	printf '\e[91mError:\e[0m %s\n' "Path to input data file cannot be empty."
	printf '\e[32m%s\e[0m ' "Sample usage:"
	printf '\e[1m%s\e[0m ' "bash ./RR.sh"
	printf '\e[3m%s\e[0m\n' "path/to/input/data/file.txt"
	exit 1

elif [ ! -f "$INPUT_FILE" ]; then

    printf '\e[91mError:\e[0m %s\n' "$INPUT_FILE does not exist."
	exit 1
fi

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

while read line; do
	P+=($(echo $line | awk '{print $1}'))
	AT+=($(echo $line | awk '{print $2}'))
	NUT+=($(echo $line | awk '{print $3}'))
	ADDED+=("0")
done < <(sort $INPUT_FILE)

printf '\t%s' ${P[@]}
printf '%s\n'

while [ $PROCESS_QUEUE == true ]; do
	QUEUE=()
	printf '%s' $TIME_SLICE
	
	if [ ${#TEMP_QUEUE[@]} -gt 0 ]; then
	
		IDX0=$(GetIndex "${TEMP_QUEUE[0]}" "${P[@]}")

		if [ ${NUT[$IDX0]} -gt 0 ]; then
			TEMP=${TEMP_QUEUE[0]}
			unset TEMP_QUEUE[0]
			QUEUE=("${TEMP_QUEUE[@]}" "$TEMP")
			NUT[$IDX0]=$((${NUT[$IDX0]}-1))
		else
			unset TEMP_QUEUE[0]
			QUEUE=("${TEMP_QUEUE[@]}")
		fi
				
	fi

	for at_idx in ${!AT[@]}
	do
		if [[ "${ADDED[$at_idx]}" == 0 && ${AT[$at_idx]} == $TIME_SLICE ]]; then
			QUEUE+=(${P[$at_idx]})
			ADDED[$at_idx]=1
			NUT[$at_idx]=$((${NUT[$at_idx]}-1))

		elif [[ "${ADDED[$at_idx]}" == 0 && ${AT[$at_idx]} != $TIME_SLICE ]]; then
			printf '%s'
		fi
	done

	TEMP_QUEUE=(${QUEUE[@]})
	NUT_CHECK=0

	for p_idx in ${!P[@]}
	do
		CURRENT_P=${P[$p_idx]}
		IN_QUEUE=$(inArray "${P[$p_idx]}" "${QUEUE[@]}")
		isFinished=0
		
		if [ ${NUT[$p_idx]} == 0 ]; then 
			isFinished=1
			else

			NUT_CHECK=${NUT[$p_idx]}
		fi 

		if [ $IN_QUEUE == 0 ]; then
			if [ $isFinished == 0 ]; then
				printf '\t%s' '-'
			else
				printf '\t%s' 'F'
			fi			
		fi

		for q_idx in ${!QUEUE[@]}
		do
			if [ ${QUEUE[$q_idx]} == $CURRENT_P ]; then

				if [ $q_idx == 0 ]; then
					printf '\t%s' 'R'

					else

					printf '\t%s' 'W'
				fi
			
			fi
	
		done
	done

	
	
	if [[ "${#QUEUE[@]}" == 0 && $NUT_CHECK == 0 ]]; then
		PROCESS_QUEUE=false
	fi

	printf '%s\n'
	let TIME_SLICE++
done