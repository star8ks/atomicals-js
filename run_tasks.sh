#!/bin/bash

process_count=${1:-1}
tick=${2:-quark}
max_gas=${3:-91}
echo "process count: $process_count"
echo "tick: $tick"

# read -p "Enter Y to continue: " input
# if [[ $input == "Y" || $input == "y" ]]; then
#     echo "Continuing..."
# else
#     echo "Bye."
#     exit
# fi

while true; do
    # get fees from mempool API
    halfHourFee=$(echo $(curl -s https://mempool.space/api/v1/fees/recommended) | jq '.halfHourFee')
    echo "halfHourFee: $halfHourFee"

    if [[ -z "$halfHourFee" || ! "$halfHourFee" =~ ^[0-9]+$ ]]; then
	    echo "use default gas"
        gas=$max_gas
    elif [ $((halfHourFee + 2)) -gt $max_gas ]; then
	    echo "gas too high, use default gas"
        gas=$max_gas
    else
        gas=$((halfHourFee + 2))
    fi
    echo "set gas: $gas"

    name=$(echo "$tick-$(date +'%m-%d-%H:%M')")
    
    pm2 start "yarn cli mint-dft $tick --disablechalk --satsbyte=$gas" -i $process_count --name $name

    sleep 900

    pm2 delete $name 
done