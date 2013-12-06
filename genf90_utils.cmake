# Utilities for invoking genf90 on a template file.

# If ENABLE_GENF90 is set to a true value, the functions here will actually
# inform CMake to invoke genf90 to generate the sources.

# If ENABLE_GENF90 is not true, the functions here not generate source
# code, but process_genf90_source_list will still return the generated file
# names that would have been used.

if(ENABLE_GENF90)

  # Notify CMake that a Fortran file can be generated from a genf90
  # template.
  function(preprocess_genf90_template genf90_file fortran_file)

    add_custom_command(OUTPUT ${fortran_file}
      COMMAND ${GENF90} ${genf90_file} >${fortran_file}
      MAIN_DEPENDENCY ${genf90_file})

    get_filename_component(stripped_name ${fortran_file} NAME_WE)

    add_custom_target(generate_${stripped_name} DEPENDS ${fortran_file})

  endfunction(preprocess_genf90_template)

else()

  # Stub if genf90 is off.
  function(preprocess_genf90_template)
  endfunction()

endif()

# Given a list of genf90 templates, an output directory for generated
# sources, and the name of a source list, tells CMake to generate sources
# if necessary, and adds those sources to the list.
function(process_genf90_source_list genf90_file_list output_directory
    fortran_list_name)

  foreach(genf90_file IN LISTS genf90_file_list)

    # If a file is a relative path, expand it (relative to current source
    # directory.
    get_filename_component(genf90_file "${genf90_file}" ABSOLUTE)

    # Get extensionless base name from input.
    get_filename_component(genf90_file_stripped "${genf90_file}" NAME_WE)

    # Add generated file to the test list.
    set(fortran_file ${output_directory}/${genf90_file_stripped}.F90)
    preprocess_genf90_template(${genf90_file} ${fortran_file})
    list(APPEND ${fortran_list_name} ${fortran_file})
  endforeach()

  # Export ${fortran_list_name} to the caller.
  set(${fortran_list_name} "${${fortran_list_name}}" PARENT_SCOPE)

endfunction(process_genf90_source_list)
