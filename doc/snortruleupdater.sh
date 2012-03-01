#!/bin/sh

# Snort Rule Updater
# Written By: Chris Sanders (chris@chrissanders.org)
# Last Modified: 4/13/2011
# This script is used for automatically updating snort rule files across multiple sensors
# This is the list of snort sensors. New sensors can be added here as delimited by spaces
# Sensors Names:
# sensor1 sensor2 sensor3 sensor 4 sensor 5
# Sensor IPs:
sensors="192.168.1.1 192.168.1.2 192.168.1.3 192.168.1.4 192.168.1.5"
# This is the default path to the rule file on the remote sensors
rulepath=/etc/snort/rules
# This is the name of the rule file you wish to update
customrules=custom.rules
# This is the user account used to perform the update
user=snortuser
echo "################################################################################################"
echo "This script will update the $customrules Snort rule file on the following sensors:"
echo "$sensors"
echo " "
echo "Successful execution requires the following: "
echo " - The new rules file must be located in the directory this script was executed from"
echo " - The new rules file must be named $customrules"
echo " - The sensors must be online"
echo " "
echo "Do you wish to continue execution (y/n)?"
echo "################################################################################################"
# Check for user confirmation of script execution
read reply
if [ "$reply" != "y" ]; then
    exit 0
fi
# Check to ensure a new rule file exists in the current working directory
if [ ! -f $customrules ]; then
    echo "### Error!"    
    echo "### In order to use this script a file named $customrules must exist in the directory the script was executed from!"
    exit 0
fi
# Core functionality of the script. Iterates through sensor list in a loop
for ip in $sensors
    do
      echo "## Connecting to $ip"
      if ssh -t -q $user@$ip "exit"
      then
      # SSH into the sensor and create a backup of the current rule file
      echo "## Creating a backup of current rule file..."
      ssh -t -q $user@$ip "sudo cp $rulepath/$customrules $rulepath/$customrules.bak ;exit"
      # Copy the new rule file to the sensor, overwriting the current file
      echo -n "## Transferring new rules file to sensor..."
      scp -q $customrules $user@$ip:$rulepath
      echo ""
      # Create a log file showing the addition to the rules file on the sensor
      echo "## Creating log file of rule changes"
      ssh -t -q $user@$ip "sudo diff $rulepath/$customrules $rulepath/$customrules.bak > \
      /var/log/snortrules/snort.rule.update.$(date +%m%d%y.%H%M%S) ;exit"
      # Restart snort so rule will take effect
      echo "## Restarting Snort"
      ssh -t -q $user@$ip "sudo /etc/init.d/snortd restart ;exit"
      echo "## Rule update completed on $ip"
      echo ""
    fi
    done
echo "################################################################################################"
echo "Snort rule update process completed. Check the output above for any errors."
echo "################################################################################################"
