# Find module for pFUnit
#
# Sets the typical variables:
# PFUNIT_FOUND
# PFUNIT_LIBRARY(/LIBRARIES)
# PFUNIT_INCLUDE_DIR(/DIRS)
#
# Also sets:
# PFUNIT_DRIVER
# PFUNIT_MODULE_DIR
# PFUNIT_PARSER

include(FindPackageHandleStandardArgs)

find_program(PFUNIT_PARSER pFUnitParser.py
  HINTS $ENV{PFUNIT}/bin)

string(REGEX REPLACE "bin/pFUnitParser\\.py\$" ""
  pfunit_directory ${PFUNIT_PARSER})

find_library(PFUNIT_LIBRARY pfunit
  HINTS ${pfunit_directory}/lib)

find_path(PFUNIT_INCLUDE_DIR driver.F90
  HINTS ${pfunit_directory}/include)

set(PFUNIT_DRIVER ${PFUNIT_INCLUDE_DIR}/driver.F90)

find_path(PFUNIT_MODULE_DIR NAMES pfunit.mod PFUNIT.MOD
  HINTS ${pfunit_directory}/include ${pfunit_directory}/mod)

set(PFUNIT_LIBRARIES ${PFUNIT_LIBRARY})
set(PFUNIT_INCLUDE_DIRS ${PFUNIT_INCLUDE_DIR} ${PFUNIT_MODULE_DIR})

# Handle QUIETLY and REQUIRED.
find_package_handle_standard_args(pFUnit DEFAULT_MSG
  PFUNIT_LIBRARY PFUNIT_INCLUDE_DIR PFUNIT_MODULE_DIR PFUNIT_PARSER)

mark_as_advanced(PFUNIT_INCLUDE_DIR PFUNIT_LIBRARY PFUNIT_MODULE_DIR
  PFUNIT_PARSER)
