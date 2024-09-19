.data 
filename: .asciiz "MedicalTest.txt"
data: .space 1024
menu: .asciiz "\nPlease choose an option: \n1.Add new medical test \n2.Search for a test (by patient ID) \n3.Searching for abnormal tests \n4.Average test value \n5.Update an existing test result \n6.Delete a test \n7.Exit \n"
ID_menu:    .asciiz "Menu:\nA) Retrieve all patient tests\nB) Retrieve all abnormal patient tests\nC) Retrieve all patient tests in a specific period\nEnter your choice (A/B/C): "
choice: .asciiz "\nPlease enter your choice:\n "
invalid: .asciiz "\nInvalid choice\n"
userInput: .space 32
prompt_patientID: .asciiz "\nPlease enter the patient ID (7 digits): "
patientIDstr: .space 8   # 7 digits + null terminator
error_msg_month: .asciiz "The month should start with 0 or 1 only.\n"
prompt_testName: .asciiz "\nPlease enter the test name (3 capital letters): "
testNamestr: .space 4    # 3 letters + null terminator
prompt_testDate: .asciiz "\nPlease enter the test date (YYYY-MM): "
testDatestr: .space 8    # 'YYYY-MM' + null terminator
prompt_testResult: .asciiz "Please enter the test result (e.g., 12.35): "
resultstr: .space 6      # Floating point, 5 characters including '.' + null terminator
result2str: .space 6 
outputBuffer: .space 50 # Buffer for the entire output string
bufferlength : .word 0
invalid_id_message: .asciiz "\nInvalid patient ID. Please enter a valid 7-digit ID.\n"
invalid_testName_message: .asciiz "\nInvalid test name. Please enter 3 capital letters (e.g., ABC).\n"
invalid_testDate_message: .asciiz "\nInvalid test date. Please enter a valid date in the format YYYY-MM.\n"
invalid_testResult_message: .asciiz "\nInvalid test result. Please enter a valid numeric value with one decimal point (e.g., 12.3).\n"
no_match_message: .asciiz "No matching ID found.\n"
current_line:   .space 1024           # Temporary storage for current line
match_found:    .word 0               # Flag to indicate if a match was found
id_to_compare_with: .space 8          # Space to store user-entered ID
result: .float 
result2: .float 0.0
delimiter: .asciiz ","  # Delimiter for printing test info
delimiter2: .asciiz ":"  # Delimiter for printing test info
buffer: .space 100 #buffer for storing each test
newline: .asciiz "\n" 
eqstr: .asciiz  "strings are equal "
noteqstr: .asciiz  "strings are not equal "
normal: .asciiz "Normal\n"
notnormal: .asciiz "notNormal\n"
str1: .asciiz "HGP"
str2: .asciiz "BGT"
str3: .asciiz "LDL"
str4: .asciiz "BPT"
minRes1: .float 13.8
maxRes1: .float 17.2
resADD:         .space 7             # Buffer to store the extracted result, size 7 bytes
minRes2: .float 70
maxRes2: .float 99
maxRes3: .float 100
maxRes4: .float 120
maxRes5: .float 80
blodNot: .asciiz"Diastolic Blood Pressure notNormal\n"
patientIDch2:   .space 8              # 7 bytes for 7-digit patient ID + 1 for null terminator
testnamech2:    .space 20             # Space for test name
resultch2:      .space 20             # Space for test result
testDatech2: .space 20    # Allocate space for the test date
float_num:      .float 0.0            # Storage for the floating-point result
match_count:    .float 0              # Counter for the number of matches
UserTestName:   .space 21
match_message:  .asciiz "\nNumber of matching names found: "
float_add: .float 0.0
average_result: .float 0.0  # To store the average result
normalDiastolic: .asciiz "Diastolic Blood Pressure is Normal\n"
normalsys:.asciiz "Systolic Blood Pressure is Normal\n"
strNotDiastolic: .asciiz"Diastolic Blood Pressure NOT Normal\n"  
strNot:.asciiz "Systolic Blood Pressure is Not Normal\n"
menu2: .asciiz "\nMenu:\n1.Systolic Blood Pressure \n2.Diastolic Blood Pressure \nChoose an option: "
choice1: .asciiz "\nYou chose option 1.\n"
choice2: .asciiz "\nYou chose option 2.\n"
sumstr: .asciiz "\nsum= "
AVGstr: .asciiz "\nAverage= "
line_number: .word 1          # Line number counter, starting from 1
colon: .asciiz ":"
prompt_line_number: .asciiz "Enter the line number to delete: "
error_msg: .asciiz "Error: Line number out of range\n"
prompt_new_result: .asciiz "Enter the new 5-digit content: "
new_result: .space 6         # Buffer for new content, 5 digits + null terminator
empty_string: .asciiz ""
correctFileName: .asciiz "MedicalTest.txt"
error_msgfile: .asciiz "This is not the correct file name.\n"
prompt_line_numberupdate: .asciiz "Enter the line number to update: "
new_resultupdate: .space 6         # Buffer for new content, 5 digits + null terminator
menu_promptupdate: .asciiz "Select an option to update:\n1. Update Diastolic Blood Pressure\n2. Update Systolic Blood Pressure\nEnter choice: "
prompt_new_resultupdate: .asciiz "Enter the new 5-digit content: "
no_match_messagedate: .asciiz "No matching date found.\n"
.text 
.globl begin
begin:
    la $a0, filename   # Load address of the current filename into $a0
    la $a1, correctFileName   # Load address of the correct filename into $a1

    # Call string_compare function
    jal string_compare
    beq $v0, 1, proceed       # If return is 1, names match, proceed
    li $v0, 4
    la $a0, error_msgfile
    syscall                   # Print error message
    j exit                    # Exit the program

proceed:
    li $v0, 4 
    la $a0, menu 
    syscall

    li $v0, 4 
    la $a0, choice 
    syscall 

    li $v0, 5 
    syscall 
    move $t0, $v0

    beq $t0, 1, addTest
    beq $t0, 2, searchByID
    beq $t0, 3, Choice_3 
    beq $t0, 4, avg 
    beq $t0, 5, update 
    beq $t0, 6, delete 
    beq $t0, 7, exit 
    j anotherchoice  

anotherchoice:
    li $v0, 4
    la $a0, invalid
    syscall
    j begin 

addTest:
    li $t4, 1  # Initialize the valid input flag to true (1 means invalid, needs loop)

    # Input loop for patient ID
    patient_id_input_loop:
        li $v0, 4
        la $a0, prompt_patientID
        syscall

        li $v0, 8
        la $a0, patientIDstr
        li $a1, 8
        syscall

        la $a0, patientIDstr
        li $a1, 7
        jal check_all_numbers
        beqz $v0, invalid_patientID

        # ID is valid, proceed
        li $t4, 0  # Set valid flag to false (0 means valid)
        j input_testName

    invalid_patientID:
        li $v0, 4
        la $a0, invalid_id_message
        syscall
        j patient_id_input_loop  # Jump back to the input loop

    test_name_input_loop:
    li $t5, 1  # Initialize the valid input flag to true (1 means invalid)

    # Input loop for test name
    input_testName:
        li $v0, 4
        la $a0, prompt_testName
        syscall

        li $v0, 8
        la $a0, testNamestr
        li $a1, 4
        syscall
        
        la $a0 , testNamestr
        la $a1 , str1
        jal string_compare 
        beq $v0 , 1 ,input_testDate
     
        la $a0 , testNamestr
        la $a1 , str2
        jal string_compare 
        beq $v0 , 1 ,input_testDate
        
        la $a0 , testNamestr
        la $a1 , str3
        jal string_compare 
        beq $v0 , 1 ,input_testDate
        
        la $a0 , testNamestr
        la $a1 , str4
        jal string_compare 
        beq $v0 , 1 , CheckkBPT
        beqz $v0, invalid_testName  
       
     CheckkBPT:
        # Test name is valid, proceed
        li $t5, 0  # Set valid flag to false (0 means valid)
        j check_test_name_BPT

    invalid_testName:
        li $v0, 4
        la $a0, invalid_testName_message
        syscall
        j input_testName  # Jump back to the input loop
        
    check_test_name_BPT:
        # Check if the test name is "BPT"
        la $a0, testNamestr
        la $a1, str4  # Pointer to the string "BPT"
        jal string_compare
        beqz $v0, not_BPT  # If not "BPT", proceed as normal
    
    input_testDateBPT:
        li $v0, 4
        la $a0, prompt_testDate
        syscall
        li $v0, 8
        la $a0, testDatestr
        li $a1, 8  # Buffer to include 'YYYY-MM' + null terminator
        syscall
        jal print_newline

        # Validate test date
        la $a0, testDatestr
        jal validate_test_date
        beqz $v0, invalid_testDate

 # Input two results for "BPT"
input_results:
    li $v0, 4
    la $a0, prompt_testResult
    syscall
    li $v0, 8
    la $a0, resultstr
    li $a1, 6  # Buffer for the first result
    syscall
      # Call validation function
    la $a0, resultstr
    jal validate_resultres             # Validates and handles incorrect inputs

    jal print_newline

    li $v0, 4
    la $a0, prompt_testResult  # Re-use prompt for second result
    syscall
    li $v0, 8
    la $a0, result2str
    li $a1, 6  # Buffer for the second result
    syscall
      # Call validation function
    la $a0, result2str
    jal validate_resultres              # Validates and handles incorrect inputs

    jal print_newline

  # Format output for "BPT" test
    # Assume 'outputBuffer' has enough space
    la $a0, outputBuffer
    la $a1, patientIDstr
    li $a2, 7
    jal strcopy

    la $a0, outputBuffer + 7
    la $a1, delimiter2  # ":"
    li $a2, 1
    jal strcopy

    la $a0, outputBuffer + 8
    la $a1, testNamestr  # "BPT"
    li $a2, 3
    jal strcopy

    la $a0, outputBuffer + 11
    la $a1, delimiter  # ","
    li $a2, 1
    jal strcopy

    la $a0, outputBuffer + 12
    la $a1, testDatestr
    li $a2, 7
    jal strcopy

    la $a0, outputBuffer + 19
    la $a1, delimiter
    li $a2, 1
    jal strcopy

    la $a0, outputBuffer + 20
    la $a1, resultstr
    li $a2, 5
    jal strcopy

    la $a0, outputBuffer + 25
    la $a1, delimiter
    li $a2, 1
    jal strcopy

    la $a0, outputBuffer + 26
    la $a1, result2str
    li $a2, 5
    jal strcopy

    la $a0, outputBuffer + 31
    la $a1, newline
    li $a2, 1
    jal strcopy

    # Determine the length of the output buffer
    la $a0, outputBuffer
    jal count_characters
    move $s1, $v0 # Move the counted length to $s1
    # Open the file "inputfile.txt" for writing
    li $v0, 13
    la $a0, filename
    li $a1, 9       # Open for writing (write mode)
    li $a2, 0       # File mode: default permissions
    syscall
    move $s0, $v0   # Save file descriptor
 
    # Write the contents of the buffer into the file
    li $v0, 15
    move $a0, $s0   # File descriptor
    la $a1, outputBuffer  # Buffer address
    move $a2, $s1      # Buffer size
    syscall
 
    # Close the file
    li $v0, 16
    move $a0, $s0   # File descriptor
    syscall
    
    j begin
###### done BPT
   
   not_BPT: 
    test_date_input_loop:
    li $t6, 1  # Initialize the valid input flag to true (1 means invalid)

    # Input loop for test date
    input_testDate:
        li $v0, 4
        la $a0, prompt_testDate
        syscall

        li $v0, 8
        la $a0, testDatestr
        li $a1, 8  # Buffer to include 'YYYY-MM' + null terminator
        syscall
        jal print_newline

        la $a0, testDatestr
        jal validate_test_date
        beqz $v0, invalid_testDate  # If zero, test date is invalid

        # Test date is valid, proceed
        li $t6, 0  # Set valid flag to false (0 means valid)
        j proceed_with_test_input  # Jump to continue with additional test input or processing

    invalid_testDate:
        li $v0, 4
        la $a0, invalid_testDate_message
        syscall
        j input_testDate  # Jump back to the input loop

    proceed_with_test_input:
       li $v0, 4
       la $a0, prompt_testResult
       syscall
       li $v0, 8
       la $a0, resultstr
       li $a1, 6  # Buffer for the result including null terminator
       syscall
         # Call validation function
    la $a0, resultstr
    jal validate_resultres              # Validates and handles incorrect inputs

       jal print_newline

    # Copy patient ID to the output buffer
la $a0, outputBuffer
la $a1, patientIDstr
li $a2, 7              # Length of patientID
jal strcopy

# Insert colon directly after patient ID
la $a0, outputBuffer + 7
la $a1, delimiter2     # delimiter2 is ":"
li $a2, 1              # Length of ":"
jal strcopy

# Copy test name directly after the colon
la $a0, outputBuffer + 8
la $a1, testNamestr
li $a2, 3              # Length of testName
jal strcopy

# Insert comma directly after test name
la $a0, outputBuffer + 11
la $a1, delimiter      # delimiter is ","
li $a2, 1              # Length of ","
jal strcopy

# Copy test date directly after the comma
la $a0, outputBuffer + 12
la $a1, testDatestr
li $a2, 7              # Length of testDate 'YYYY-MM'
jal strcopy

# Insert comma directly after test date
la $a0, outputBuffer + 19
la $a1, delimiter      # ","
li $a2, 1              # Length of ","
jal strcopy

# Copy test result directly after the final comma
la $a0, outputBuffer + 20
la $a1, resultstr
li $a2, 10             # Length of result (including potential whitespace or decimals)
jal strcopy

# Add newline at the end of the buffer for clarity when written to a file or output
la $a0, outputBuffer + 30  # Adjust the index appropriately
la $a1, newline
li $a2, 1
jal strcopy

# Determine the length of the output buffer
la $a0, outputBuffer  # Start of the outputBuffer
jal count_characters
move $s1, $v0         # Move the counted length to $s1
  
      # Open the file "inputfile.txt" for writing
    li $v0, 13
    la $a0, filename
    li $a1, 9       # Open for writing (write mode)
    li $a2, 0       # File mode: default permissions
    syscall
    move $s0, $v0   # Save file descriptor
    li $v0, 15
    move $a0, $s0             # File descriptor
    la $a1, newline           # Address of newline character buffer
    li $a2, 1                 # Size of newline character
    syscall
    # Write the contents of the buffer into the file
    li $v0, 15
    move $a0, $s0   # File descriptor
    la $a1, outputBuffer  # Buffer address
    move $a2, $s1      # Buffer size
    syscall

    # Close the file
    li $v0, 16
    move $a0, $s0   # File descriptor
    syscall
    
    j begin
    
###################### Done Choice1 ####################################################
 
searchByID:
	# Display menu prompt
    li $v0, 4                       # syscall for printing string
    la $a0, ID_menu
    syscall
    
     
     # Read user choice
    li $v0, 8                       # syscall for reading string
    la $a0, choice                  # buffer to store the user's choice
    li $a1, 2                       # maximum number of bytes to read (including null terminator)
    syscall
    
    # Process user choice
    lb $t0, choice                  # load the first character of the choice
    li $t1, 'A'                     # ASCII value for 'A'
    li $t2, 'B'                     # ASCII value for 'B'
    li $t3, 'C'                     # ASCII value for 'C'	
    
    beq $t0, $t1, retrieve_all_tests
    beq $t0, $t2, retrieve_abnormal_tests
    beq $t0, $t3, retrieve_tests_in_period
    j invalid_choice                # if none of the valid options were chosen		
    			
   retrieve_all_tests:
   li $t4, 1  # Initialize the valid input flag to true (1 means invalid, needs loop)

    # Input loop for patient ID
    patient_id_input_loop2:
        li $v0, 4
        la $a0, prompt_patientID
        syscall

        li $v0, 8
        la $a0, id_to_compare_with
        li $a1, 8
        syscall
        jal print_newline 

        la $a0, id_to_compare_with
        li $a1, 7
        jal check_all_numbers
        beqz $v0, invalid_patientID2

        # ID is valid, proceed
        li $t4, 0  # Set valid flag to false (0 means valid)
        j  readdd

    invalid_patientID2:
        li $v0, 4
        la $a0, invalid_id_message
        syscall
        j patient_id_input_loop2  # Jump back to the input loop

  readdd:
    
     jal read_file
   
     # Process data to find matches
    la $a0, data
    jal extract_compare_and_print
    

    # Check if a match was found and print message if none were found
    lw $t0, match_found
   
    beqz $t0, print_no_match
    
    j begin 

   
retrieve_abnormal_tests:
       
        li $t4, 1  # Initialize the valid input flag to true (1 means invalid, needs loop)

    # Input loop for patient ID
    patient_id_input_loop3:
        li $v0, 4
        la $a0, prompt_patientID
        syscall

        li $v0, 8
        la $a0, id_to_compare_with
        li $a1, 8
        syscall

        la $a0, id_to_compare_with
        li $a1, 7
        jal check_all_numbers
        beqz $v0, invalid_patientID3

        # ID is valid, proceed
        li $t4, 0  # Set valid flag to false (0 means valid)
        j  readdd2

    invalid_patientID3:
        li $v0, 4
        la $a0, invalid_id_message
        syscall
        j patient_id_input_loop3  # Jump back to the input loop

  readdd2:
    
    # Print the newline after the input
    li $v0, 4
    la $a0, newline
    syscall
    
    # Call read_file function to read all data from the file into the buffer
    jal read_file
    
    # Process data to find matches
    la $a0, data
    jal extract_compare_and_print1

    # Check if a match was found and print message if none were found
    lw $t0, match_found
    beqz $t0, print_no_match

    j begin 


 			
retrieve_tests_in_period:
       
        li $t4, 1  # Initialize the valid input flag to true (1 means invalid, needs loop)

    # Input loop for patient ID
    patient_id_input_loop4:
        li $v0, 4
        la $a0, prompt_patientID
        syscall

        li $v0, 8
        la $a0, id_to_compare_with
        li $a1, 8
        syscall

        la $a0, id_to_compare_with
        li $a1, 7
        jal check_all_numbers
        beqz $v0, invalid_patientID4

        # ID is valid, proceed
        li $t4, 0  # Set valid flag to false (0 means valid)
        j  readdd4

    invalid_patientID4:
        li $v0, 4
        la $a0, invalid_id_message
        syscall
        j patient_id_input_loop3  # Jump back to the input loop

  readdd4:
    
    jal print_newline
input_testDatech2:    
   
test_date_input_loop2:
    li $t6, 1  # Initialize the valid input flag to true (1 means invalid)

    # Input loop for test date
    input_testDate2:
        li $v0, 4
        la $a0, prompt_testDate
        syscall

        li $v0, 8
        la $a0, testDatestr
        li $a1, 8  # Buffer to include 'YYYY-MM' + null terminator
        syscall
        jal print_newline

        la $a0, testDatestr
        jal validate_test_date
        beqz $v0, invalid_testDate2  # If zero, test date is invalid

        # Test date is valid, proceed
        li $t6, 0  # Set valid flag to false (0 means valid)
        j complete  # Jump to continue with additional test input or processing

    invalid_testDate2:
        li $v0, 4
        la $a0, invalid_testDate_message
        syscall
        j input_testDate2  # Jump back to the input loop

complete:
    jal read_file
    
    # Process data to find matches
    la $a0, data
    jal extract_compare_and_print3
    
    j begin 																			
    invalid_choice:							
    j begin
    															
###################### Done ID ####################################################																																																																					
Choice_3:
    
  # Initialize match count
  li $s4, 0                          # $s4 used for match count
  sw $s4, match_count                # Initialize match count in memory
  # Input loop for test name
    input_testName3:
           li $v0, 4
        la $a0, prompt_testName
        syscall

        li $v0, 8
        la $a0, UserTestName
        li $a1, 4
        syscall
        
        la $a0 , UserTestName
        la $a1 , str1
        jal string_compare 
        beq $v0 , 1 , ContComp
     
        la $a0 , UserTestName
        la $a1 , str2
        jal string_compare 
        beq $v0 , 1 , ContComp
        
        la $a0 , UserTestName
        la $a1 , str3
        jal string_compare 
        beq $v0 , 1 , ContComp
        
        la $a0 , UserTestName
        la $a1 , str4
        jal string_compare 
        beq $v0 , 1 ,  handle_bpt
        beqz $v0, invalid_testName3  
     
    invalid_testName3:
        li $v0, 4
        la $a0, invalid_testName_message
        syscall
        j input_testName3  # Jump back to the input loop
          
    ContComp:

   jal read_file
        # Process data to find matches and convert results
        la $a0, data
        jal extract_compare_and_printCH3
      
        
        # Print newline
        li $v0, 4
        la $a0, newline
        syscall
        
	
        # Load match count and check if a match was found
        lw $s4, match_count
        li $v0, 4
        la $a0, match_message
        syscall
        li $v0, 1
        move $a0, $s4
        syscall

        # Print newline
        li $v0, 4
        la $a0, newline
        syscall
        j begin 

handle_bpt: 

   jal read_file 

        # Process data to find matches and convert results
         la $a0, data
        jal extract_compare_and_printch3_bpt2
        la $a0, data
        jal extract_compare_and_printch3_bpt
        
        # Print newline
        li $v0, 4
        la $a0, newline
        syscall
        
        # Load match count and check if a match was found
        lw $s4, match_count
        li $v0, 4
        la $a0, match_message
        syscall
        li $v0, 1
        move $a0, $s4
        syscall

        # Print newline
        li $v0, 4
        la $a0, newline
        syscall

    
    j begin 
###################### Done Normal ####################################################
avg:
    # Initialize match count
  li $s4, 0                          # $s4 used for match count
  sw $s4, match_count                # Initialize match count in memory
li $t5, 1  # Initialize the valid input flag to true (1 means invalid)

    # Input loop for test name
    input_testName4:
          li $v0, 4
        la $a0, prompt_testName
        syscall

        li $v0, 8
        la $a0, UserTestName
        li $a1, 4
        syscall
        
        la $a0 , UserTestName
        la $a1 , str1
        jal string_compare 
        beq $v0 , 1 , contAVG
     
        la $a0 , UserTestName
        la $a1 , str2
        jal string_compare 
        beq $v0 , 1 , contAVG
        
        la $a0 , UserTestName
        la $a1 , str3
        jal string_compare 
        beq $v0 , 1 , contAVG
        
        la $a0 , UserTestName
        la $a1 , str4
        jal string_compare 
        beq $v0 , 1 ,  handle_bptResult
        beqz $v0, invalid_testName4  
     
    invalid_testName4:
        li $v0, 4
        la $a0, invalid_testName_message
        syscall
        j input_testName4  # Jump back to the input loop
      
    contAVG:
    jal read_file 
        # Process data to find matches and convert results
        la $a0, data
        jal extract_compare_and_printCH4

        # Load match count and check if a match was found
        lw $s4, match_count
        li $v0, 4
        la $a0, match_message
        syscall
        li $v0, 1
        move $a0, $s4
        syscall

        # Print newline
        li $v0, 4
        la $a0, newline
        syscall
        li $v0, 4
        la $a0, sumstr
        syscall
        lwc1 $f12, float_add
        li $v0, 2
        
        syscall
   
       lw $t1, match_count            # Load match count into $t1
       beqz $t1, exit_program         # If match count is zero, skip division to avoid division by zero

       mtc1 $t1, $f2                  # Move the match count to a floating-point register
       cvt.s.w $f2, $f2               # Convert the integer match count to floating-point

       lwc1 $f1, float_add            # Load the accumulated sum into $f1
       div.s $f12, $f1, $f2           # Divide total sum by match count to get average
       swc1 $f12, average_result      # Store the result in average_result
       jal print_newline
       # Print the average result
       li $v0, 4
       la $a0, AVGstr
       syscall
       li $v0, 2                      # Syscall for printing floating-point number
       syscall
       j begin
     
handle_bptResult:
 # Display menu
        li $v0, 4
        la $a0, menu2
        syscall

        # Read integer input
        li $v0, 5
        syscall

        # Check the input
        move $t0, $v0           # Move the read value to $t0
        li $t1, 1               # Load the integer 1 into $t1
        li $t2, 2               # Load the integer 2 into $t2

        # Compare input and jump to corresponding label
        beq $t0, $t1, option1
        beq $t0, $t2, option2
        j invalid_option

    option1:
        jal read_file 

        # Process data to find matches and convert results
        la $a0, data
        jal extract_compare_and_printCH42

        # Load match count and check if a match was found
        lw $s4, match_count
        li $v0, 4
        la $a0, match_message
        syscall
        li $v0, 1
        move $a0, $s4
        syscall

        jal print_newline 
        li $v0, 4
        la $a0, sumstr
        syscall
        lwc1 $f12, float_add
        li $v0, 2 
        syscall
       
        lw $t1, match_count            # Load match count into $t1
        beqz $t1, exit_program         # If match count is zero, skip division to avoid division by zero

        mtc1 $t1, $f2                  # Move the match count to a floating-point register
        cvt.s.w $f2, $f2               # Convert the integer match count to floating-point

       lwc1 $f1, float_add            # Load the accumulated sum into $f1
       div.s $f12, $f1, $f2           # Divide total sum by match count to get average
       swc1 $f12, average_result      # Store the result in average_result
       jal print_newline
       # Print the average result
       li $v0, 4
       la $a0, AVGstr
       syscall
       li $v0, 2                      # Syscall for printing floating-point number
       syscall
       j begin

    option2:
        jal read_file 

        # Process data to find matches and convert results
        la $a0, data
        jal extract_compare_and_printCH43

        # Load match count and check if a match was found
        lw $s4, match_count
        li $v0, 4
        la $a0, match_message
        syscall
        li $v0, 1
        move $a0, $s4
        syscall
        jal print_newline
        li $v0, 4
        la $a0, sumstr
        syscall
        lwc1 $f12, float_add
        li $v0, 2  
        syscall
       
        lw $t1, match_count            # Load match count into $t1
        beqz $t1, exit_program         # If match count is zero, skip division to avoid division by zero

        mtc1 $t1, $f2                  # Move the match count to a floating-point register
        cvt.s.w $f2, $f2               # Convert the integer match count to floating-point

       lwc1 $f1, float_add            # Load the accumulated sum into $f1
       div.s $f12, $f1, $f2           # Divide total sum by match count to get average
       swc1 $f12, average_result      # Store the result in average_result
       jal print_newline
       # Print the average result
       li $v0, 4
       la $a0, AVGstr
       syscall
       li $v0, 2                      # Syscall for printing floating-point number
       syscall
       j begin 

    invalid_option:
        # Invalid option selected
        li $v0, 4
        la $a0, invalid
        syscall
        j handle_bptResult
   

exit_program:
    li $v0, 10                     # Exit syscall
    syscall

    j begin
###################### Done AVG ####################################################
update:
     jal read_file 
    # Initialize pointers and counters
    la $s0, data               # Pointer to data buffer start
    li $s2, 0                  # Index for storing line in temp buffer

process_lines_loopupdate:
    move $s1, $s0              # Start of the line in the main data buffer

copy_lineupdate:
    lb $t1, 0($s0)             # Load character from buffer
    beq $t1, 0, last_line_checkupdate  # Check for end of buffer
    sb $t1, current_line($s2)  # Store character in current_line buffer
    addi $s2, $s2, 1           # Increment index for current_line
    beq $t1, 10, process_lineupdate # Check for newline character
    addi $s0, $s0, 1           # Move to next character
    j copy_lineupdate

process_lineupdate:
    sb $zero, current_line($s2) # Null-terminate the current line

    print_lineupdate: # Common routine to print the line and increment the line number
    # Print the line number
    lw $t2, line_number
    li $v0, 1
    move $a0, $t2
    syscall

    # Print colon and space
    li $v0, 4
    la $a0, colon
    syscall

    # Print the line content
    li $v0, 4
    la $a0, current_line
    syscall

    jal print_newline

    # Increment line number
    addi $t2, $t2, 1
    sw $t2, line_number

    # Reset for next line
    li $s2, 0
    addi $s0, $s0, 1            # Skip past newline character
    j process_lines_loopupdate

last_line_checkupdate:
    bnez $s2, print_lineupdate        # If $s2 is not zero, there are characters in the buffer to print
    j after_processing_linesupdate    # Jump to post-processing input phase
exitupdate:
    li $v0,4
    la $a0,data
    syscall 
    li $v0, 10
    syscall

read_errorupdate:
    li $v0, 10
    syscall
    
  
after_processing_linesupdate:
    # Prompt the user to enter the line number to update
    li $v0, 4
    la $a0, prompt_line_numberupdate
    syscall

    li $v0, 5
    syscall
    move $s7, $v0  # Store the line number in $s7
  
    # Reinitialize pointers for second pass
    la $s0, data               # Reset pointer to start of data buffer
    li $s2, 0                  # Reset index for storing line
    li $s3, 1                  # Reset line counter
    li $s4, 0                  # Flag to print only selected line

find_line_loopupdate:
    move $s1, $s0  # Store the start of the line

process_line_2update:
    lb $t1, 0($s0)  # Load a byte from the buffer
    beq $t1, 0, check_lineupdate  # If end of buffer, check if it's the line to update
    beq $t1, 10, check_lineupdate  # Newline found, check line
    addi $s0, $s0, 1  # Increment the buffer pointer
    j process_line_2update

check_lineupdate:
    # If it's the line to update or the end of the buffer without a newline
    beq $s3, $s7, update_resultupdate  # Check if it's the line to update
    addi $s3, $s3, 1  # Increment the line counter
    bnez $t1, skip_updateupdate  # If $t1 is not zero (not end of buffer), skip update
    j update_resultupdate  # Update the last line if it's the right line number

skip_updateupdate:
    addi $s0, $s0, 1  # Move past the newline character
    j find_line_loopupdate

update_resultupdate:
    move $t6,$s1
    addi $t6,$t6,9
    
    lb $t5,0($t6)
     
    li $t1, 0x50        # Load the ASCII value of 'P' (0x50) into $t1
    beq $t5, $t1, BPT_Testupdate
 
update_result1update: 
    jal updated_resultupdate          
    addi $s1, $s1, 20  # Move to the start of the result within the line
    la $t4, new_resultupdate  # Start of new content

update_loopupdate:
    lb $t2, 0($t4)  # Load a byte from new content
    beq $t2, 0, finishupdate  # End of new content
    sb $t2, 0($s1)  # Store the byte in the buffer
    addi $s1, $s1, 1
    addi $t4, $t4, 1
    j update_loopupdate


update_diastolicupdate:
    jal updated_resultupdate
   
    addi $s1, $s1, 26  # Move to the start of the result within the line
    la $t4, new_resultupdate  # Start of new content
update_diastolic_loopupdate:
    lb $t2, 0($t4)  # Load a byte from new content
    beq $t2, 0, finishupdate  # End of new content
    sb $t2, 0($s1)  # Store the byte in the buffer
    addi $s1, $s1, 1
    addi $t4, $t4, 1
    j update_diastolic_loopupdate


BPT_Testupdate:
    # Display menu and handle user input here
    li $v0, 4
    la $a0, menu_promptupdate           # Load address of the menu prompt
    syscall

    li $v0, 5                     # Read integer for user choice
    syscall
    move $s6, $v0                 # Store user's choice in $s6
    
    li $t2, 1
    beq $s6, $t2, update_result1update
    
    li $t3, 2
    beq $s6, $t3, update_diastolicupdate
    

updated_resultupdate:
  
    # New: Prompt the user for new content
    li $v0, 4
    la $a0, prompt_new_resultupdate
    syscall

    # New: Read the new content as a string
    li $v0, 8
    la $a0, new_resultupdate 
    li $a1, 6  # Limit input to 5 characters + null terminator
    syscall 
    
    jr $ra
finishupdate:
    # Optionally print the entire data buffer to verify updates
    li $v0, 4
    la $a0, data
    syscall

    
    la $a0, data  # Start of the outputBuffer
    jal count_characters
    move $s1, $v0    
    # Open the file "inputfile.txt" for writing
    li $v0, 13
    la $a0, filename
    li $a1, 1       # Open for writing (write mode)
    li $a2, 0       # File mode: default permissions
    syscall
    move $s0, $v0   # Save file descriptor

    # Write the contents of the buffer into the file
    li $v0, 15
    move $a0, $s0   # File descriptor
    la $a1, data  # Bu1300500:RBC,2024-03,1
    move $a2,$s1      # Buffer size
    syscall

    # Close the file
    li $v0, 16
    move $a0, $s0   # File descriptor
    syscall
    j begin
###################### Done Update ####################################################
delete:
    jal read_file 
    
    # Open the file "inputfile.txt" for writing
    li $v0, 13
    la $a0, filename
    li $a1, 1      # Open for writing (write mode)
    li $a2, 0       # File mode: default permissions
    syscall
    move $s0, $v0   # Save file descriptor

    # Write the contents of the buffer into the file
    li $v0, 15
    move $a0, $s0   # File descriptor
    la $a1, empty_string # Buffer address
    li $a2, 0     # Buffer size
    syscall

    # Close the file
    li $v0, 16
    move $a0, $s0   # File descriptor
    syscall
    
    # Initialize pointers and counters
    la $s0, data               # Pointer to data buffer start
    li $s2, 0                  # Index for storing line in temp buffer

process_lines_loopCH6:
    move $s1, $s0              # Start of the line in the main data buffer

copy_lineCH6:
    lb $t1, 0($s0)             # Load character from buffer
    beq $t1, 0, last_line_checkCH6  # Check for end of buffer
    sb $t1, current_line($s2)  # Store character in current_line buffer
    addi $s2, $s2, 1           # Increment index for current_line
    beq $t1, 10, process_lineCH6  # Check for newline character
    addi $s0, $s0, 1           # Move to next character
    j copy_lineCH6

process_lineCH6:
    sb $zero, current_line($s2) # Null-terminate the current line

    print_lineCH6: # Common routine to print the line and increment the line number
    # Print the line number
    lw $t2, line_number
    li $v0, 1
    move $a0, $t2
    syscall

    # Print colon and space
    li $v0, 4
    la $a0, colon
    syscall
    
    # Print the line content
    li $v0, 4
    la $a0, current_line
    syscall
    jal print_newline 

    # Increment line number
    addi $t2, $t2, 1
    sw $t2, line_number

    # Reset for next line
    li $s2, 0
    addi $s0, $s0, 1            # Skip past newline character
    j process_lines_loopCH6

last_line_checkCH6:
    bnez $s2, print_lineCH6       # If $s2 is not zero, there are characters in the buffer to print
    j after_processing_linesCH6   # Jump to post-processing input phase

read_errorCH6:
    li $v0, 10
    syscall
  
after_processing_linesCH6:
    # Prompt the user to enter the line number to skip
    li $v0, 4
    la $a0, prompt_line_number
    syscall

    li $v0, 5
    syscall
    move $s7, $v0  # Store the line number to skip in $s7

    # Reinitialize pointers for second pass
    la $s0, data               # Reset pointer to start of data buffer
    li $s2, 0                  # Reset index for storing line
    li $s3, 1                  # Reset line counter

find_line_loopCH6:
    move $s1, $s0              # Store the start of the line
    li $s2, 0                  # Reset index for temporary line buffer

copy_line_2CH6:
    lb $t1, 0($s0)             # Load a byte from the buffer
    beq $t1, 0, end_of_dataCH6   # If end of buffer, jump to end_of_data
    beq $t1, 10, check_printCH6   # Newline found, check if we should print
    sb $t1, current_line($s2)  # Store character in current_line buffer
    addi $s2, $s2, 1           # Increment index for current_line
    addi $s0, $s0, 1           # Increment the buffer pointer
    j copy_line_2CH6

check_printCH6:
    # Terminate the current line for printing
    sb $zero, current_line($s2)

    # Check if current line is the one to skip
    bne $s3, $s7, print_line2CH6  # If current line number is not the line to skip, print it

    # Increment line number and continue
    addi $s3, $s3, 1
    addi $s0, $s0, 1           # Move past the newline character
    j find_line_loopCH6

print_line2CH6:
    move $t7,$s0
    la $a0, current_line  # Start of the outputBuffer
    jal count_characters
    move $s1, $v0         # Move the counted length to $s1
    # Open the file "inputfile.txt" for writing
    li $v0, 13
    la $a0, filename
    li $a1, 9       # Open for writing (write mode)
    li $a2, 0       # File mode: default permissions
    syscall
    move $s0, $v0   # Save file descriptor

    # Write the contents of the buffer into the file
    li $v0, 15
    move $a0, $s0   # File descriptor
    la $a1, current_line  # Buffer address
    move $a2, $s1      # Buffer size
    syscall
    
    # Write a newline character after the line content
    li $v0, 15
    move $a0, $s0             # File descriptor
    la $a1, newline           # Address of newline character buffer
    li $a2, 1                 # Size of newline character
    syscall
    # Close the file
    li $v0, 16
    move $a0, $s0   # File descriptor
    syscall

    # Increment line number and reset for next line
    move $s0,$t7
    addi $s3, $s3, 1
    addi $s0, $s0, 1            # Skip past newline character
    j find_line_loopCH6

end_of_dataCH6:
    # Check if the last line should be printed (it has no newline character ending)
    bne $s3, $s7, final_printCH6  # If it's not the line to skip, print it
    j begin                     # Otherwise, exit

final_printCH6:
    la $a0, current_line  # Start of the outputBuffer
    jal count_characters
    move $s1, $v0         # Move the counted length to $s1
    # Open the file "inputfile.txt" for writing
    li $v0, 13
    la $a0, filename
    li $a1, 9       # Open for writing (write mode)
    li $a2, 0       # File mode: default permissions
    syscall
    move $s0, $v0   # Save file descriptor

    # Write the contents of the buffer into the file
    li $v0, 15
    move $a0, $s0   # File descriptor
    la $a1, current_line  # Buffer address
    move $a2, $s1      # Buffer size
    syscall
     # Write a newline character after the line content
    li $v0, 15
    move $a0, $s0   # File descriptor
    la $a1, newline  # Address of newline character
    li $a2, 1        # Size of newline character
    syscall
    
    # Close the file
    li $v0, 16
    move $a0, $s0   # File descriptor
    syscall


    j begin 
###################### Done Delete ####################################################
exit:
    li $v0, 10
    syscall
   
###################### REad from File function ####################################################

read_file:
    # Open the file for reading
    li $v0, 13                      # syscall for open file
    la $a0, filename                    # load address of filename
    li $a1, 0                       # mode for read-only
    syscall
    move $s0, $v0                   # save file descriptor

read_loop:
    li $v0, 14                      # syscall for read from file
    move $a0, $s0                   # file descriptor
    la $a1, data                    # buffer to store data
    li $a2, 100100                  # maximum number of bytes to read
    syscall

    # Check if end of file reached
    beq $v0, 0, end_read_loop       # Exit loop if no data read
    j read_loop

end_read_loop:
    # Close the file
    li $v0, 16                      # syscall for close file
    move $a0, $s0                   # file descriptor
    syscall
    jr $ra                          # Return from the function

# Subroutine to print a newline character
print_newline:
    li $v0, 4
    la $a0, newline
    syscall
    jr $ra   # Return to caller

 ###################### ID validation ####################################################
# Subroutine to check if all characters in a string are numbers
check_all_numbers:
    li $t0, 0          # Counter for digits
    li $t1, 48         # ASCII value for '0'
    li $t2, 57         # ASCII value for '9'
    check_numbers_loop:
        lb $t3, 0($a0)  # Load a byte from the string
        beq $t3, $zero, all_numbers_checked # If null terminator, all characters checked
        blt $t3, $t1, not_all_numbers   # If not a digit, characters are not all numbers
        bgt $t3, $t2, not_all_numbers
        addiu $a0, $a0, 1   # Move to the next character
        b check_numbers_loop # Continue loop
    all_numbers_checked:
        li $v0, 1            # All characters are numbers
        jr $ra

not_all_numbers:
        li $v0, 0            # Not all characters are numbers
        jr $ra
#################### Test Date Validation ####################################################
# Subroutine to validate test date
validate_test_date:
    li $t0, 0  # Initialize counter
    validate_date_loop:
        lb $t1, 0($a0)  # Load a byte from the string
        beq $t1, $zero, check_date_format  # End of string
        beq $t0, 4, check_hyphen  # Position for first hyphen
        blt $t0, 4, check_digit  # Check YYYY part
        blt $t0, 7, check_digit  # Check MM part
        j invalid_date

    check_digit:
        li $t2, '0'
        li $t3, '9'
        blt $t1, $t2, invalid_date  # Less than '0'
        bgt $t1, $t3, invalid_date  # Greater than '9'
        addiu $t0, $t0, 1
        addiu $a0, $a0, 1
        j validate_date_loop

    check_hyphen:
        li $t2, '-'
        bne $t1, $t2, invalid_date  # Not a hyphen
        addiu $t0, $t0, 1
        addiu $a0, $a0, 1
        lb $t1, 0($a0)  # Load the first digit of MM
        li $t2, '0'
        li $t3, '1'
        beq $t1, $t2, increment_for_second_digit  # If it's '0', it's valid, check next digit
        beq $t1, $t3, check_second_digit_month  # If it's '1', check second digit for 10, 11, 12
        j invalid_date  # If neither '0' nor '1', it's invalid

    check_second_digit_month:
        lb $t1, 1($a0)  # Load second digit of MM
        li $t2, '0'
        li $t3, '2'
        blt $t1, $t2, invalid_date  # Less than '0'
        bgt $t1, $t3, invalid_date  # Greater than '2'
        addiu $t0, $t0, 2  # Skip over the next character
        addiu $a0, $a0, 2
        j validate_date_loop

    increment_for_second_digit:
       
        addiu $t0, $t0, 1  # Increment to check next character
        addiu $a0, $a0, 1
        lb $t1, 0($a0)  # Load second digit immediately after incrementing
        li $t2, '0'
        beq $t1, $t2, invalid_date  # If second digit is '0', mark as invalid
        j validate_date_loop

    check_date_format:
        li $t1, 7  # Expect 7 characters: 'YYYY-MM'
        bne $t0, $t1, invalid_date  # Incorrect format length
        lb $t1, 0($a0)  # Check if sixth byte (0-based index 5) is zero
        beq $t1, $zero, check_seventh_byte  # If sixth byte is zero, check seventh byte
        li $v0, 1  # Valid date format
        jr $ra

    check_seventh_byte:
        lb $t1, 1($a0)  # Load seventh byte (0-based index 6)
        beq $t1, $zero, invalid_date  # If seventh byte is also zero, it's invalid
        li $v0, 1  # Otherwise, consider it a valid format
        jr $ra

    invalid_date:
        li $v0, 0  # Invalid date format
        jr $ra
  ###################################result validation ###############################      
     validate_resultres :
    # Expecting: $a0 - address of the result buffer, $a1 - buffer size (6 including null terminator)
    li $t0, 0                       # Counter for characters

validate_loopres:
    lb $t1, 0($a0)                  # Load a byte from the buffer
    beqz $t1, check_lengthres          # If null terminator, check the length
    addiu $t0, $t0, 1               # Increment character counter
    addiu $a0, $a0, 1               # Move to the next character
    j validate_loopres 

check_lengthres:
    li $t2, 5
    bne $t0, $t2, invalid_lengthres     # If the count is not 5, handle invalid input
    jr $ra                          # Return from function if valid

invalid_lengthres :
    # Print an error message and ask for input again
    li $v0, 4
    la $a0, invalid_testResult_message
    syscall

    # Prompt and read new input
    li $v0, 4
    la $a0, prompt_testResult
    syscall
    li $v0, 8
    la $a0, resultstr
    li $a1, 6                        # Including null terminator
    syscall

    # Reset pointer and retry validation
    la $a0, resultstr
    j validate_resultres                # Jump to start of validation

###################### copy strings ####################################################
# Subroutine to copy strings
strcopy:
    # $a0 = destination, $a1 = source, $a2 = count
    copy_loop:
        lb $t0, 0($a1)          # Load a byte from source
        sb $t0, 0($a0)          # Store the byte in destination
        addiu $a0, $a0, 1       # Increment the destination address
        addiu $a1, $a1, 1       # Increment the source address
        addiu $a2, $a2, -1      # Decrement the count
        bnez $a2, copy_loop     # Continue if count != 0
    jr $ra                      # Return to the caller

######################count characters####################################################

# $a0 = address of the string
count_characters:
    li $t0, 0           # Initialize counter in $t0
    count_loop:
        lb $t1, 0($a0)  # Load a byte from the buffer
        beq $t1, $zero, end_count # Exit loop if byte is null terminator
        addiu $t0, $t0, 1        # Increment the counter
        addiu $a0, $a0, 1        # Move to the next character
        j count_loop
    end_count:
    move $v0, $t0       # Move the count to $v0 to return it
    jr $ra              # Return to the caller

print_no_match:	
    jal print_newline 
    li $v0, 4                       # syscall for printing string
    la $a0, no_match_message
    syscall
    j begin 
######################ID choice A ####################################################
# Function to extract patient ID from each line, compare, and set flag if match found
extract_compare_and_print:
    # Save registers on stack
    addi $sp, $sp, -16
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)

    li $s0, 0  # Index in buffer
    la $a0, data # Start of buffer

process_lines_loop:
    # Initialize start of line
    move $s1, $s0
    li $s2, 0  # index for storing line

copy_line:
    lb $t1, data($s0)     # Load character from buffer
    beq $t1, 0, end_of_buffer # Check for end of buffer
    sb $t1, current_line($s2) # Store character in current_line buffer
    addi $s2, $s2, 1      # Increment index for current_line
    beq $t1, 10, check_id # Check for newline character
    addi $s0, $s0, 1      # Move to next character
    j copy_line

check_id:
    # Null-terminate the current line
    sb $zero, current_line($s2)

    # Extract patient ID and compare with given ID
    la $a1, patientIDstr
    la $a0, current_line
    li $t0, 0
extract_id:
    lb $t1, 0($a0)
    beq $t1, 58, done_extracting_id  # Stop at ':' (colon is delimiter)
    sb $t1, patientIDstr($t0)       # Store character in patientIDch2
    addi $t0, $t0, 1
    addi $a0, $a0, 1
    j extract_id

done_extracting_id:
    sb $zero, patientIDstr($t0) # Null-terminate patient ID

    # Compare patient IDs
    la $a1, patientIDstr
    la $a2, id_to_compare_with
    li $v0, 0  # Result of comparison

compare_loop:
    lb $t1, 0($a1)
    lb $t2, 0($a2)
    bne $t1, $t2, id_not_match  # If characters do not match, jump to id_not_match
    beqz $t1, ids_match         # If we reach end of string and all matched, they match
    addi $a1, $a1, 1
    addi $a2, $a2, 1
    j compare_loop

ids_match:
    li $t0, 1
    sw $t0, match_found         # Set match found flag
    li $v0, 4                   # syscall for printing string
    la $a0, current_line        # Load address of current line
    syscall

    # Print newline after the current line
    li $v0, 4
    la $a0, newline
    syscall

id_not_match:
    # Set start of next line
    addi $s0, $s0, 1            # Increment to skip the newline character
    j process_lines_loop

end_of_buffer:
    # Restore registers from stack
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    addi $sp, $sp, 16

    jr $ra  # Return


    # Extract the test name from the current line
extract_test_name:
    la $a0, current_line          # Address of the current line
    li $s2, 0                     # Index for test name

    # Find the colon separator to skip patient ID
    find_colon:
        lb $t0, 0($a0)
        beqz $t0, end_test_name   # Check for null terminator
        addiu $a0, $a0, 1         # Move to the next character
        bne $t0, ':', find_colon

    # Copy characters to testnamech2 until a comma is found
    copy_test_name:
        lb $t0, 0($a0)
        beqz $t0, end_test_name   # Check for null terminator
        beq $t0, ',', end_test_name # Check for comma
        sb $t0, testnamech2($s2)  # Store character
        addiu $s2, $s2, 1
        addiu $a0, $a0, 1
        j copy_test_name

    end_test_name:
        sb $zero, testnamech2($s2) # Null-terminate test name
        jr $ra


# Extract the test result from the current line
extract_test_result:
    la $a0, current_line         # Address of the current line
    li $s3, 0                    # Index for result

    # Initially skip to the first comma (after the test name)
    li $t2, 0                   # Flag to note comma count
skip_to_data:
    lb $t0, 0($a0)
    beqz $t0, end_test_result   # End if null terminator
    beq $t0, ',', process_commas # Process if comma
    addiu $a0, $a0, 1           # Move to next character
    j skip_to_data              # Continue until first comma

process_commas:
    addiu $t2, $t2, 1           # Increment comma count
    addiu $a0, $a0, 1           # Move past the comma
    beq $t2, 2, start_copy_result # If second comma, start copying next
    j skip_to_data              # Otherwise, keep skipping to next comma

# Start copying from here to get the result after the second comma
start_copy_result:
    lb $t0, 0($a0)              # Load the first character of the result

# Copy characters to resultch2 until null terminator is found
copy_result:
    beqz $t0, end_test_result   # Check for null terminator
    sb $t0, resultch2($s3)      # Store character
    addiu $s3, $s3, 1
    addiu $a0, $a0, 1
    lb $t0, 0($a0)              # Load next character
    j copy_result               # Continue copying

end_test_result:
    sb $zero, resultch2($s3)    # Null-terminate result
    jr $ra
    
######################String to float ####################################################
# Conversion function
convert_string_to_float:
    la      $a0, resultch2        # Load the address of the string containing the number to be converted
    
    # Initialize variables
    li      $t1, 0                # Counter for digits before the decimal point
    li      $t2, 0                # Counter for digits after the decimal point
    li      $t3, 0                # Flag to track if the current digit is before or after the decimal point
    li      $t4, 10               # Base for decimal arithmetic
    
    mtc1    $zero, $f1            # Initialize floating-point accumulator to 0
    cvt.s.w $f1, $f1              # Convert integer 0 to float
    
    mtc1    $t4, $f5              # Load base 10 into floating-point register for multiplication/division
    cvt.s.w $f5, $f5              # Convert integer to float
    
    mtc1    $t4, $f4              # Load base 10 into floating-point register for multiplication/division
    cvt.s.w $f4, $f4              # Convert integer to float
    
    # Loop for processing each character of the string
loop:
    lb      $t5, 0($a0)          # Load the current character
    
    # Check if the current character is the decimal point
    beq     $t5, '.', set_decimal_flag   # If decimal point, set decimal flag and continue
    
    # Check if the current character is the null terminator
    beqz    $t5, done_conversion         # If null terminator, exit loop
    
    # Check if the current character is a digit
    blt     $t5, '0', done_conversion    # If not a digit, exit loop
    bgt     $t5, '9', done_conversion    # If not a digit, exit loop
    
    # Convert character to integer
    subi    $t5, $t5, '0'                # Convert ASCII digit to integer
    
    # Check if the current digit is before or after the decimal point
    beq     $t3, $zero, before_decimal
    b       after_decimal
    
set_decimal_flag:
    # Set flag to indicate decimal point has been encountered
    li      $t3, 1                       # Set decimal flag
    b       next_char
    
before_decimal:
    # Multiply previous digits by base
    mul.s   $f1, $f1, $f4                # Multiply float number by 10
    mtc1    $t5, $f2                     # Convert integer to float
    cvt.s.w $f2, $f2
    add.s   $f1, $f1, $f2                # Add digit to float number
    b       next_char
    
after_decimal:
    # Divide following digits by base
    mtc1    $t5, $f2                     # Convert integer to float
    cvt.s.w $f2, $f2
    div.s   $f2, $f2, $f4                # Divide float number by divisor
    add.s   $f1, $f1, $f2                # Add digit to float number
    mul.s   $f4, $f4, $f5                # Multiply the divisor by 10
    b       next_char
    
next_char:
    # Move to the next character in the string
    addi    $a0, $a0, 1                  # Move to next character
    j       loop                         # Repeat loop
    
done_conversion:
    # Store the final float number in memory
    swc1    $f1, float_num               # Store the float number in memory

  jr $ra

######################Compare Normal####################################################       
#Compare if the test result is within the normal range for all strings
compareNormal:

#compareHGP name 
  la $a0 , testnamech2
    la $a1 , str1

    compareLoop1:
        lb $t0 , 0($a0)
        lb $t1 , 0($a1)
        beq $t0 , $zero , endstr1
        beq $t1 , $zero , endstr1
        beq $t0 , $t1 , contloop1
        j compareBGT # Jump to str2 if not equal to str1

    contloop1:
        addi $a0 , $a0 , 1
        addi $a1 , $a1 , 1
        j compareLoop1

    endstr1:
        beq $t0 , $t1 , equalStr1
      

    equalStr1:
    
      # Check if the test result is within the normal range for str1
    l.s $f10, float_num
    l.s $f12, minRes1
    l.s $f13, maxRes1
    c.le.s $f12, $f10       # Compare if minRes2 <= result
    bc1t compare_less_MaxHGB
    bc1f notNormalStr1      # If not, skip to the next comparison

compare_less_MaxHGB:
    c.le.s $f10, $f13       # Compare if result < maxRes2
    bc1t normalStr1         # If true, it's normal
   
    c.le.s $f13 , $f10      # Compare if result > maxRes2
    bc1t notNormalStr1         # If true, it's normal

notNormalStr1:
    li $v0, 4               # Print string
    la $a0, notnormal       # Load address of not normal string
    syscall
    j exitCMP

normalStr1:
    li $v0, 4               # Print string
    la $a0, normal          # Load address of normal string
    syscall
    j exitCMP

#compareBGT name 
compareBGT:
    la $a0 , testnamech2
    la $a1 , str2

    compareLoop2:
        lb $t0 , 0($a0)
        lb $t1 , 0($a1)
        beq $t0 , $zero , endstr2
        beq $t1 , $zero , endstr2
        beq $t0 , $t1 , contloop2

 
        j compareStr3  # Jump to compareStr3 if not equal to str2

    contloop2:
        addi $a0 , $a0 , 1
        addi $a1 , $a1 , 1
        j compareLoop2

    endstr2:
        beq $t0 , $t1 , equalStr2
       
        j exit 

    equalStr2:
       # Check if the test result is within the normal range for str1
    l.s $f10, float_num
    l.s $f12, minRes2
    l.s $f13, maxRes2
    c.le.s $f12, $f10       # Compare if minRes2 <= result
    bc1t compare_less_MaxBGT
    bc1f notNormalStr2      # If not, skip to the next comparison

compare_less_MaxBGT:
    c.le.s $f10, $f13       # Compare if result < maxRes2
    bc1t normalStr2         # If true, it's normal
   
    c.le.s $f13 , $f10      # Compare if result > maxRes2
    bc1t notNormalStr2         # If true, it's normal
notNormalStr2:
    li $v0, 4               # Print string
    la $a0, notnormal       # Load address of not normal string
    syscall
    j exitCMP

normalStr2:
    li $v0, 4               # Print string
    la $a0, normal          # Load address of normal string
    syscall
    j exitCMP

# Compare if the test result is within the normal range for str3
compareStr3:
    la $a0, testnamech2
    la $a1, str3

    compareLoop3:
        lb $t0, 0($a0)
        lb $t1, 0($a1)
        beq $t0, $zero, endstr3
        beq $t1, $zero, endstr3
        beq $t0, $t1, contloop3

        j exitCMP # Jump to compareStr4 if not equal to str3

    contloop3:
        addi $a0, $a0, 1
        addi $a1, $a1, 1
        j compareLoop3

    endstr3:
        l.s $f10, float_num       # Load the test result
        l.s $f12, maxRes3      # Load maxRes3

        c.lt.s $f10, $f12      # Compare if result < maxRes3
        bc1t normalStr3        # If true, it's normal

        li $v0, 4              # Print string
        la $a0, notnormal      # Load address of not normal string
        syscall 
        j exitCMP

    normalStr3:
        li $v0, 4              # Print string
        la $a0, normal         # Load address of normal string
        syscall 
        j exitCMP
 

exitCMP:
    jr $ra                   # Return

######################choice3 ####################################################     
# Function to extract, compare, and increment match count if names match
extract_compare_and_printCH3:
  # Save registers on stack
  addi $sp, $sp, -24                 # Allocate stack space for saved registers
  sw $ra, 0($sp)
  sw $s0, 4($sp)
  sw $s1, 8($sp)
  sw $s2, 12($sp)
  sw $s3, 16($sp)
  sw $s4, 20($sp)

  li $s0, 0                          # Index in buffer
  la $a0, data                       # Start of buffer

process_lines_loopCH3:
  move $s1, $s0                      # Initialize start of line
  li $s2, 0                          # Index for storing line

copy_lineCH3:
  lb $t1, data($s0)                  # Load character from buffer
  beqz $t1, end_of_bufferCH3            # Check for end of buffer
  sb $t1, current_line($s2)          # Store character in current_line buffer
  addiu $s2, $s2, 1                  # Increment index for current_line
  addiu $s0, $s0, 1                  # Move to next character
  beq $t1, 10, process_test_nameCH3     # Check for newline character to process line
  j copy_lineCH3

process_test_nameCH3:
  sb $zero, current_line($s2)        # Null-terminate the current line

  # Reset registers for test name extraction
  li $s2, 0                          # Reset index for storing test name
  la $a0, current_line               # Reset pointer to start of current_line

extract_test_nameCH3:
    lb $t1, 0($a0)                     # Load character from current line
    beqz $t1, end_test_name_extractionCH3 # Check for null terminator
    beq $t1, 58, found_colonCH3          # Check if character is a colon (ASCII 58)
    addiu $a0, $a0, 1                  # Skip current character
    j extract_test_nameCH3                # Continue extraction

found_colonCH3:
    addiu $a0, $a0, 1                  # Immediately move past the colon

copy_test_nameCH3:
    li $s3, 0                          # Initialize counter for three characters

copy_three_charsCH3:
    lb $t1, 0($a0)                     # Load character immediately after colon
    beq $s3, 3, end_test_name_extractionCH3 # If three characters have been copied, end extraction
    sb $t1, testnamech2($s2)           # Store character in testnamech2
    addiu $s2, $s2, 1                  # Increment test name index
    addiu $s3, $s3, 1                  # Increment counter for three characters
    addiu $a0, $a0, 1                  # Move to next character
    j copy_three_charsCH3                # Continue copying three characters

end_test_name_extractionCH3:
    sb $zero, testnamech2($s2)         # Null-terminate the extracted test name

  # Compare test names
  la $a1, testnamech2
  la $a2, UserTestName
  li $v0, 0                          # Initialize comparison result

compare_test_namesCH3:
  lb $t1, 0($a1)
  lb $t2, 0($a2)
  bne $t1, $t2, not_matchCH3           # If characters do not match, jump to not_match
  beqz $t1, testnames_matchCH3          # If end of string and all matched, they match
  addiu $a1, $a1, 1
  addiu $a2, $a2, 1
  j compare_test_namesCH3

testnames_matchCH3:
  # Increment match count
  lw $t1, match_count
  addiu $t1, $t1, 1
  sw $t1, match_count
  j extract_resultCH3                   # Jump to result extraction if test name matches

not_matchCH3:
  # Set start of next line
  addiu $s0, $s0, 1                  # Increment to start of next line
  j process_lines_loopCH3

extract_resultCH3:
  # Extract result from the line after the second comma
  li $s3, 0                          # Index for result
  li $s2, 0                          # Comma count
find_second_commaCH3:
  lb $t1, 0($a0)                     # Load character from line
  beqz $t1, end_result_extractionCH3    # Check for end of line
  beq $t1, 44, found_commaCH3           # Check for comma
  addiu $a0, $a0, 1                  # Move to next character
  j find_second_commaCH3

found_commaCH3:
  addiu $s2, $s2, 1                  # Increment comma count
  beq $s2, 2, start_result_extractionCH3 # If two commas found, start extracting result
  addiu $a0, $a0, 1                  # Otherwise, skip this comma
  j find_second_commaCH3

start_result_extractionCH3:
  lb $t1, 0($a0)                     # Load character from line
  beqz $t1, end_result_extractionCH3    # Check for end of line
  bne $t1, 44, store_characterCH3       # If not a comma, store the character
  j skip_characterCH3                   # If it's a comma, skip it

store_characterCH3:
  sb $t1, resADD($s3)                # Store result character in resADD
  addiu $s3, $s3, 1                  # Increment result index

skip_characterCH3:
  addiu $a0, $a0, 1                  # Move to next character
  j start_result_extractionCH3

end_result_extractionCH3:
  sb $zero, resADD($s3)              # Null-terminate the result
  la $a0, resADD                     # Load the address of the extracted result
  jal convert_string_to_floatCH3        # Convert extracted result to float
    	# Print newline
        li $v0, 4
        la $a0, newline
        syscall
	jal compareNormal

   	 li $v0, 4                   # syscall for printing string
   	 la $a0, current_line        # Load address of current line
   	 syscall

  # Continue processing lines
  addiu $s0, $s0, 1                  # Increment to start of next line
  j process_lines_loopCH3

end_of_bufferCH3:
  # Restore registers from stack
  lw $ra, 0($sp)
  lw $s0, 4($sp)
  lw $s1, 8($sp)
  lw $s2, 12($sp)
  lw $s3, 16($sp)
  lw $s4, 20($sp)
  addiu $sp, $sp, 24                 # Restore stack pointer
  jr $ra                             # Return from function

# Conversion function
convert_string_to_floatCH3:

    la      $a0, resADD      
     # Initialize variables
    li      $t1, 0                # Counter for digits before the decimal point
    li      $t2, 0                # Counter for digits after the decimal point
    li      $t3, 0                # Flag to track if the current digit is before or after the decimal point
    li      $t4, 10               # Base for decimal arithmetic
    
    mtc1    $zero, $f1            # Initialize floating-point accumulator to 0
    cvt.s.w $f1, $f1              # Convert integer 0 to float
    
    mtc1    $t4, $f5              # Load base 10 into floating-point register for multiplication/division
    cvt.s.w $f5, $f5              # Convert integer to float
    
    mtc1    $t4, $f4              # Load base 10 into floating-point register for multiplication/division
    cvt.s.w $f4, $f4              # Convert integer to float
    
    # Loop for processing each character of the string
loopCH3:
    lb      $t5, 0($a0)          # Load the current character
    
    # Check if the current character is the decimal point
    beq     $t5, '.', set_decimal_flagCH3   # If decimal point, set decimal flag and continue
    
    # Check if the current character is the null terminator
    beqz    $t5, done_conversionCH3         # If null terminator, exit loop
    
    # Check if the current character is a digit
    blt     $t5, '0', done_conversionCH3    # If not a digit, exit loop
    bgt     $t5, '9', done_conversionCH3    # If not a digit, exit loop
    
    # Convert character to integer
    subi    $t5, $t5, '0'                # Convert ASCII digit to integer
    
    # Check if the current digit is before or after the decimal point
    beq     $t3, $zero, before_decimalCH3
    b       after_decimalCH3
    
set_decimal_flagCH3:
    # Set flag to indicate decimal point has been encountered
    li      $t3, 1                       # Set decimal flag
    b       next_charCH3
    
before_decimalCH3:
    # Multiply previous digits by base
    mul.s   $f1, $f1, $f4                # Multiply float number by 10
    mtc1    $t5, $f2                     # Convert integer to float
    cvt.s.w $f2, $f2
    add.s   $f1, $f1, $f2                # Add digit to float number
    b       next_charCH3
    
after_decimalCH3:
    # Divide following digits by base
    mtc1    $t5, $f2                     # Convert integer to float
    cvt.s.w $f2, $f2
    div.s   $f2, $f2, $f4                # Divide float number by divisor
    add.s   $f1, $f1, $f2                # Add digit to float number
    mul.s   $f4, $f4, $f5                # Multiply the divisor by 10
    b       next_charCH3
    
next_charCH3:
    # Move to the next character in the string
    addi    $a0, $a0, 1                  # Move to next character
    j       loopCH3                         # Repeat loop
    
done_conversionCH3:
    # Store the final float number in memory
    
    swc1    $f1, float_num               # Store the float number in memory
     
  lwc1 $f2, float_add
    add.s $f2, $f2, $f1   # Add the new float number to float_add
    swc1 $f2, float_add   # Store back the sum to float_add

  jr $ra



string_compare:
    push_registers:     # Optional: Save registers if used in other parts of your program
        addi $sp, $sp, -8
        sw $ra, 4($sp)
        sw $a2, 0($sp)
    
    compare_loop7:
        lb $t0, 0($a0)  # Load a byte from the first string
        lb $t1, 0($a1)  # Load a byte from the second string
        beq $t0, $zero, check_second_string_end  # If end of first string, check if second is also at end
        bne $t0, $t1, strings_not_equal  # If bytes are not equal, jump to strings_not_equal
        addiu $a0, $a0, 1  # Increment pointer to next char in first string
        addiu $a1, $a1, 1  # Increment pointer to next char in second string
        j compare_loop7   # Loop back to start of comparison

    check_second_string_end:
        beq $t1, $zero, strings_equal  # If second string also ends, strings are equal

    strings_not_equal:
        li $v0, 0  # Set return value to 0 (strings not equal)
        j restore_and_return  # Jump to restore registers and return

    strings_equal:
        li $v0, 1  # Set return value to 1 (strings are equal)

    restore_and_return:
        lw $ra, 4($sp)
        lw $a2, 0($sp)
        addi $sp, $sp, 8
        jr $ra  # Return to caller
 
# Function to extract, compare, and increment match count if names match
extract_compare_and_printch3_bpt2:
  # Save registers on stack
  addi $sp, $sp, -24                 # Allocate stack space for saved registers
  sw $ra, 0($sp)
  sw $s0, 4($sp)
  sw $s1, 8($sp)
  sw $s2, 12($sp)
  sw $s3, 16($sp)
  sw $s4, 20($sp)

  li $s0, 0                          # Index in buffer
  la $a0, data                       # Start of buffer

process_lines_loopch3_bpt2:
  move $s1, $s0                      # Initialize start of line
  li $s2, 0                          # Index for storing line

copy_linech3_bpt2:
  lb $t1, data($s0)                  # Load character from buffer
  beqz $t1, end_of_bufferch3_bpt2            # Check for end of buffer
  sb $t1, current_line($s2)          # Store character in current_line buffer
  addiu $s2, $s2, 1                  # Increment index for current_line
  addiu $s0, $s0, 1                  # Move to next character
  beq $t1, 10, process_test_namech3_bpt2    # Check for newline character to process line
  j copy_linech3_bpt2

process_test_namech3_bpt2:
  sb $zero, current_line($s2)        # Null-terminate the current line

  # Reset registers for test name extraction
  li $s2, 0                          # Reset index for storing test name
  la $a0, current_line               # Reset pointer to start of current_line

extract_test_namech3_bpt2:
    lb $t1, 0($a0)                     # Load character from current line
    beqz $t1, end_test_name_extractionch3_bpt2 # Check for null terminator
    beq $t1, 58, found_colonch3_bpt2           # Check if character is a colon (ASCII 58)
    addiu $a0, $a0, 1                  # Skip current character
    j extract_test_namech3_bpt2                # Continue extraction

found_colonch3_bpt2:
    addiu $a0, $a0, 1                  # Immediately move past the colon

copy_test_namech3_bpt2:
    li $s3, 0                          # Initialize counter for three characters

copy_three_charsch3_bpt2:
    lb $t1, 0($a0)                     # Load character immediately after colon
    beq $s3, 3, end_test_name_extractionch3_bpt2 # If three characters have been copied, end extraction
    sb $t1, testnamech2($s2)           # Store character in testnamech2
    addiu $s2, $s2, 1                  # Increment test name index
    addiu $s3, $s3, 1                  # Increment counter for three characters
    addiu $a0, $a0, 1                  # Move to next character
    j copy_three_charsch3_bpt2                # Continue copying three characters

end_test_name_extractionch3_bpt2:
    sb $zero, testnamech2($s2)         # Null-terminate the extracted test name

  # Compare test names
  la $a1, testnamech2
  la $a2, UserTestName
  li $v0, 0                          # Initialize comparison result

compare_test_namesch3_bpt2:
  lb $t1, 0($a1)
  lb $t2, 0($a2)
  bne $t1, $t2, not_matchch3_bpt2            # If characters do not match, jump to not_match
  beqz $t1, testnames_matchch3_bpt2          # If end of string and all matched, they match
  addiu $a1, $a1, 1
  addiu $a2, $a2, 1
  j compare_test_namesch3_bpt2

testnames_matchch3_bpt2:
  # Increment match count
  lw $t1, match_count
  addiu $t1, $t1, 1
  sw $t1, match_count
  j extract_resultch3_bpt2                   # Jump to result extraction if test name matches

not_matchch3_bpt2:
  # Set start of next line
  addiu $s0, $s0, 1                  # Increment to start of next line
  j process_lines_loopch3_bpt2

extract_resultch3_bpt2:
  # Extract result from the line after the second comma
  li $s3, 0                          # Index for result
  li $s2, 0                          # Comma count
find_second_commach3_bpt2:
  lb $t1, 0($a0)                     # Load character from line
  beqz $t1, end_result_extractionch3_bpt2  # Check for end of line
  beq $t1, 44, found_comma2ch3_bpt2        # Check for comma
  addiu $a0, $a0, 1                  # Move to next character
  j find_second_commach3_bpt2

found_comma2ch3_bpt2:
  addiu $s2, $s2, 1                  # Increment comma count
  beq $s2, 3, start_result_extractionch3_bpt2 # If two commas found, start extracting result
  addiu $a0, $a0, 1                  # Otherwise, skip this comma
  j find_second_commach3_bpt2

start_result_extractionch3_bpt2:
  lb $t1, 0($a0)                     # Load character from line
  beqz $t1, end_result_extractionch3_bpt2    # Check for end of line
  bne $t1, 44, store_characterch3_bpt2       # If not a comma, store the character
  j skip_characterch3_bpt2                   # If it's a comma, skip it

store_characterch3_bpt2:
  sb $t1, resADD($s3)                # Store result character in resADD
  addiu $s3, $s3, 1                  # Increment result index

skip_characterch3_bpt2:
  addiu $a0, $a0, 1                  # Move to next character
  j start_result_extractionch3_bpt2

end_result_extractionch3_bpt2:
  sb $zero, resADD($s3)              # Null-terminate the result
  la $a0, resADD                     # Load the address of the extracted result
  jal convert_string_to_float        # Convert extracted result to float
    	lwc1 $f12, float_num  # Assuming float_num is the memory location where your result is stored

    	# Print newline
        li $v0, 4
        la $a0, newline
        syscall
        
# Load normal range values for systolic
    lwc1 $f14, maxRes4            # Load max normal value for systolic
    c.lt.s $f12, $f14             # Compare if systolic is less than max
    bc1t systolic_normal          # Branch if systolic is normal
    li $v0, 4
    la $a0, strNot                # Load address for not normal message
    syscall

    j end_result_processing       # Jump to end processing if not normal

systolic_normal:
    li $v0, 4
    la $a0, normalsys             # Load address for normal systolic message
    syscall

end_result_processing:
    # Print current line for context (optional)
    li $v0, 4
    la $a0, current_line
    syscall

  # Continue processing lines
  addiu $s0, $s0, 1                  # Increment to start of next line
  j process_lines_loopch3_bpt2

end_of_bufferch3_bpt2:
  # Restore registers from stack
  lw $ra, 0($sp)
  lw $s0, 4($sp)
  lw $s1, 8($sp)
  lw $s2, 12($sp)
  lw $s3, 16($sp)
  lw $s4, 20($sp)
  addiu $sp, $sp, 24                 # Restore stack pointer
  jr $ra                             # Return from function

# Function to extract, compare, and increment match count if names match
extract_compare_and_printch3_bpt:
  # Save registers on stack
  addi $sp, $sp, -24                 # Allocate stack space for saved registers
  sw $ra, 0($sp)
  sw $s0, 4($sp)
  sw $s1, 8($sp)
  sw $s2, 12($sp)
  sw $s3, 16($sp)
  sw $s4, 20($sp)

  li $s0, 0                          # Index in buffer
  la $a0, data                       # Start of buffer

process_lines_loopch3_bpt:
  move $s1, $s0                      # Initialize start of line
  li $s2, 0                          # Index for storing line

copy_linech3_bpt:
  lb $t1, data($s0)                  # Load character from buffer
  beqz $t1, end_of_bufferch3_bpt            # Check for end of buffer
  sb $t1, current_line($s2)          # Store character in current_line buffer
  addiu $s2, $s2, 1                  # Increment index for current_line
  addiu $s0, $s0, 1                  # Move to next character
  beq $t1, 10, process_test_namech3_bpt     # Check for newline character to process line
  j copy_linech3_bpt

process_test_namech3_bpt:
  sb $zero, current_line($s2)        # Null-terminate the current line

  # Reset registers for test name extraction
  li $s2, 0                          # Reset index for storing test name
  la $a0, current_line               # Reset pointer to start of current_line

extract_test_namech3_bpt:
    lb $t1, 0($a0)                     # Load character from current line
    beqz $t1, end_test_name_extractionch3_bpt # Check for null terminator
    beq $t1, 58, found_colonch3_bpt           # Check if character is a colon (ASCII 58)
    addiu $a0, $a0, 1                  # Skip current character
    j extract_test_namech3_bpt                # Continue extraction

found_colonch3_bpt:
    addiu $a0, $a0, 1                  # Immediately move past the colon

copy_test_namech3_bpt:
    li $s3, 0                          # Initialize counter for three characters

copy_three_charsch3_bpt:
    lb $t1, 0($a0)                     # Load character immediately after colon
    beq $s3, 3, end_test_name_extractionch3_bpt # If three characters have been copied, end extraction
    sb $t1, testnamech2($s2)           # Store character in testnamech2
    addiu $s2, $s2, 1                  # Increment test name index
    addiu $s3, $s3, 1                  # Increment counter for three characters
    addiu $a0, $a0, 1                  # Move to next character
    j copy_three_charsch3_bpt                 # Continue copying three characters

end_test_name_extractionch3_bpt:
    sb $zero, testnamech2($s2)         # Null-terminate the extracted test name

  # Compare test names
  la $a1, testnamech2
  la $a2, UserTestName
  li $v0, 0                          # Initialize comparison result

compare_test_namesch3_bpt:
  lb $t1, 0($a1)
  lb $t2, 0($a2)
  bne $t1, $t2, not_matchch3_bpt            # If characters do not match, jump to not_match
  beqz $t1, testnames_matchch3_bpt          # If end of string and all matched, they match
  addiu $a1, $a1, 1
  addiu $a2, $a2, 1
  j compare_test_namesch3_bpt

testnames_matchch3_bpt:
  # Increment match count
  lw $t1, match_count
  addiu $t1, $t1, 1
  sw $t1, match_count
  j extract_resultch3_bpt                   # Jump to result extraction if test name matches

not_matchch3_bpt:
  # Set start of next line
  addiu $s0, $s0, 1                  # Increment to start of next line
  j process_lines_loopch3_bpt
extract_resultch3_bpt:
  # Initialize comma count and index for result extraction
  li $s2, 0                          # Comma count
  li $s3, 0                          # Index for storing result

find_commas_and_extractch3_bpt:
   lb $t1, 0($a0)                     # Load character from line      # Load character from current line
  beqz $t1, end_result_extractionch3_bpt    # Check for null terminator (end of line)
  beq $t1, 44, found_commach3_bpt           # Check for comma (ASCII 44)
  bgt $s2, 1, store_characterch3_bpt        # If more than one comma has been found, store the character
  j skip_characterch3_bpt

found_commach3_bpt:
  addiu $s2, $s2, 1                  # Increment comma count
  beq $s2, 3, end_result_extractionch3_bpt  # If three commas are found, end extraction
  j skip_characterch3_bpt                   # Skip the comma character

store_characterch3_bpt:
  sb $t1, resADD($s3)                # Store the character in resADD
  addiu $s3, $s3, 1                  # Increment result index

skip_characterch3_bpt:
  addiu $a0, $a0, 1                  # Move to the next character
  j find_commas_and_extractch3_bpt

end_result_extractionch3_bpt:
  sb $zero, resADD($s3)              # Null-terminate the result at the current position
  la $a0, resADD                     # Load the address of the extracted result
  jal convert_string_to_float        # Convert extracted result to float and continue processing
    	lwc1 $f12, float_num  # Assuming float_num is the memory location where your result is stored

    	# Print newline
        li $v0, 4
        la $a0, newline
        syscall
        
# Load normal range values for systolic
    lwc1 $f15, maxRes5            # Load max normal value for systolic
    c.lt.s $f12, $f15             # Compare if systolic is less than max
    bc1t Diastolic_normal          # Branch if systolic is normal
    li $v0, 4
    la $a0, strNotDiastolic                # Load address for not normal message
    syscall

    j end_result_processing2       # Jump to end processing if not normal

Diastolic_normal:
    li $v0, 4
    la $a0, normalDiastolic             # Load address for normal systolic message
    syscall

end_result_processing2:
    # Print current line for context (optional)
    li $v0, 4
    la $a0, current_line
    syscall

  # Continue processing lines
  addiu $s0, $s0, 1                  # Increment to start of next line
  j process_lines_loopch3_bpt

end_of_bufferch3_bpt:
  # Restore registers from stack
  lw $ra, 0($sp)
  lw $s0, 4($sp)
  lw $s1, 8($sp)
  lw $s2, 12($sp)
  lw $s3, 16($sp)
  lw $s4, 20($sp)
  addiu $sp, $sp, 24                 # Restore stack pointer
  jr $ra                             # Return from function

############################ Id choice 2 ########################################
# Function to extract patient ID from each line, compare, and set flag if match found
extract_compare_and_print1:
    # Save registers on stack
    addi $sp, $sp, -16
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)

    li $s0, 0  # Index in buffer
    la $a0, data # Start of buffer

process_lines_loop1:
    # Initialize start of line
    move $s1, $s0
    li $s2, 0  # index for storing line

copy_line1:
    lb $t1, data($s0)     # Load character from buffer
    beq $t1, 0, end_of_buffer1 # Check for end of buffer
    sb $t1, current_line($s2) # Store character in current_line buffer
    addi $s2, $s2, 1      # Increment index for current_line
    beq $t1, 10, check_id1 # Check for newline character
    addi $s0, $s0, 1      # Move to next character
    j copy_line1
    


check_id1:
    # Null-terminate the current line
    sb $zero, current_line($s2)

    # Extract patient ID and compare with given ID
    la $a1, patientIDch2
    la $a0, current_line
    li $t0, 0
extract_id1:
    lb $t1, 0($a0)
    beq $t1, 58, done_extracting_id1  # Stop at ':' (colon is delimiter)
    sb $t1, patientIDch2($t0)       # Store character in patientIDch2
    addi $t0, $t0, 1
    addi $a0, $a0, 1
    j extract_id1

done_extracting_id1:
    sb $zero, patientIDch2($t0) # Null-terminate patient ID

    # Compare patient IDs
    la $a1, patientIDch2
    la $a2, id_to_compare_with
    li $v0, 0  # Result of comparison

compare_loop1:
    lb $t1, 0($a1)
    lb $t2, 0($a2)
    bne $t1, $t2, id_not_match1  # If characters do not match, jump to id_not_match
    beqz $t1, ids_match1         # If we reach end of string and all matched, they match
    addi $a1, $a1, 1
    addi $a2, $a2, 1
    j compare_loop1

ids_match1:
    li $t0, 1
    sw $t0, match_found         # Set match found flag
    jal extract_test_name # Extract test name from current_line
    la $a0, testnamech2
    la $a1, str4
    jal string_compare
    beq $v0, 1, handle_bpt # If BPT, handle special case
    
    jal extract_test_result  # Extract test result from current_line
     
    # Convert result string to float and print it
    jal convert_string_to_floatCH3
    
    li $v0,4
    la $a0,testnamech2
    syscall
    
    li $v0,4
    la $a0,delimiter2 
    syscall
    jal     compareNormal            # Compares the float result with normal ranges

    j process_lines_loop1  # Continue processing next line
handle_bpt2:
j begin 
id_not_match1:
    # Set start of next line
    addi $s0, $s0, 1            # Increment to skip the newline character
    j process_lines_loop1

end_of_buffer1:
	bnez $s2, check_id1
    # Restore registers from stack
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    addi $sp, $sp, 16

    jr $ra  # Return
    
############################ Id choice 3 ######################################## 
# Function to extract patient ID from each line, compare, and set flag if match found
extract_compare_and_print3:
    # Save registers on stack
    addi $sp, $sp, -16
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)

    li $s0, 0  # Index in buffer
    la $a0, data # Start of buffer

process_lines_loop3:
    # Initialize start of line
    move $s1, $s0
    li $s2, 0  # index for storing line

copy_line3:
    lb $t1, data($s0)     # Load character from buffer
    beq $t1, 0, end_of_buffer3 # Check for end of buffer
    sb $t1, current_line($s2) # Store character in current_line buffer
    addi $s2, $s2, 1      # Increment index for current_line
    beq $t1, 10, check_id3 # Check for newline character
    addi $s0, $s0, 1      # Move to next character
    j copy_line3

check_id3:
    # Null-terminate the current line
    sb $zero, current_line($s2)

    # Extract patient ID and compare with given ID
    la $a1, patientIDch2
    la $a0, current_line
    li $t0, 0
extract_id3:
    lb $t1, 0($a0)
    beq $t1, 58, done_extracting_id3  # Stop at ':' (colon is delimiter)
    sb $t1, patientIDch2($t0)       # Store character in patientIDch2
    addi $t0, $t0, 1
    addi $a0, $a0, 1
    j extract_id3

done_extracting_id3:
    sb $zero, patientIDch2($t0) # Null-terminate patient ID

    # Compare patient IDs
    la $a1, patientIDch2
    la $a2, id_to_compare_with
    li $v0, 0  # Result of comparison

compare_loop3:
    lb $t1, 0($a1)
    lb $t2, 0($a2)
    bne $t1, $t2, id_not_match3  # If characters do not match, jump to id_not_match
    beqz $t1, ids_match3         # If we reach end of string and all matched, they match
    addi $a1, $a1, 1
    addi $a2, $a2, 1
    j compare_loop3

ids_match3:
    li $t0, 1
    sw $t0, match_found         # Set match found flag
    # Extract the test date from the current line
    jal extract_test_date

  
    # Compare extracted date with the user-entered date
    la $a1, testDatech2             # Address of the extracted test date
    la $a2, testDatestr              # Address of the user-entered date
    jal compare_dates               # Jump to the date comparison function
       
    beq $v0, 1, print_line3          # If dates match, print the line
    
    j process_lines_loop3            # Else, continue processing lines

print_line3:
    li $v0, 4                       # syscall for printing string
    la $a0, current_line            # Load address of the current line
    syscall
    j process_lines_loop3            # Continue to next line after printing

print_no_matchDate:
    li $v0, 4                       # syscall for printing string
    la $a0, no_match_message        # "No matching date found.\n"
    syscall
    li $v0, 10                      # syscall for exit
    syscall                  # Exit after printing no match message
    

id_not_match3:
    # Set start of next line
    addi $s0, $s0, 1            # Increment to skip the newline character
    j process_lines_loop3

end_of_buffer3:
    # Restore registers from stack
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    addi $sp, $sp, 16

    jr $ra  # Return
    
# Function to extract the test date from the current line
extract_test_date:
    la $a0, current_line       # Load address of the current line
    li $s3, 0                  # Index for test date in the buffer
    li $t2, 0                  # Counter for commas encountered

skip_to_date:
    lb $t0, 0($a0)             # Load the current character from the line
    beqz $t0, end_date_extract # If null terminator, end the extraction
    beq $t0, ',', process_commas_date # If comma is found, process it
    addiu $a0, $a0, 1          # Move to the next character
    j skip_to_date             # Continue until the first comma is found

process_commas_date:
    addiu $t2, $t2, 1          # Increment the comma counter
    addiu $a0, $a0, 1          # Move past the comma
    beq $t2, 1, start_copy_date # Start copying when the first comma has been processed
    j skip_to_date             # Continue to skip characters until the comma

start_copy_date:
    lb $t0, 0($a0)             # Start copying from the next character after the first comma

copy_date:
    beq $t0, ',', end_date_extract # Stop copying when the second comma is encountered
    beqz $t0, end_date_extract     # Stop copying if the null terminator is reached
    sb $t0, testDatech2($s3)       # Store the character in the testDatech2 buffer
    addiu $s3, $s3, 1              # Increment the index for testDatech2
    addiu $a0, $a0, 1              # Move to the next character
    lb $t0, 0($a0)                 # Load the next character
    j copy_date                    # Continue copying

end_date_extract:
    sb $zero, testDatech2($s3)     # Null-terminate the test date string
    jr $ra                         # Return from the function

compare_dates:
    # Assuming both dates are null-terminated strings in testDatech2 and testDatestr
    move $t1, $a1                   # Pointer to extracted date
    move $t2, $a2                   # Pointer to input date

date_loop:
    lb $t3, 0($t1)                  # Load byte from extracted date
    lb $t4, 0($t2)                  # Load byte from input date
    beqz $t3, check_end             # Check if end of extracted date
    beqz $t4, dates_not_equal       # Check if end of input date
    bne $t3, $t4, dates_not_equal   # Bytes do not match
    addiu $t1, $t1, 1               # Increment pointer to extracted date
    addiu $t2, $t2, 1               # Increment pointer to input date
    j date_loop                     # Loop back

check_end:
    beqz $t4, dates_equal           # Both strings ended, dates are equal
    j dates_not_equal               # Input date longer, not equal

dates_equal:
    li $v0, 1                       # Set return value to 1 (dates match)
    jr $ra                          # Return

dates_not_equal:

    li $v0, 0                       # Set return value to 0 (dates do not match)
    jr $ra                          # Return

############################  choice 4 ######################################## 
        
# Function to extract, compare, and increment match count if names match
extract_compare_and_printCH4:
  # Save registers on stack
  addi $sp, $sp, -24                 # Allocate stack space for saved registers
  sw $ra, 0($sp)
  sw $s0, 4($sp)
  sw $s1, 8($sp)
  sw $s2, 12($sp)
  sw $s3, 16($sp)
  sw $s4, 20($sp)

  li $s0, 0                          # Index in buffer
  la $a0, data                       # Start of buffer

process_lines_loopCH4:
  move $s1, $s0                      # Initialize start of line
  li $s2, 0                          # Index for storing line

copy_lineCH4:
  lb $t1, data($s0)                  # Load character from buffer
  beqz $t1, end_of_bufferCH4            # Check for end of buffer
  sb $t1, current_line($s2)          # Store character in current_line buffer
  addiu $s2, $s2, 1                  # Increment index for current_line
  addiu $s0, $s0, 1                  # Move to next character
  beq $t1, 10, process_test_nameCH4    # Check for newline character to process line
  j copy_lineCH4

process_test_nameCH4:
  sb $zero, current_line($s2)        # Null-terminate the current line

  # Reset registers for test name extraction
  li $s2, 0                          # Reset index for storing test name
  la $a0, current_line              # Reset pointer to start of current_line

extract_test_nameCH4:
    lb $t1, 0($a0)                     # Load character from current line
    beqz $t1, end_test_name_extractionCH4 # Check for null terminator
    beq $t1, 58, found_colonCH4           # Check if character is a colon (ASCII 58)
    addiu $a0, $a0, 1                  # Skip current character
    j extract_test_nameCH4               # Continue extraction

found_colonCH4:
    addiu $a0, $a0, 1                  # Immediately move past the colon

copy_test_nameCH4:
    li $s3, 0                          # Initialize counter for three characters

copy_three_charsCH4:
    lb $t1, 0($a0)                     # Load character immediately after colon
    beq $s3, 3, end_test_name_extractionCH4 # If three characters have been copied, end extraction
    sb $t1, testnamech2($s2)           # Store character in testnamech2
    addiu $s2, $s2, 1                  # Increment test name index
    addiu $s3, $s3, 1                  # Increment counter for three characters
    addiu $a0, $a0, 1                  # Move to next character
    j copy_three_charsCH4                 # Continue copying three characters

end_test_name_extractionCH4:
    sb $zero, testnamech2($s2)         # Null-terminate the extracted test name

  # Compare test names
  la $a1, testnamech2
  la $a2, UserTestName
  li $v0, 0                          # Initialize comparison result

compare_test_namesCH4:
  lb $t1, 0($a1)
  lb $t2, 0($a2)
  bne $t1, $t2, not_matchCH4            # If characters do not match, jump to not_match
  beqz $t1, testnames_matchCH4          # If end of string and all matched, they match
  addiu $a1, $a1, 1
  addiu $a2, $a2, 1
  j compare_test_namesCH4

testnames_matchCH4:
  # Increment match count
  lw $t1, match_count
  addiu $t1, $t1, 1
  sw $t1, match_count
  j extract_resultCH4                   # Jump to result extraction if test name matches

not_matchCH4:
  # Set start of next line
  addiu $s0, $s0, 1                  # Increment to start of next line
  j process_lines_loopCH4

extract_resultCH4:
  # Extract result from the line after the second comma
  li $s3, 0                          # Index for result
  li $s2, 0                          # Comma count
find_second_commaCH4:
  lb $t1, 0($a0)                     # Load character from line
  beqz $t1, end_result_extractionCH4    # Check for end of line
  beq $t1, 44, found_commaCH4           # Check for comma
  addiu $a0, $a0, 1                  # Move to next character
  j find_second_commaCH4

found_commaCH4:
  addiu $s2, $s2, 1                  # Increment comma count
  beq $s2, 2, start_result_extractionCH4 # If two commas found, start extracting result
  addiu $a0, $a0, 1                  # Otherwise, skip this comma
  j find_second_commaCH4

start_result_extractionCH4:
  lb $t1, 0($a0)                     # Load character from line
  beqz $t1, end_result_extractionCH4    # Check for end of line
  bne $t1, 44, store_characterCH4       # If not a comma, store the character
  j skip_characterCH4                   # If it's a comma, skip it

store_characterCH4:
  sb $t1, resADD($s3)                # Store result character in resADD
  addiu $s3, $s3, 1                  # Increment result index

skip_characterCH4:
  addiu $a0, $a0, 1                  # Move to next character
  j start_result_extractionCH4

end_result_extractionCH4:
  sb $zero, resADD($s3)              # Null-terminate the result
  la $a0, resADD                     # Load the address of the extracted result
  jal convert_string_to_floatCH4        # Convert extracted result to float
   
  

  # Continue processing lines
  addiu $s0, $s0, 1                  # Increment to start of next line
  j process_lines_loopCH4

end_of_bufferCH4:
  # Restore registers from stack
  lw $ra, 0($sp)
  lw $s0, 4($sp)
  lw $s1, 8($sp)
  lw $s2, 12($sp)
  lw $s3, 16($sp)
  lw $s4, 20($sp)
  addiu $sp, $sp, 24                 # Restore stack pointer
  jr $ra                             # Return from function

# Conversion function
convert_string_to_floatCH4:

    la      $a0, resADD      
     # Initialize variables
    li      $t1, 0                # Counter for digits before the decimal point
    li      $t2, 0                # Counter for digits after the decimal point
    li      $t3, 0                # Flag to track if the current digit is before or after the decimal point
    li      $t4, 10               # Base for decimal arithmetic
    
    mtc1    $zero, $f1            # Initialize floating-point accumulator to 0
    cvt.s.w $f1, $f1              # Convert integer 0 to float
    
    mtc1    $t4, $f5              # Load base 10 into floating-point register for multiplication/division
    cvt.s.w $f5, $f5              # Convert integer to float
    
    mtc1    $t4, $f4              # Load base 10 into floating-point register for multiplication/division
    cvt.s.w $f4, $f4              # Convert integer to float
    
    # Loop for processing each character of the string
loopCH4:
    lb      $t5, 0($a0)          # Load the current character
    
    # Check if the current character is the decimal point
    beq     $t5, '.', set_decimal_flagCH4   # If decimal point, set decimal flag and continue
    
    # Check if the current character is the null terminator
    beqz    $t5, done_conversionCH4         # If null terminator, exit loop
    
    # Check if the current character is a digit
    blt     $t5, '0', done_conversionCH4    # If not a digit, exit loop
    bgt     $t5, '9', done_conversionCH4    # If not a digit, exit loop
    
    # Convert character to integer
    subi    $t5, $t5, '0'                # Convert ASCII digit to integer
    
    # Check if the current digit is before or after the decimal point
    beq     $t3, $zero, before_decimalCH4
    b       after_decimalCH4
    
set_decimal_flagCH4:
    # Set flag to indicate decimal point has been encountered
    li      $t3, 1                       # Set decimal flag
    b       next_charCH4
    
before_decimalCH4:
    # Multiply previous digits by base
    mul.s   $f1, $f1, $f4                # Multiply float number by 10
    mtc1    $t5, $f2                     # Convert integer to float
    cvt.s.w $f2, $f2
    add.s   $f1, $f1, $f2                # Add digit to float number
    b       next_charCH4
    
after_decimalCH4:
    # Divide following digits by base
    mtc1    $t5, $f2                     # Convert integer to float
    cvt.s.w $f2, $f2
    div.s   $f2, $f2, $f4                # Divide float number by divisor
    add.s   $f1, $f1, $f2                # Add digit to float number
    mul.s   $f4, $f4, $f5                # Multiply the divisor by 10
    b       next_charCH4
    
next_charCH4:
    # Move to the next character in the string
    addi    $a0, $a0, 1                  # Move to next character
    j       loopCH4                         # Repeat loop
    
done_conversionCH4:
    # Store the final float number in memory
    
    swc1    $f1, float_num               # Store the float number in memory
     
  lwc1 $f2, float_add
    add.s $f2, $f2, $f1   # Add the new float number to float_add
    swc1 $f2, float_add   # Store back the sum to float_add

  jr $ra

# Function to extract, compare, and increment match count if names match
extract_compare_and_printCH42:
  # Save registers on stack
  addi $sp, $sp, -24                 # Allocate stack space for saved registers
  sw $ra, 0($sp)
  sw $s0, 4($sp)
  sw $s1, 8($sp)
  sw $s2, 12($sp)
  sw $s3, 16($sp)
  sw $s4, 20($sp)

  li $s0, 0                          # Index in buffer
  la $a0, data                       # Start of buffer

process_lines_loopCH42:
  move $s1, $s0                      # Initialize start of line
  li $s2, 0                          # Index for storing line

copy_lineCH42:
  lb $t1, data($s0)                  # Load character from buffer
  beqz $t1, end_of_bufferCH42            # Check for end of buffer
  sb $t1, current_line($s2)          # Store character in current_line buffer
  addiu $s2, $s2, 1                  # Increment index for current_line
  addiu $s0, $s0, 1                  # Move to next character
  beq $t1, 10, process_test_nameCH42    # Check for newline character to process line
  j copy_lineCH42

process_test_nameCH42:
  sb $zero, current_line($s2)        # Null-terminate the current line

  # Reset registers for test name extraction
  li $s2, 0                          # Reset index for storing test name
  la $a0, current_line               # Reset pointer to start of current_line

extract_test_nameCH42:
    lb $t1, 0($a0)                     # Load character from current line
    beqz $t1, end_test_name_extractionCH42 # Check for null terminator
    beq $t1, 58, found_colonCH42           # Check if character is a colon (ASCII 58)
    addiu $a0, $a0, 1                  # Skip current character
    j extract_test_nameCH42                # Continue extraction

found_colonCH42:
    addiu $a0, $a0, 1                  # Immediately move past the colon

copy_test_nameCH42:
    li $s3, 0                          # Initialize counter for three characters

copy_three_charsCH42:
    lb $t1, 0($a0)                     # Load character immediately after colon
    beq $s3, 3, end_test_name_extractionCH42 # If three characters have been copied, end extraction
    sb $t1, testnamech2($s2)           # Store character in testnamech2
    addiu $s2, $s2, 1                  # Increment test name index
    addiu $s3, $s3, 1                  # Increment counter for three characters
    addiu $a0, $a0, 1                  # Move to next character
    j copy_three_charsCH42                # Continue copying three characters

end_test_name_extractionCH42:
    sb $zero, testnamech2($s2)         # Null-terminate the extracted test name

  # Compare test names
  la $a1, testnamech2
  la $a2, UserTestName
  li $v0, 0                          # Initialize comparison result

compare_test_namesCH42:
  lb $t1, 0($a1)
  lb $t2, 0($a2)
  bne $t1, $t2, not_matchCH42            # If characters do not match, jump to not_match
  beqz $t1, testnames_matchCH42          # If end of string and all matched, they match
  addiu $a1, $a1, 1
  addiu $a2, $a2, 1
  j compare_test_namesCH42

testnames_matchCH42:
  # Increment match count
  lw $t1, match_count
  addiu $t1, $t1, 1
  sw $t1, match_count
  j extract_resultCH42                   # Jump to result extraction if test name matches

not_matchCH42:
  # Set start of next line
  addiu $s0, $s0, 1                  # Increment to start of next line
  j process_lines_loopCH42

extract_resultCH42:
  # Extract result from the line after the second comma
  li $s3, 0                          # Index for result
  li $s2, 0                          # Comma count
find_second_commaCH42:
  lb $t1, 0($a0)                     # Load character from line
  beqz $t1, end_result_extractionCH42   # Check for end of line
  beq $t1, 44, found_commaCH422         # Check for comma
  addiu $a0, $a0, 1                  # Move to next character
  j find_second_commaCH42

found_commaCH422:
  addiu $s2, $s2, 1                  # Increment comma count
  beq $s2, 3, start_result_extractionCH42 # If two commas found, start extracting result
  addiu $a0, $a0, 1                  # Otherwise, skip this comma
  j find_second_commaCH42

start_result_extractionCH42:
  lb $t1, 0($a0)                     # Load character from line
  beqz $t1, end_result_extractionCH42    # Check for end of line
  bne $t1, 44, store_characterCH42       # If not a comma, store the character
  j skip_characterCH42                   # If it's a comma, skip it

store_characterCH42:
  sb $t1, resADD($s3)                # Store result character in resADD
  addiu $s3, $s3, 1                  # Increment result index

skip_characterCH42:
  addiu $a0, $a0, 1                  # Move to next character
  j start_result_extractionCH42

end_result_extractionCH42:
  sb $zero, resADD($s3)              # Null-terminate the result
  la $a0, resADD                     # Load the address of the extracted result
  jal convert_string_to_floatCH4        # Convert extracted result to float
  

  # Continue processing lines
  addiu $s0, $s0, 1                  # Increment to start of next line
  j process_lines_loopCH42

end_of_bufferCH42:
  # Restore registers from stack
  lw $ra, 0($sp)
  lw $s0, 4($sp)
  lw $s1, 8($sp)
  lw $s2, 12($sp)
  lw $s3, 16($sp)
  lw $s4, 20($sp)
  addiu $sp, $sp, 24                 # Restore stack pointer
  jr $ra                             # Return from function


# Function to extract, compare, and increment match count if names match
extract_compare_and_printCH43:
  # Save registers on stack
  addi $sp, $sp, -24                 # Allocate stack space for saved registers
  sw $ra, 0($sp)
  sw $s0, 4($sp)
  sw $s1, 8($sp)
  sw $s2, 12($sp)
  sw $s3, 16($sp)
  sw $s4, 20($sp)

  li $s0, 0                          # Index in buffer
  la $a0, data                       # Start of buffer

process_lines_loopCH43:
  move $s1, $s0                      # Initialize start of line
  li $s2, 0                          # Index for storing line

copy_lineCH43:
  lb $t1, data($s0)                  # Load character from buffer
  beqz $t1, end_of_bufferCH43            # Check for end of buffer
  sb $t1, current_line($s2)          # Store character in current_line buffer
  addiu $s2, $s2, 1                  # Increment index for current_line
  addiu $s0, $s0, 1                  # Move to next character
  beq $t1, 10, process_test_nameCH43     # Check for newline character to process line
  j copy_lineCH43

process_test_nameCH43:
  sb $zero, current_line($s2)        # Null-terminate the current line

  # Reset registers for test name extraction
  li $s2, 0                          # Reset index for storing test name
  la $a0, current_line               # Reset pointer to start of current_line

extract_test_nameCH43:
    lb $t1, 0($a0)                     # Load character from current line
    beqz $t1, end_test_name_extractionCH43 # Check for null terminator
    beq $t1, 58, found_colonCH43           # Check if character is a colon (ASCII 58)
    addiu $a0, $a0, 1                  # Skip current character
    j extract_test_nameCH43                # Continue extraction

found_colonCH43:
    addiu $a0, $a0, 1                  # Immediately move past the colon

copy_test_nameCH43:
    li $s3, 0                          # Initialize counter for three characters

copy_three_charsCH43:
    lb $t1, 0($a0)                     # Load character immediately after colon
    beq $s3, 3, end_test_name_extractionCH43 # If three characters have been copied, end extraction
    sb $t1, testnamech2($s2)           # Store character in testnamech2
    addiu $s2, $s2, 1                  # Increment test name index
    addiu $s3, $s3, 1                  # Increment counter for three characters
    addiu $a0, $a0, 1                  # Move to next character
    j copy_three_charsCH43                 # Continue copying three characters

end_test_name_extractionCH43:
    sb $zero, testnamech2($s2)         # Null-terminate the extracted test name

  # Compare test names
  la $a1, testnamech2
  la $a2, UserTestName
  li $v0, 0                          # Initialize comparison result

compare_test_namesCH43:
  lb $t1, 0($a1)
  lb $t2, 0($a2)
  bne $t1, $t2, not_matchCH43            # If characters do not match, jump to not_match
  beqz $t1, testnames_matchCH43          # If end of string and all matched, they match
  addiu $a1, $a1, 1
  addiu $a2, $a2, 1
  j compare_test_namesCH43

testnames_matchCH43:
  # Increment match count
  lw $t1, match_count
  addiu $t1, $t1, 1
  sw $t1, match_count
  j extract_resultCH43                   # Jump to result extraction if test name matches

not_matchCH43:
  # Set start of next line
  addiu $s0, $s0, 1                  # Increment to start of next line
  j process_lines_loopCH43
extract_resultCH43:
  # Initialize comma count and index for result extraction
  li $s2, 0                          # Comma count
  li $s3, 0                          # Index for storing result

find_commas_and_extractCH43:
   lb $t1, 0($a0)                     # Load character from line      # Load character from current line
  beqz $t1, end_result_extractionCH43    # Check for null terminator (end of line)
  beq $t1, 44, found_commaCH43           # Check for comma (ASCII 44)
  bgt $s2, 1, store_characterCH43        # If more than one comma has been found, store the character
  j skip_characterCH43

found_commaCH43:
  addiu $s2, $s2, 1                  # Increment comma count
  beq $s2, 3, end_result_extractionCH43  # If three commas are found, end extraction
  j skip_characterCH43                   # Skip the comma character

store_characterCH43:
  sb $t1, resADD($s3)                # Store the character in resADD
  addiu $s3, $s3, 1                  # Increment result index

skip_characterCH43:
  addiu $a0, $a0, 1                  # Move to the next character
  j find_commas_and_extractCH43

end_result_extractionCH43:
  sb $zero, resADD($s3)              # Null-terminate the result at the current position
  la $a0, resADD                     # Load the address of the extracted result
  jal convert_string_to_floatCH4        # Convert extracted result to float and continue processing

  # Continue processing lines
  addiu $s0, $s0, 1                  # Increment to start of next line
  j process_lines_loopCH43

end_of_bufferCH43:
  # Restore registers from stack
  lw $ra, 0($sp)
  lw $s0, 4($sp)
  lw $s1, 8($sp)
  lw $s2, 12($sp)
  lw $s3, 16($sp)
  lw $s4, 20($sp)
  addiu $sp, $sp, 24                 # Restore stack pointer
  jr $ra                             # Return from function
