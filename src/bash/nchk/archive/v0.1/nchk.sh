#!/bin/bash

nmap -sP 10.1.1.0/24 > out.1.txt
nmap -sP 10.1.11.0/24 > out.11.txt
nmap -sP 10.1.0.0/24 > out.0.txt
nmap -sP 10.1.254.0/24 > out.254.txt
