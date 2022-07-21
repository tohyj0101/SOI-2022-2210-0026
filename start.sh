#!/bin/bash
#
# Start Cuckoo siandbox analysis

function startVM() {
	# Power on "cuckoo1" virtual machine
	vboxmanage startvm "cuckoo1" --type headless
}

function startCuckoo() {
	# Start Cuckoo 
	cuckoo
}

echo -e "\033[41;30m----------------------------------\033[0m"
echo -e "\033[41;30m Power on cuckoo1 virtual machine \033[0m"
echo -e "\033[41;30m----------------------------------\033[0m"
startVM

echo -e "\033[41;30m--------------\033[0m"
echo -e "\033[41;30m Start Cuckoo \033[0m"
echo -e "\033[41;30m--------------\033[0m"
startCuckoo

