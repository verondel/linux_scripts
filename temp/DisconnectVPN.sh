#!/bin/bash
# Находим процессы OpenVPN, использующие данный конфигурационный файл
VPN_CONFIG="/home/a1/profile-1970934955222476292.ovpn"

while true; do
    VPN_PIDS=$(pgrep -f "openvpn --config $VPN_CONFIG")
    if [ -z "$VPN_PIDS" ]; then
        echo "Процессы VPN не найдены"
        break
    else
        for PID in $VPN_PIDS; do
            echo "Останавливаем VPN с PID $PID..."
            sudo kill "$PID"
        done
        echo "Все найденные VPN процессы были остановлены"
    fi
    sleep 5
done
