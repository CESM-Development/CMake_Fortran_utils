! This test is useful to know if you have hdf5 but not if it is parallel capable since
! the var_par_access function is supported even in serial.
program TryNC4
  use netcdf
  integer :: ierr, fh, varid
  ierr = nf90_var_par_access(fh,varid,NF90_COLLECTIVE)
end program
