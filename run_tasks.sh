#!/bin/bash

process_count=${1:-1}
tick=${2:-neutron}
max_gas=${3:-150}
echo "process count: $process_count"
echo "tick: $tick"

while true; do
    # get fees from mempool API
    halfHourFee=$(echo $(curl -s https://mempool.space/api/v1/fees/recommended) | jq '.halfHourFee')
    echo "halfHourFee: $halfHourFee"

    if [[ -z "$halfHourFee" || ! "$halfHourFee" =~ ^[0-9]+$ ]]; then
	echo "use default gas"
        gas=$max_gas
    elif [ "$halfHourFee" -gt $max_gas ]; then
	echo "gas too high, use default gas"
        gas=$max_gas
    else
        gas=$halfHourFee
    fi
    echo "curretn gas: $gas"

    name=$(echo "$tick-$(date +'%y-%m-%d-%H:%M')")
    
    pm2 start "yarn cli mint-dft $tick --disablechalk --satsbyte=$gas" -i $process_count --name $name

    sleep 600

    pm2 delete $name 
done