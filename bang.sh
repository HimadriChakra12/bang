sudo timedatectl set-timezone Asia/Dhaka
echo "Pick One of those 1. Packages | 2. Firefox | 3. .dots | 0. All"
read -p "Lets Do it: " option

case "$option" in
0)
    bash package.sh
    bash firefox.sh
    bash dots.sh
    ;;
1)
    bash package.sh
    ;;
2)
    bash firefox.sh
    ;;
3)
    bash dots.sh
    ;;
*)
    echo "Invalid choice"
    exit 0
    ;;
esac

swaybg -i $HOME/bang/Standing.png -m fill &
