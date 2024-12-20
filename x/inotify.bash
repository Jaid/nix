inotifywait --event create,delete,delete_self,move,move_self,unmount,close_write,modify --monitor --recursive --no-dereference --format "%T %e %w%f" --timefmt '%d.%m.%Y %H:%M:%S' /home/jaid | grep -v -E "/home/jaid/.config/Code/|/home/jaid/.config/thorium/|/home/jaid/.cache/" | while read -r line; do
  echo "$line"
done
