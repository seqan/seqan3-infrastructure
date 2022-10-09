# Log thresholds.
set (CTEST_CUSTOM_MAXIMUM_FAILED_TEST_OUTPUT_SIZE 2048)
set (CTEST_CUSTOM_MAXIMUM_PASSED_TEST_OUTPUT_SIZE 10)
set (CTEST_CUSTOM_MAXIMUM_NUMBER_OF_ERRORS   100)
set (CTEST_CUSTOM_MAXIMUM_NUMBER_OF_WARNINGS 10)

# Warning exception
set (
  CTEST_CUSTOM_WARNING_EXCEPTION
    ${CTEST_CUSTOM_WARNING_EXCEPTION} # keep current warning exceptions
    "layout of aggregates containing vectors"
)

set (
  CTEST_CUSTOM_ERROR_EXCEPTION
    ${CTEST_CUSTOM_ERROR_EXCEPTION} # keep current error exceptions
    "multiple use of section label 'api303' while adding anchor"
)
