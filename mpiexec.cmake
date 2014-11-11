function( add_mpi_test _testName _testExe _testArgs _numProc )

    if (${PLATFORM} STREQUAL "yellowstone" )
        ###
        ### note: no space between -n and num_proc for mpirun.lsf on
        ### yellowstone
        ###
        set(MPIEXEC_NPF -n${_numProc})
        set(EXE_CMD ${EXECCA} ${MPIEXEC} ${_testExe} ${_testArgs} ${MPIEXEC_NPF})
    else()
        set(MPIEXEC_NPF ${MPIEXEC_NUMPROC_FLAG} ${_numProc})
        set(EXE_CMD ${MPIEXEC} ${MPIEXEC_NPF} ${_testExe} ${_testArgs})
    endif()
    add_test(NAME ${_testName} COMMAND ${EXE_CMD} )

endfunction(add_mpi_test)




