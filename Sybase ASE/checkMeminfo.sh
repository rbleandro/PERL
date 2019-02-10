while true; do
 for i in $(grep ^Huge /proc/meminfo | head -3 | awk '{print $2}'); do
  echo -n "$i "
 done
 echo ""
 sleep 5
done
