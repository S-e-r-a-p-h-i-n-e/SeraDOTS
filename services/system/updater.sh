fastfetch
echo -e "\n--- Starting System Update---"
if  {command -v topgrade > /dev/null 2>&1;}; then
    topgrade --no-confirm
else
    echo "Topgrade not found. Please install it to use this updater script."
fi