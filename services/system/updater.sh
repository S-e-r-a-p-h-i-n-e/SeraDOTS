fastfetch

echo -e "\n--- Starting System Update (Pacman) ---"
sudo pacman -Syyu

echo -e "\n--- Starting Flatpak Updates ---"
flatpak update -y

echo -e "\n--- All updates complete! ---"