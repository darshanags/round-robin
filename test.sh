#!/bin/bash

# A 1 2
# B 2 3
# C 0 4
TIME_SLICE=0
COMPLETED=false
P=("A" "B" "C")
AT=("1" "2" "0")
NUT=("2" "3" "4")
ADDED=("0" "0" "0")
Q2=()

function GetIndex(){
	local ARG1=$1
	local RESULT=""

	for index in "${!P[@]}"
	do
		if [ ${P[$index]} == $ARG1 ]; then
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


printf '\t%s' ${P[@]}
printf '%s\n'

while [ $TIME_SLICE -lt 10 ]; do
	Q=()
	printf '%s' $TIME_SLICE
	
	if [ ${#Q2[@]} -gt 0 ]; then
	
		IDX0=$(GetIndex ${Q2[0]})

		if [ ${NUT[$IDX0]} -gt 0 ]; then
			TEMP=${Q2[0]}
			unset Q2[0]
			Q=("${Q2[@]}" "$TEMP")
			NUT[$IDX0]=$((${NUT[$IDX0]}-1))
		else
			unset Q2[0]
			Q=("${Q2[@]}")
		fi
				
	fi

	for at_idx in ${!AT[@]}
	do
		if [[ "${ADDED[$at_idx]}" == 0 && ${AT[$at_idx]} == $TIME_SLICE ]]; then
			Q+=(${P[$at_idx]})
			ADDED[$at_idx]=1
			NUT[$at_idx]=$((${NUT[$at_idx]}-1))

		elif [[ "${ADDED[$at_idx]}" == 0 && ${AT[$at_idx]} != $TIME_SLICE ]]; then
			printf '%s'
		fi
	done

	Q2=(${Q[@]})

	for p_idx in ${!P[@]}
	do
		CURRENT_P=${P[$p_idx]}
		IN_Q=$(inArray "${P[$p_idx]}" "${Q[@]}")
		isFinished=0
		
		if [ ${NUT[$p_idx]} == 0 ]; then 
			isFinished=1
		fi 

		if [ $IN_Q == 0 ]; then
			if [ $isFinished == 0 ]; then
				printf '\t%s' '-'
			else
				printf '\t%s' 'F'

			fi			
		fi

		for q_idx in ${!Q[@]}
		do
			if [ ${Q[$q_idx]} == $CURRENT_P ]; then

				if [ $q_idx == 0 ]; then
					printf '\t%s' 'R'

					else

					printf '\t%s' 'W'
				fi
			
			fi
	
		done
	done

	printf '%s\n'
	let TIME_SLICE++
done