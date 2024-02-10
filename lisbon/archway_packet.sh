#!/bin/bash


archwayd tx wasm execute archway1h04c8eqr99dnsw6wqx80juj2vtuxth70eh65cf6pnj4zan6ms4jqshc5wk \
	"{\"send_call_message\":{\"to\":\"0x2.icon/hx48080d70475f6456dc80cd3a0d21e3bd1624dc20\",\"data\":[104,101,108,108,111,105,99,111,110,33,33]}}" \
	--gas auto \
	--gas-prices 900000000000aconst \
	--gas-adjustment 1.5 \
	--amount 1000000000000000000aconst \
	--from main \
	--node https://rpc.constantine.archway.tech:443 \
	--chain-id constantine-3 \
	--output json -y