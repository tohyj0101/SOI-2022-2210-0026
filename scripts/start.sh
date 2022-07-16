#!/bin/bash
#
# Start analysis

function startVM() {
	vboxmanage startvm "cuckoo1" --type headless
}

function startCuckoo() {
	cuckoo
}

echo -e "\033[41;30m------------------------------\033[0m"
echo -e "\033[41;30m Start VM (cuckoo1) \033[0m"
echo -e "\033[41;30m------------------------------\033[0m"
startVM

echo -e "\033[41;30m------------------------------\033[0m"
echo -e "\033[41;30m Start Cuckoo \033[0m"
echo -e "\033[41;30m------------------------------\033[0m"
startCuckoo
