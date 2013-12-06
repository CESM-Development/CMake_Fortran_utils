
# For each relative path in ${file_list}, prepend ${base_directory} to make
# an absolute path, and put result in list named by ${new_list_name}.
function(expand_relative_paths file_list base_directory new_list_name)

  unset(${new_list_name})
  foreach(file IN LISTS file_list)
    if("${file}" MATCHES "^/")
      set(new_file "${file}")
    else()
      set(new_file "${base_directory}/${file}")
    endif()
    list(APPEND ${new_list_name} "${new_file}")
  endforeach()

  set(${new_list_name} "${${new_list_name}}" PARENT_SCOPE)

endfunction(expand_relative_paths)

# Find an absolute file path in ${all_sources} for each base name in
# ${sources_needed}, and append found paths to ${source_list}.
function(extract_sources sources_needed all_sources source_list)

  foreach(needed_source IN LISTS ${sources_needed})

    set(source_match source-NOTFOUND)

    foreach(source IN LISTS ${all_sources})
      if(${source} MATCHES "(^|/)${needed_source}\$")
        set(source_match ${source})
      endif()
    endforeach()

    if(NOT source_match)
      message(FATAL_ERROR
        "Source file not found: ${needed_source}
After searching in list: ${${all_sources}}")
    endif()

    list(APPEND ${source_list} ${source_match})

  endforeach()

  set(${source_list} "${${source_list}}" PARENT_SCOPE)

endfunction(extract_sources)
