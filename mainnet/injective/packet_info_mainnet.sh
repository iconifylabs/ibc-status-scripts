#!/bin/bash

CHAIN="injective"
COLOR_GREEN='\e[32m'
COLOR_YELLOW='\e[33m'
COLOR_RED='\e[31m'
COLOR_RESET='\e[0m'

while getopts ":h-:" opt; do
    case $opt in
        -)
            case "${OPTARG}" in
                chain)
                    CHAIN="${!OPTIND}"
                    OPTIND=$((OPTIND + 1))
                    ;;
                help)
                    echo "Usage: $0 [--chain <chain_name>] [--help]"
                    exit 0
                    ;;
                *)
                    echo "Invalid option: --$OPTARG" >&2
                    exit 1
                    ;;
            esac
            ;;
        h)
            echo "Usage: $0 [--chain <chain_name>] [--help]"
            exit 0
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
    esac
done



# icon config
ICON_IBC=cx622bbab73698f37dbef53955fd3decffeb0b0c16
ICON_PORT_ID=xcall
WASM_PORT_ID=xcall
ICON_NODE=https://ctz.solidwallet.io/api/v3/
ICON_CPT=$PWD/.iconSn
WASM_CPT=$PWD/.wasmSn


if [ "$CHAIN" == "archway" ]; then
    WASM_IBC=archway1rujqm6c555jv4zaa6q0x0fcc7mk4ca4zgyg9gt3xhzzw0933g63qk4v0zl
    WASM_CHANNEL=channel-0
    ICON_CHANNEL=channel-0
    WASM_NODE=https://rpc.mainnet.archway.io:443
    WASM_NETWORK_ID=archway-1
    WASM_BIN=archwayd
elif [ "$CHAIN" == "injective" ]; then
    WASM_IBC=inj14980ljp04rfcw67lzk0whmjwyt67xt2m3smk8q
    WASM_CHANNEL=channel-0
    ICON_CHANNEL=channel-2
    WASM_NODE=https://sentry.tm.injective.network:443 
    WASM_NETWORK_ID=injective-1
    WASM_BIN=injectived
else
    echo "Unknown chain: $chain"
    exit 1
fi

function hex2dec() {
    hex=${@#0x}
    echo "obase=10; ibase=16; ${hex^^}" | bc
}

icon_seq_num=$(goloop rpc call --uri $ICON_NODE \
        --to $ICON_IBC \
        --method getNextSequenceSend \
        --param portId=${ICON_PORT_ID} \
        --param channelId=${ICON_CHANNEL})

isn=$(hex2dec $icon_seq_num)
echo $isn


args="{\"get_next_sequence_send\":{\"channel_id\":\"${WASM_CHANNEL}\",\"port_id\":\"${WASM_PORT_ID}\"}}"
wsn=$(${WASM_BIN} query wasm contract-state smart ${WASM_IBC} $args --node ${WASM_NODE} --chain-id ${WASM_NETWORK_ID} --output json | jq -r .data)
echo $wsn

# exit 0
function getPacketReceiptWasm() {
	local args="{\"has_packet_receipt\":{\"port_id\":\"${WASM_PORT_ID}\",\"channel_id\":\"${WASM_CHANNEL}\",\"sequence\":${1}}}"
	local op=$(${WASM_BIN} query wasm contract-state smart ${WASM_IBC} $args --node ${WASM_NODE} --chain-id ${WASM_NETWORK_ID} --output json | jq -r .data)
	if [[ $op == "true" ]]; then
		echo -e "$1: ${COLOR_GREEN}$op${COLOR_RESET}" 
	else
		echo -e "$1: ${COLOR_RED}$op${COLOR_RESET}" 
	fi
}

function getPacketReceiptIcon() {
	local op=$(goloop rpc call --uri $ICON_NODE \
	        --to $ICON_IBC \
	        --method getPacketReceipt \
	        --param portId=${ICON_PORT_ID} \
	        --param channelId=${ICON_CHANNEL} \
	        --param sequence=$1 | tr -d [:blank:])
	if [[ $op == "\"0x1"\" ]]; then 
		echo -e "$1: ${COLOR_GREEN}true${COLOR_RESET}"
	else
		echo -e "$1: ${COLOR_RED}false${COLOR_RESET}"
	fi
}

function getAllPacketCommitmentsWasm() {
	local n=$1

    local c=$(cat $ICON_CPT)
    echo Checkpointed upto $c
    s=$(($c-5))
    if [ $s -lt 1 ]; then
        s=1
    fi

	for (( c=s; c<$n; c++ ))
	do 
	   getPacketReceiptWasm $c
	done
}

function getAllPacketCommitmentsIcon() {
	local n=$1
    local c=$(cat $WASM_CPT)
    echo Checkpointed upto $c
    s=$(($c-5))
    if [ $s -lt 1 ]; then
        s=1
    fi
	for (( c=s; c<$n; c++ ))
	do 
	   getPacketReceiptIcon $c
	done
}

echo "Next sn of packet send icon: $isn"
echo "Check if packets were received on injective"
getAllPacketCommitmentsWasm $isn
if [ -n "$isn" ]; then
    echo $isn > $ICON_CPT
fi
echo 
echo
echo "Next sn of packet send wasm: $wsn"
echo "Check if packets were received on lisbon"
getAllPacketCommitmentsIcon $wsn
if [ -n "$wsn" ]; then
    echo $wsn > $WASM_CPT
fi