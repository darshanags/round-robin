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

function Clean(){
	local ARR_TO_CLEAN=("$@")
	
	for index in ${!ARR_TO_CLEAN[@]}
	do
		if [ ${ARR_TO_CLEAN[index]} == "-" ]; then
			unset ARR_TO_CLEAN[$index]
		fi
	done

	echo ${ARR_TO_CLEAN[@]}
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

	#Q=(${Q2[@]})

	#unset Q2[0]

	#printf '%s' ${#Q2[@]}
	
	if [ ${#Q2[@]} -gt 0 ]; then
		# for pq_idx in ${!Q2[@]}
		# do
		# 	if [ $pq_idx == 0 ]; then
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
		# 	fi
		# done
	fi

	for at_idx in ${!AT[@]}
	do
		if [[ "${ADDED[$at_idx]}" == 0 && ${AT[$at_idx]} == $TIME_SLICE ]]; then
			Q+=(${P[$at_idx]})
			ADDED[$at_idx]=1
			NUT[$at_idx]=$((${NUT[$at_idx]}-1))

		elif [[ "${ADDED[$at_idx]}" == 0 && ${AT[$at_idx]} != $TIME_SLICE ]]; then
			#printf '{%s}' ${AT[$at_idx]}
			#Q+=("-")
			printf '%s'
		fi
	done

	Q2=(${Q[@]})

	#printf '%s' ${Q[@]}
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
				#unset Q2[$q_idx]

				# if [ ${NUT[$p_idx]} -gt 0 ]; then
				# 	Q2+=(${P[$p_idx]})
				# 	#NUT[$p_idx]=$((${NUT[$p_idx]}-1))
				# fi

				# else

				# printf '\t%s' '-'
			fi
	
		done
	done
	#printf '\t%s' ${NUT[@]}

	printf '%s\n'
	let TIME_SLICE++
done