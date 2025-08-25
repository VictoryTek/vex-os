#!/usr/bin/env bash

# Set hostname for Vex
echo "Setting hostname to vex"
hostnamectl set-hostname vex || echo "vex" > /etc/hostname
