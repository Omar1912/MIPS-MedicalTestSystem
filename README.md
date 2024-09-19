# Medical Test Management System (MIPS Assembly)
This repository contains the source code for a Medical Test Management System written in MIPS assembly. The system is designed to efficiently manage medical test data for patients, allowing users to store, search, update, and analyze test results.

### Project Overview
The project solves the problem of managing and retrieving medical test data in an organized manner, providing functionality for adding new tests, searching by patient ID, identifying abnormal tests, and calculating averages.

### Solution Approach
The program uses a text-based menu to interact with users, allowing them to perform various actions such as adding new tests, searching for tests by patient ID, updating or deleting existing test data, and more. Data is validated for correctness before being stored.

### Main Functions
1. **Add New Medical Test**
Allows users to input a new medical test, including patient ID, test name, test date, and result, and stores it in the system.

2. **Search by Patient ID**
Retrieves all tests associated with a specific patient ID, displaying their test history.

3. **Search for Abnormal Tests**
Identifies and retrieves all test results that fall outside the normal range for a particular test.

4. **Average Test Value**
Calculates the average value of a specific medical test across all patients.

5. **Update Test Result**
Updates the result of an existing medical test, allowing for corrections or changes.

6. **Delete a Test**
Removes a medical test from the system based on the user’s input.

### Data Structures & Algorithms
**.data Segment**: Defines memory storage for patient ID, test name, test date, test result, and various prompts and error messages.

**String Handling**: Compares strings for matching patient IDs and validates input formats (dates, IDs, and results).

**Floating Point Calculations**: Performs floating-point arithmetic to calculate averages and determine normal/abnormal results.

### Key Functions (MIPS Assembly)
`Input Validation`: Ensures valid data types (e.g., integer for patient ID, string for test names, proper date format) and displays error messages for invalid inputs.

`File Handling`: Reads and writes medical test data from a text file.

`String Comparison`: Compares patient IDs and test names to identify matching records
