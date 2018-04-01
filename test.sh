#! /bin/bash

output=$(nc -z localhost 8545; echo $?)
[ $output -eq "0" ] && trpc_running=true
if [ ! $trpc_running ]; then
  echo "Starting our own testrpc node instance"
  testrpc > /dev/null &
  trpc_pid=$!
fi
/home/sohel/.nvm/versions/node/v8.9.4/lib/node_modules/truffle/build/cli.bundled.js test
if [ ! $trpc_running ]; then
  kill -9 $trpc_pid
fi
