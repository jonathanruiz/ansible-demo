#!/bin/bash

echo "Running apt update"
sudo apt update -y

echo "Running apt upgrade"
sudo apt update -y

echo "Installing nginx"
sudo apt-get install ansible -y