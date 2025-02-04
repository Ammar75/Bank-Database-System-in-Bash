#!/bin/bash
#Global variables
Current_Customer_ID=""	#Global variable to store the current customer using it
main_database_file="bank_db.txt" #main database file
customers_files_dir="customers/" #customers files directory
#====================================================================================================================================================#
#Function name: update_balance
#Input: $1:Customer name, $2:Customer ID, $3: Customer current balance
#Output: NONE
#Description: One line function to update balance of specific customer, called only by deposit and withdraw functions
update_balance()
{
	sed -i "/^$1 $2 /s/[0-9]\+$/$3/" ${main_database_file}
}
#====================================================================================================================================================#
#Function name: generate_random_id
#Input: NONE
#Output: unique ID
#Description: This function is used to generate new ID for the new customer.
#	      It assures that the assigned new ID to the user is not assigned to another previous user
generate_random_id() 
{
    newid=$(( RANDOM ))
    while grep -q "${newid}" ${main_database_file};
    do
        newid=$((RANDOM))
    done
    echo $newid
}
#====================================================================================================================================================#
#Function name: remove_account
#Input: NONE
#Output: NONE
#Description: This function is used to delete customer's account if required by the customer
remove_account()
{
	zenity --question --text="Are you sure you want to remove your account?" --width=250 --height=100	#ask if the customer is sure to remove his account
	if [[ $? -eq 0 ]]; #if the customer said yes
    	then 
    		customer_file=${customers_files_dir}${Current_Customer_ID}.txt	#customer file
    		sed -i "/${Current_Customer_ID}/d" ${main_database_file}	#remove customer
    		rm ${customer_file}	#remove customer file
    		zenity --info --text="Customer removed successfully" --width=250 --height=100
		return 0
	else #the customer said no
		return 1
    	fi
}
#====================================================================================================================================================#
#Function name: add_customer
#Input: NONE
#Output: $?: return status
#Description: This function is used to add new customer to the system's database
add_customer() 
{
	while true;
	do
		new_customer_input=$(zenity --forms --title="Welcome!" --text="Please fill the following information" --add-entry="First name"\
    				--add-entry="Last name" --add-entry="Email" --add-password="PIN" --add-password="Re-enter PIN" --add-calendar="Birthdate" --separator=",")
		if [[ $? -eq 1 ]]; #if form box canceled
    		then 
			return -1
    		fi	
		old_IFS=${IFS}
    		IFS=,	# make the Internal Field Separator is ','
    		read FirstName LastName Email PIN PIN2 Birthdate <<< ${new_customer_input}
    		IFS=${old_IFS} 
		if [[ -n ${FirstName} && -n ${LastName} && -n ${Email} && -n ${PIN} && -n ${PIN2} && -n ${Birthdate} ]];  #check all entries are not empty
   		then
   			PINLength=${#PIN}	#get PIN number length
   			if [[ ${PINLength} -lt 8 ]];	#check if PIN number is less than 8 digits
   			then
   				zenity --error --text="PIN number must not be less than 8 digits" --width=250 --height=100
   				continue
   			fi
   			if [[ ${PIN} == ${PIN2} ]];
   			then	#Successfully added new customer
   				id=$(generate_random_id)	#generate new id for the customer
   				balance=0
   				echo "${FirstName} ${id} ${balance}" >> ${main_database_file}	#add customer to the main database
   				new_customer_file=${customers_files_dir}${id}.txt	#customer file
   				echo "${FirstName},${LastName},${Email},${Birthdate}" > ${new_customer_file} #add customer info to its file
   				PIN_Hash=$(openssl dgst -sha512 <<< ${PIN} | awk '{print $2}') #create hash digest for the PIN using SHA512 and store the hash in the variable
   				echo ${PIN_Hash} >> ${new_customer_file}	#add customer PIN hash to its file
   				zenity --info --text="Welcome ${FirstName} to our Bank, your ID number: <b>${id}</b>\nPlease write it down" --width=250 --height=100
   				return 0
   			else
   				zenity --error --text="Entered PIN numbers are different" --width=250 --height=100
   				continue
   			fi
   		else
   			zenity --error --text="All fields are required" --width=250 --height=100
   			continue
   		fi
	done 
}
#====================================================================================================================================================#
#Function name: show_balance
#Input: NONE
#Output: NONE
#Description: This function is used to show account balance to the customer
show_balance()
{
 	balance=$(awk -F' ' -v id="${Current_Customer_ID}" '$2 == id {print $3}' ${main_database_file})
	zenity --info --text="Balance: ${balance}" --width=250 --height=100
}
#====================================================================================================================================================#
#Function name: deposit
#Input: NONE
#Output: NONE
#Description: This function is used to deposit for customers, it calls "update_balance" function internally
deposit()
{
	amount=$(zenity --entry --title="Deposit" --text="Please, enter deposit amount" --width=250 --height=100)	# Ask for the deposit amount
	if [[ $? -eq 1 ]]; #if entry box canceled
	then 
		return 	#return
	fi
	current_balance=$(awk "/${Current_Customer_ID}/ {print \$3}" ${main_database_file})	#(awk "/regex/ {action: (print $3) , $3: third column}" input_file) 
	customer_name=$(awk "/${Current_Customer_ID}/ {print \$1}" ${main_database_file})	#fetch/parse customer name
	new_balance=$((current_balance+amount))	#calculate the new balance
	update_balance ${customer_name} ${Current_Customer_ID} ${new_balance} #call update_balance function passing the required variables
	customer_file=${customers_files_dir}${Current_Customer_ID}.txt	#customer file
	timestamp=$(date "+%Y-%m-%d %H:%M:%S")
	receipt="DEPOSIT: +${amount} - $(date "+%Y-%m-%d %H:%M:%S")"
	echo ${receipt} >> ${customer_file} #insert the transaction recepit into the customer file
	zenity --info --text="Transcation is successful" --width=250 --height=100 #show info message by "Zenity" that transcation is successful
}
#====================================================================================================================================================#
#Function name: withdraw
#Input: NONE
#Output: NONE
#Description: This function is used to withdraw for customers, it calls "update_balance" function internally
withdraw()
{
while true;
do
	amount=$(zenity --entry --title="Withdraw" --text="Please, enter withdraw amount" --width=250 --height=100)	# Ask for the deposit amount
	if [[ $? -eq 1 ]]; #if entry box canceled
	then 
		break 	#break and return
	fi
	customer_name=$(awk "/${Current_Customer_ID}/ {print \$1}" ${main_database_file})	#fetch/parse customer name
	current_balance=$(awk "/${Current_Customer_ID}/ {print \$3}" ${main_database_file})	#fetch/parse current balance	#(awk "/regex/ {action: (print $3) , $3: third column}" input_file) 
	if (( amount > current_balance )); 
	then
		zenity --error --text="Insufficient Balance" --width=250 --height=100	#show info message by "Zenity" that balance is insufficient
	else
		new_balance=$((current_balance-amount))	#calculate the new balance
		update_balance ${customer_name} ${Current_Customer_ID} ${new_balance} #call update_balance function passing the required variables
		customer_file=${customers_files_dir}${Current_Customer_ID}.txt	#customer file
		timestamp=$(date "+%Y-%m-%d %H:%M:%S")
		receipt="WITHDRAW: -${amount} - $(date "+%Y-%m-%d %H:%M:%S")"
		echo ${receipt} >> ${customer_file} #insert the transaction recepit into the customer file
		zenity --info --text="Transcation is successful" --width=250 --height=100 #show info message by "Zenity" that transcation is successful
		break
	fi	
done
}
#====================================================================================================================================================#
#Function name: authenticate
#Input: NONE
#Output: NONE
#Description: This function is used to authenticate customer that wants to access the bank services
authenticate()
{
while true;	#authentication loop
do
	customer_login_input=$(zenity --forms --title="Customer Login" --text="Please, enter your ID and PIN number" --add-entry="ID" --add-password="PIN" --separator="," --width=300 --height=150)
	if [[ $? -eq 1 ]]; #if form box canceled
	then 
		return 1
	fi
	old_IFS=${IFS}
    	IFS=,	# make the Internal Field Separator is ','
    	read ID PIN <<< ${customer_login_input}
    	IFS=${old_IFS}
    	if [[ -n ${ID} && -n ${PIN} ]];  #check all entries are not empty
    	then
    		customer_file=${customers_files_dir}${ID}.txt
    		if [[ -e ${customer_file} ]];	#check if file exists
    		then
    			PIN_Hash=$(awk 'NR==2' ${customer_file}) #get the second line inside the file, which is the PIN Hash
    			Entered_PIN_Hash=$(openssl dgst -sha512 <<< ${PIN} | awk '{print $2}') #create hash digest for the Entered PIN using SHA512 and store the hash in the variable
    			if [[ ${PIN_Hash} == ${Entered_PIN_Hash} ]]; #the entered password is correct
    			then
    				zenity --info --text="Access Granted" --width=250 --height=100
    				Current_Customer_ID=${ID}	#store the authenticated ID in the current customer ID variable
    				return 0	#authentication succesful
    			else
    				zenity --error --text="Wrong PIN number" --width=250 --height=100
    			fi    			
    		else
    			zenity --error --text="Customer with ID ${ID} is not found!" --width=250 --height=100
    		fi
    	else
    		zenity --error --text="All fields are required" --width=250 --height=100 #show info message by "Zenity" that all field required
    	fi
 done
	#return 0
}
#====================================================================================================================================================#
#====================================================================================================================================================#
while true; 
    do
    choice=$(zenity --list --title="Bank System" --column="Options" "Create a New Account" "Access My Account" "Exit" --width=200 --height=300)	# existing and new customers list
    case $choice in	#first case statement
        "Create a New Account")  
        	add_customer
        	continue ;;	#end of the "Create a New Account" case
        "Access My Account")
            authenticate	#authenticate customer	
            if [[ $? -ne 0 ]];	#if last function executed did not return 0
            then
            	continue; #continue again inside the inner while loop
            fi	
            while true; #while loop for the second menu
            do
            	choice2=$(zenity --list --title="Bank System" --column="Options" "Show Balance" "Deposit" "Withdraw" "Remove Account" "Exit" --width=200 --height=400) 
                	case $choice2 in #second case statement
                    	"Show Balance") show_balance ;;
                    	"Deposit") deposit ;;
                    	"Withdraw") withdraw ;;
                    	"Remove Account") 
                    		remove_account	#remove this customer from the database
                    		if [[ $? -eq 0 ]]; #if the customer said yes
    				then 
					Current_Customer_ID=""	#exit the customer options menu and get back to the first menu
					break  #break from the inner loop
				else #the customer said no
					continue	#continue in the menu
    				fi ;;
                    	"Exit")
                    		Current_Customer_ID=""	#exit the customer options menu and get back to the first menu 
                    		break ;; #break from the inner loop
                    	*) zenity --error --title="Error" --text="Invalid choice!" --width=250 --height=100 ;; 
                esac #end of the "Access My Account" case and second case statement
	done ;;
        "Exit") exit 0 ;;	#"Exit" case
        *) zenity --error --title="Error" --text="Invalid choice!" --width=250 --height=100 ;; #any other choice
    esac #end of first case statement
done
