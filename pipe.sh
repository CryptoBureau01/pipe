# !/bin/bash

curl -s https://raw.githubusercontent.com/CryptoBureau01/logo/main/logo.sh | bash
sleep 5

# Function to print info messages
print_info() {
    echo -e "\e[32m[INFO] $1\e[0m"
}

# Function to print error messages
print_error() {
    echo -e "\e[31m[ERROR] $1\e[0m"
}



#Function to check system type and root privileges
master_fun() {
    echo "Checking system requirements..."

    # Check if the system is Ubuntu
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        if [ "$ID" != "ubuntu" ]; then
            echo "This script is designed for Ubuntu. Exiting."
            exit 1
        fi
    else
        echo "Cannot detect operating system. Exiting."
        exit 1
    fi

    # Check if the user is root
    if [ "$EUID" -ne 0 ]; then
        echo "You are not running as root. Please enter root password to proceed."
        sudo -k  # Force the user to enter password
        if sudo true; then
            echo "Switched to root user."
        else
            echo "Failed to gain root privileges. Exiting."
            exit 1
        fi
    else
        echo "You are running as root."
    fi

    echo "System check passed. Proceeding to package installation..."
}


# Function to install dependencies
install_dependency() {
    print_info "<=========== Install Dependency ==============>"
    
    # Updating and upgrading system packages
    print_info "Updating and upgrading system packages, and installing curl..."
    sudo apt update && sudo apt upgrade -y && sudo apt install git wget curl -y 
    sleep 1

    # Allow port 8003 in firewall
    print_info "Allowing port 8003 in UFW..."
    sudo ufw allow 8003
    sudo ufw allow 8003/tcp
    sleep 1

    # Allow port 443 in firewall (for HTTPS traffic)
    print_info "Allowing port 443 in UFW..."
    sudo ufw allow 443
    sudo ufw allow 443/tcp
    sleep 1

    # Allow port 80 in firewall (for HTTP traffic)
    print_info "Allowing port 80 in UFW..."
    sudo ufw allow 80
    sudo ufw allow 80/tcp
    sleep 1

    # Reload UFW to apply changes
    print_info "Reloading UFW to apply firewall changes..."
    sudo ufw reload
    sleep 1

    # Check UFW status to confirm changes
    print_info "Checking UFW status..."
    sudo ufw status
    sleep 1

    # Call the master function to proceed further
    master
}


setup_pipe() {
    local PIPE_FOLDER="pipe"

    # Check if the folder already exists
    if [ -d "$PIPE_FOLDER" ]; then
        echo "Folder '$PIPE_FOLDER' already exists. Exiting..."
        return
    fi

    # Create the 'pipe' folder
    mkdir "$PIPE_FOLDER"
    echo "Folder '$PIPE_FOLDER' created successfully."

    # Change directory to 'pipe'
    cd "$PIPE_FOLDER" || exit

    # Download the compiled pop binary
    curl -L -o pop "https://dl.pipecdn.app/v0.2.5/pop"

    # Assign executable permission to pop binary
    chmod +x pop

    # Create folder to be used for download cache
    mkdir download_cache

    echo "Pipe network setup completed successfully!"

    # Call the uni_menu function to display the menu
    master
}


# Function to configure and run Pipe Network node
pipe_data() {
    print_info "<=========== Configuring Pipe Network Node ==============>"

    # User se Solana public key input lene ka prompt
    read -p "Enter your Solana Public Key: " pubKey
    sleep 1

    # Ensure pop binary exists
    if [ ! -f "./pipe/pop" ]; then
        print_info "Error: pop binary not found! Make sure you have downloaded it."
        exit 1
    fi

    # Saving Pipe Network node configuration
    print_info "Saving Pipe Network node configuration..."
    echo "./pop \\
  --ram 4 \\               # 4GB RAM allocate karega
  --max-disk 150 \\        # Max 150GB disk space use karega
  --cache-dir ./pipe/download_cache \\     # Cache pipe folder mein store hoga
  --pubKey $pubKey         # User ka Solana public key" > ./pipe/pop_config.sh
    sleep 1

    # Pop node start karna
    print_info "Starting Pipe Network node..."
    cd pipe && ./pop --ram 4 --max-disk 150 --cache-dir ./download_cache --pubKey "$pubKey"
    sleep 1

    print_info "Pipe Network node setup complete!"

    # Call the uni_menu function to display the menu
    master
}


# Function to check Pipe Network node status
pipe_status() {
    print_info "<=========== Checking Pipe Network Node Status ==============>"

    # Pop status command run karna
    print_info "Fetching node status..."
    ./pop --status

    print_info "Status check complete!"

    # Call the uni_menu function to display the menu
    master
}


# Function to check Pipe Network node points
pipe_points() {
    print_info "<=========== Checking Pipe Network Node Points ==============>"

    # Pop points command run karna
    print_info "Fetching node points (Note: Points are not active yet)..."
    ./pop --points

    print_info "Points check complete!"

    # Call the uni_menu function to display the menu
    master
}



# Function to display menu and prompt user for input
master() {
    print_info "==============================="
    print_info "    Pipe Node Tool Menu      "
    print_info "==============================="
    print_info ""
    print_info "1. Install-Dependency"
    print_info "2. Setup-Pipe"
    print_info "3. Pipe-Pop-Data"
    print_info "4. Pipe-Status"
    print_info "5. Pipe-Points"
    print_info "6. Exit"
    print_info ""
    print_info "==============================="
    print_info " Created By : CB-Master "
    print_info "==============================="
    print_info ""
    
    read -p "Enter your choice (1 or 6): " user_choice

    case $user_choice in
        1)
            install_dependency
            ;;
        2)
            setup_pipe
            ;;
        3) 
            pipe_data
            ;;
        4)
            pipe_status
            ;;
        5)
            pipe_points
            ;;
        6)
            exit 0  # Exit the script after breaking the loop
            ;;
        *)
            print_error "Invalid choice. Please enter 1 or 6 : "
            ;;
    esac
}

# Call the uni_menu function to display the menu
master_fun
master
