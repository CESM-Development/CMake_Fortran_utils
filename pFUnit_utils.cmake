# Utilities for using pFUnit's preprocessor and provided driver file.

# In most cases, the only function needed will be add_pFUnit_executable,
# defined at the end.

# Notify CMake that a given Fortran file can be produced by preprocessing a
# pFUnit file.
function(preprocess_pf_suite pf_file fortran_file)

  add_custom_command(OUTPUT ${fortran_file}
    COMMAND python ${PFUNIT_PARSER} ${pf_file} ${fortran_file}
    MAIN_DEPENDENCY ${pf_file})

  set_source_files_properties(${fortran_file} PROPERTIES GENERATED 1)

endfunction(preprocess_pf_suite)

# This function manages most of the work involved in preprocessing pFUnit
# files. You provide absolute paths to every *.pf file for a given
# executable, an output directory where generated sources should be output,
# and a list name. It will generate the sources, and append them and the
# pFUnit driver to the named list.
function(process_pFUnit_source_list pf_file_list output_directory
    fortran_list_name)

  foreach(pf_file IN LISTS pf_file_list)
    # Get base name from input.
    string(REGEX REPLACE "(.*/)" "" pf_file_basename "${pf_file}")

    # Add the generated Fortran files to the source list.
    string(REGEX REPLACE "(.*)\\.pf\$" "${output_directory}\\1.F90"
      fortran_file ${pf_file_basename})
    preprocess_pf_suite(${pf_file} ${fortran_file})
    list(APPEND ${fortran_list_name} ${fortran_file})

    # Add the file to testSuites.inc
    string(REGEX REPLACE "\\.pf\$" "_suite" suite_name ${pf_file_basename})
    set(testSuites_contents
      "${testSuites_contents}ADD_TEST_SUITE(${suite_name})\n")
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

endfunction(add_pFUnit_executable)
