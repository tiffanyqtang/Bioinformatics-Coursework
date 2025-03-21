#!/usr/bin/bash

# Above is the shebang line. This tells the shell interpreter what language the code in this file is written in. It allows you to execute the file without needing to know the language.

# Any line with a # is a comment line. Everything after the # is ignored.

# The following line shows how to define a shell variable
# By convention, we use lower case variable names to avoid collisions with environmental variables that are in upper case

samfile=/scratch/work/courses/BI7653/hw1.2025/week1.sam

# By contrast, the PWD variable is an environmental variable that tracks the current location in the file system
# Of course, we also can get the present working directory using the pwd function

echo The present working directory is:
echo $PWD


# Example of echo with variable expansion (the $ before samfile means to replace $samfile with the variable contents)

echo This is the contents of the samfile variable: $samfile


# Now echo the date command in a line of text using command substitution
# If we didnt wrap date with $() BASH would just print the word date.

echo This is todays time and date: $(date)

