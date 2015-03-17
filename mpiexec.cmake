function( add_mpi_test _testName _testExe _testArgs _numProc _timeout)

    if ("${PLATFORM}" STREQUAL "yellowstone" )
        ###
        ### note: no space between -n and num_proc for mpirun.lsf on
        ### yellowstone
        ###
        set(MPIEXEC_NPF -n${_numProc})
        set(EXE_CMD ${EXECCA} ${MPIEXEC} ${MPIEXEC_PREFLAGS} ${_testExe} ${_testArgs} ${MPIEXEC_NPF})
    elseif ("${PLATFORM}" STREQUAL "cetus" )
        ###
        ###
				#set(PIO_RUNJOB ${CMAKE_BINARY_DIR}/scripts/pio_runjob.sh)
        set(REQUIRED_OPTION --block \$ENV{COBALT_PARTNAME} --envs GPFS_COLLMEMPROF=1 --envs GPFSMPIO_NAGG_PSET=16 --envs ROMIO_HINTS=/home/pkcoff/public/romio_hints --envs GPFSMPIO_BALANCECONTIG=1 --envs GPFSMPIO_AGGMETHOD=2 --envs PAMID_TYPED_ONESIDED=1 --envs PAMID_RMA_PENDING=1M --envs GPFSMPIO_BRIDGERINGAGG=1 ) 
        set(RUNJOB_NPF --np ${_numProc})
        if (DEFINED ENV{BGQ_RUNJOB})
          set(RUNJOB $ENV{BGQ_RUNJOB})
        else()
          set(RUNJOB runjob)
        endif()
        set(EXE_CMD ${RUNJOB} ${RUNJOB_NPF} ${REQUIRED_OPTION} ${MPIEXEC_PREFLAGS} : ${_testExe} ${_testArgs})
    else()
        set(MPIEXEC_NPF ${MPIEXEC_NUMPROC_FLAG} ${_numProc})
        set(EXE_CMD ${MPIEXEC} ${MPIEXEC_NPF} ${MPIEXEC_PREFLAGS} ${_testExe} ${_testArgs})
    endif()
    add_test(NAME ${_testName} COMMAND ${EXE_CMD})
    set_tests_properties(${_testName} PROPERTIES TIMEOUT ${_timeout})

endfunction(add_mpi_test)




