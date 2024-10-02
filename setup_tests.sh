#!/bin/bash
echo Roku IP:
read ip

echo Roku Password:
read password

export ROKU_IP="$ip"
export ROKU_PASSWORD="$password"
# Export variables to make them available in the current shell
echo "export ROKU_IP=\"$ip\"" >> ~/.bashrc
echo "export ROKU_PASSWORD=\"$password\"" >> ~/.bashrc

# Source the updated .bashrc file to apply changes immediately
source ~/.bashrc

# Inform the user that the variables have been exported
echo "ROKU_IP and ROKU_PASSWORD have been exported and are now available in your terminal."
echo "You may need to restart your terminal or run 'source ~/.bashrc' in other open sessions for the changes to take effect."


