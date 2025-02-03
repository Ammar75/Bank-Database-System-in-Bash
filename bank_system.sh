#!/bin/bash
Data_file="bank_db.txt"

generate_random_id() {
    newid=$(( RANDOM ))
    while grep -q "${newid}" ${Data_file};
    do
        newid=$(( RANDOM ))
    done
    echo $newid

}


Remove_customer()
{
    id=$(zenity --entry --title="Show Balance" --text="Enter your ID" --entry-text "ID")
    # check if ID is valid
    if grep -q "${id}" ${Data_file};
    then
        #remove customer
        sed -i "/${id}/d" $Data_file
        zenity --info --text="customer removed successfully"
    else
        zenity --error --text="Invalid ID"
    fi
}




add_customer() {
    name=$(zenity --entry --title="Add new user" --text="Enter your name" --entry-text "Your Name")
    # Check if name already exists in the database
    if grep -q "${name}" ${Data_file}; 
    then
        zenity --error --text="Customer with this name already exists!"
        return
    fi
    
    id=$(generate_random_id)
    balance=0
    
    if [[ -n ${name} && -n ${id} && -n ${balance} ]]; 
    then
        echo "${name} ${id} ${balance}" >> ${Data_file}
        zenity --info --text="     Welcome \nUser name: ${name} \nUser id: ${id} \nBalance: 0 "
    else
        zenity --error --text="All fields are required"
    fi    
}

show_balance()
{
    # Ask for the user's ID
    id=$(zenity --entry --title="Show Balance" --text="Enter your ID" --entry-text "ID")

    # Check if the ID is non-empty
    if [[ -n "${id}" ]]; 
    then
        # Search for the ID in the database file and extract the balance using awk
        
        balance=$(awk -F' ' -v id="$id" '$2 == id {print $3}' ${Data_file})

        # Check if balance is non-empty (ID was found)
        if [[ -n "${balance}" ]]; 
        then
            zenity --info --text="Balance: ${balance}"
        else
            zenity --error --text="Customer with ID ${id} not found!"
        fi
    else
        zenity --error --text="ID is required!"
    fi
}



while true; 
    do
    choice=$(zenity --list --title="Bank System" --column="Options" "Create a New Account" "Access My Account" "Exit")
    # old and new customers list
    
    case $choice in
        "Create a New Account")  add_customer;;
    
        "Access My Account")
    
            # old_customers list
            choice2=$(zenity --list --title="Bank System" --column="Options" "Show Balance" "Deposit" "Withdraw" "Remove Customer" "Exit")
                case $choice2 in
                    "Show Balance") show_balance ;;
                    "Deposit") ;;
                    "Withdraw") ;;
                    "Remove Customer") Remove_customer ;;
                    "Exit") return ;;
                    *) zenity --error --title="Error" --text="Invalid choice!" ;;
                esac ;;

        "Exit") exit 0 ;;
        *) zenity --error --title="Error" --text="Invalid choice!" ;;
    esac
done




