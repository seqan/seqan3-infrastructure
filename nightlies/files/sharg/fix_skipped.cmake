cmake_minimum_required (VERSION 3.10)

file (READ ${FILE} content)
string (REPLACE "PROPERTIES SKIP_RETURN_CODE 1" "PROPERTIES PASS_REGULAR_EXPRESSION \"TARGET_FILE\"" content ${content})
file (WRITE ${FILE} ${content})

