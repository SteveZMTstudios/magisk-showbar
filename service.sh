MODDIR=${0%/*}
sleep 120
if [[ "`getprop init.svc.bootanim`" = "running" ]]; then
echo > $MODDIR/disable

echo "$(date '+%g-%m-%d %H:%M:%S') E detect: module bootlooped. Disable at next reboot. " > $MODDIR/status.log
exit
fi



