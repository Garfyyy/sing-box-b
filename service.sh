#!/bin/bash

# Detect the operating system and perform actions accordingly

if [ -f /etc/alpine-release ]; then
    echo "Detected Alpine Linux system."
    # Alpine: Create OpenRC service script
    cat << 'EOF' > /etc/init.d/sing-box
#!/sbin/openrc-run

description="Sing-box Service"

command="/root/sing-box/sing-box"
command_args="run -c /root/sing-box/config.json -C /root/sing-box/conf"

directory="/root/sing-box"

supervisor="supervise-daemon"
EOF

    # Make the OpenRC service script executable
    chmod +x /etc/init.d/sing-box

    echo -e "\nsing-box service created. Run the following command to add and start the service:"
    echo "sudo rc-update add sing-box default && sudo rc-service sing-box start"
    echo -e "\nTo remove the service, run:"
    echo "sudo rc-service sing-box stop && sudo rc-update del sing-box && sudo rm /etc/init.d/sing-box"

elif [ -f /etc/debian_version ]; then
    echo "Detected Debian/Ubuntu system."
    # Debian/Ubuntu: Create systemd service file
    cat << 'EOF' > /etc/systemd/system/sing-box.service
[Unit]
Description=Sing-box Service
After=network.target

[Service]
WorkingDirectory=/root/sing-box
ExecStart=/root/sing-box/sing-box run -c /root/sing-box/config.json -C /root/sing-box/conf
Restart=on-failure
RestartSec=5
RestartPreventExitStatus=23

[Install]
WantedBy=multi-user.target
EOF

    echo -e "\nsing-box.service created. Run the following command to start:"
    echo "sudo systemctl daemon-reload"
    echo "sudo systemctl enable --now sing-box"
    echo -e "\nTo remove the service, run the following commands:"
    echo "sudo systemctl disable --now sing-box"
    echo "sudo rm /etc/systemd/system/sing-box.service"

else
    echo "Unsupported system. This script supports Alpine Linux and Debian/Ubuntu systems only."
fi
