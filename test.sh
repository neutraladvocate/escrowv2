#! /bin/bash
# 7 errors currently
truffle compile -all
output=$(nc -z localhost 8545; echo $?)
[ $output -eq "0" ] && trpc_running=true
if [ ! $trpc_running ]; then
  echo "Starting our own testrpc node instance"
  testrpc > /dev/null &
  trpc_pid=$!
fi
# ./node_modules/truffle/build/cli.bundled.js test
truffle test
if [ ! $trpc_running ]; then
  kill -9 $trpc_pid
fi
