# Bank-Database-System-in-Bash

Project Overview

This is a simple Bank System implemented in a bash script. It simulates a basic banking system where users can create an account, check their balance, deposit money, withdraw money, and remove their account. The system stores the bank data in a text file, allowing the script to perform basic operations like reading and modifying the account details.
Features

  Create a New Account: A new customer can create an account with a unique ID and an initial balance.
  Show Balance: Customers can check their current balance using their unique account ID.
  Deposit: Customers can deposit money into their account.
  Withdraw: Customers can withdraw money from their account.
  Remove Customer: Customers can remove their account from the system.
  Unique ID Generation: A random ID is generated for each customer, ensuring uniqueness.

Prerequisites

Before running the script, ensure that you have the following dependencies:

  zenity: A tool for creating GUI dialogs from the command line. It is used in this script to prompt users for inputs and display messages.

  To install zenity, run the following command:

  sudo apt-get install zenity

  bash: The script is written in bash, which is the default shell on most Linux distributions.

Script Breakdown
1. Generate Random ID

    This function generates a random ID for a new customer by using the built-in $(( RANDOM )) command.
    It ensures that the generated ID is unique by checking if it already exists in the bank_db.txt file.

2. Add Customer

    This function allows the creation of a new account for a customer.
    It prompts the user to enter their name and generates a unique random ID for them.
    The initial balance is set to 0.
    The function checks if the name already exists in the database to avoid duplicates.

3. Show Balance

    This function allows customers to view their current account balance.
    The user is prompted to enter their account ID, and the function checks the database for the corresponding balance.
    If the ID is valid, the balance is displayed. Otherwise, an error message is shown.

4. Deposit

    This function allows customers to deposit money into their account.
    The user enters their ID and the deposit amount, and the function updates the balance in the bank_db.txt file.
    The new balance is displayed after the deposit.

5. Withdraw

    This function allows customers to withdraw money from their account.
    The user enters their ID and the withdrawal amount.
    The function checks if the balance is sufficient for the withdrawal. If yes, it updates the balance and displays the new amount. If not, an error message is shown for insufficient funds.

6. Remove Customer

    This function allows customers to remove their account from the system.
    The user enters their account ID, and if it exists in the database, the account is removed from the bank_db.txt file.
    A success message is displayed if the account is removed, and an error message is shown if the ID is invalid.

How to Use the Script

  Run the script by executing it from the terminal:
  ./bank_system.sh

  Follow the on-screen prompts:
        Create a New Account: Enter your name to create an account. A random ID will be generated, and your initial balance will be set to 0.
        Access My Account: Enter your ID to access your account. You can view your balance, deposit, withdraw, or remove your account.
        Exit: Exit the program.

Known Issues
  Ensure the bank_db.txt file exists and has the correct format (name id balance).
