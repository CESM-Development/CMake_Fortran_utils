# Utilities for using pFUnit's preprocessor and provided driver file.

# In most cases, the only build function needed will be
# add_pFUnit_executable, defined at the end.

# Additionally, define_pFUnit_failure can be used to inform CTest about how
# to detect whether a pFUnit test has failed.

# Notify CMake that a given Fortran file can be produced by preprocessing a
# pFUnit file.
function(preprocess_pf_suite pf_file fortran_file)

  add_custom_command(OUTPUT ${fortran_file}
    COMMAND python ${PFUNIT_PARSER} ${pf_file} ${fortran_file}
    MAIN_DEPENDENCY ${pf_file})

endfunction(preprocess_pf_suite)

# This function manages most of the work involved in preprocessing pFUnit
# files. You provide every *.pf file for a given executable, an output
# directory where generated sources should be output, and a list name. It
# will generate the sources, and append them and the pFUnit driver to the
# named list.
function(process_pFUnit_source_list pf_file_list output_directory
    fortran_list_name)

  foreach(pf_file IN LISTS pf_file_list)

    # If a file is a relative path, expand it (relative to current source
    # directory.
    get_filename_component(pf_file "${pf_file}" ABSOLUTE)

    # Get extensionless base name from input.
    get_filename_component(pf_file_stripped "${pf_file}" NAME_WE)

    # Add the generated Fortran files to the source list.
    set(fortran_file ${output_directory}/${pf_file_stripped}.F90)
    preprocess_pf_suite(${pf_file} ${fortran_file})
    list(APPEND ${fortran_list_name} ${fortran_file})

    # Add the file to testSuites.inc
    set(testSuites_contents
      "${testSuites_contents}ADD_TEST_SUITE(${pf_file_stripped}_suite)\n")
  endforeach()

  # Regenerate testSuites.inc if and only if necessary.
  if(EXISTS ${output_directory}/testSuites.inc)
    file(READ ${output_directory}/testSuites.inc old_testSuites_contents)
  endif()

  if(NOT testSuites_contents STREQUAL old_testSuites_contents)
    file(WRITE ${output_directory}/testSuites.inc ${testSuites_contents})
  endif()

  # Export ${fortran_list_name} to the caller, and add ${PFUNIT_DRIVER}
  # to it.
  set(${fortran_list_name} "${${fortran_list_name}}" "${PFUNIT_DRIVER}"
    PARENT_SCOPE)

endfunction(process_pFUnit_source_list)

# Creates an executable of the given name using the pFUnit driver. Input
# variables are the executable name, a list of .pf files, the output
# directory for generated sources, and a list of regular Fortran files.
function(add_pFUnit_executable name pf_file_list output_directory
    fortran_source_list)

  # Handle source code generation, add to list of sources.
  process_pFUnit_source_list("${pf_file_list}" ${output_directory}
    fortran_source_list)

  # Create the executable itself.
  add_executable(${name} ${fortran_source_list})

  # Handle pFUnit linking.
  target_link_libraries(${name} "${PFUNIT_LIBRARIES}")

  # Necessary to include testSuites.inc
  get_target_property(includes ${name} INCLUDE_DIRECTORIES)
  list(APPEND includes ${output_directory})
  set_target_properties(${name} PROPERTIES
    INCLUDE_DIRECTORIES "${includes}")

  # The above lines are equivalent to:
  #   target_include_directories(${name} PRIVATE ${output_directory})
  # However, target_include_directories was not added until 2.8.11, and at
  # the time of this writing, we can't depend on having such a recent
  # version of CMake available on HPC systems.

endfunction(add_pFUnit_executable)

# Tells CTest what regular expressions are used to signal pass/fail from
# pFUnit output.
function(define_pFUnit_failure test_name)
  # Set both pass and fail regular expressions to minimize the change that
  # the system under test will interfere with output and cause a false
  # negative.
  set_tests_properties(${test_name} PROPERTIES
      FAIL_REGULAR_EXPRESSION "FAILURES!!!")
  set_tests_properties(${test_name} PROPERTIES
      PASS_REGULAR_EXPRESSION "OK")
endfunction(define_pFUnit_failure)
