#!/bin/bash


archway_function() {
    echo "Sending packet to  Archway"
    goloop rpc sendtx call \
        --uri https://lisbon.net.solidwallet.io/api/v3 \
        --to cx15a339fa60bd86225050b22ea8cd4a9d7cd8bb83 \
        --nid 2 \
        --method sendCallMessage \
        --step_limit 50_000_000 \
        --value 1000000000000000000 \
        --param _to=archway/archway12pr4qremzdpwdqwn4py0dtqtm9qtnz364eldr6 \
        --param _data=7061636b65745f66726f6d5f69636f6e \
        --key_store ./godWallet.json \
        --key_password gochain
}

neutron_function() {
    echo "Sending packet to neutron"
    goloop rpc sendtx call \
        --uri https://lisbon.net.solidwallet.io/api/v3 \
        --to cx15a339fa60bd86225050b22ea8cd4a9d7cd8bb83 \
        --nid 2 \
        --method sendCallMessage \
        --step_limit 50_000_000 \
        --value 1000000000000000000 \
        --param _to=neutron/neutron12pr4qremzdpwdqwn4py0dtqtm9qtnz364eldr6 \
        --param _data=7061636b65745f66726f6d5f69636f6e \
        --key_store ./godWallet.json \
        --key_password gochain
}

injective_function() {
    echo "Sending packet to injective"
    goloop rpc sendtx call \
        --uri https://lisbon.net.solidwallet.io/api/v3 \
        --to cx15a339fa60bd86225050b22ea8cd4a9d7cd8bb83 \
        --nid 2 \
        --method sendCallMessage \
        --step_limit 50_000_000 \
        --value 1000000000000000000 \
        --param _to=injective/inj1k5nwz0ctk98k7zwn95jjy2klhfpgufklnt0sgq \
        --param _data=7061636b65745f66726f6d5f69636f6e \
        --key_store ./godWallet.json \
        --key_password gochain
}

# Check for the command-line argument
if [ $# -ne 1 ]; then
    echo "Usage: $0 <option>"
    exit 1
fi

# Determine which function to call based on the provided option
case "$1" in
    --archway)
        archway_function
        ;;
    --neutron)
        neutron_function
        ;;
    --injective)
        injective_function
        ;;
    *)
        echo "Invalid option: $1"
        echo "Usage: $0 <option>"
        exit 1
        ;;
esac

