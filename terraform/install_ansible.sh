#!/bin/bash

echo "Running apt update"
sudo apt update -y

echo "Running apt upgrade"
sudo apt update -y

echo "Installing nginx"
sudo apt install ansible -y

echo "Installing sshpass"
sudo apt install sshpass -y