#!/bin/sh

usage()
{
    echo "The following environment variables can be set to influence this script:"
    echo "    BITS           32 or 64 (64 by default)"
    echo "    GIT_BRANCH     master, develop or a valid branch name (develop by default)"
    echo "    COMPILERS      list of compiler-binaries to use"
    echo "    COMPILER_FLAGS flags to append to the compiler calls"
    echo "    WITH_MEMCHECK  if set to anything but 0 CTEST will perform memchecks"
    echo "    WITH_COVERAGE  if set to anything but 0 CTEST will perform coverage checks"
    echo "    MODEL          Nightly, Experimental or Continuous (defaults to Experimental)"
    echo "    TMPDIR         place to store temporary files of run (will be pruned after"
    echo "                   run; defaults to /tmp)"
    echo "    TESTROOT        The place checkouts and builds take place (if unset defaults"
    echo "                   to TMPDIR, which means it will be pruned; otherwise it will "
    echo "                   be reused on next run)"
    echo "    THREADS       number of threads to use (defaults to 1)"
    echo ""
}

diagnostics()
{
    echo "NIGHTLY BUILD SCRIPT FOR SEQAN"   | tee    ${LOGFILE}
    echo ""                                 | tee -a ${LOGFILE}
    echo "Variables set to:"                | tee -a ${LOGFILE}
    echo " GIT_BRANCH:     $GIT_BRANCH"     | tee -a ${LOGFILE}
    echo " PLATFORM:       $PLATFORM"       | tee -a ${LOGFILE}
    echo " BITS:           $BITS"           | tee -a ${LOGFILE}
    echo " COMPILERS:      $COMPILERS"      | tee -a ${LOGFILE}
    echo " COMPILER_FLAGS: $COMPILER_FLAGS" | tee -a ${LOGFILE}
    echo " WITH_MEMCHECK:  $WITH_MEMCHECK"  | tee -a ${LOGFILE}
    echo " WITH_COVERAGE:  $WITH_COVERAGE"  | tee -a ${LOGFILE}
    echo " MODEL:          $MODEL"          | tee -a ${LOGFILE}
    echo ""
    echo " HOSTBITS:       $HOSTBITS"       | tee -a ${LOGFILE}
    echo " TMPDIR:         $TMPDIR"         | tee -a ${LOGFILE}
    echo " TESTROOT:       $TESTROOT"       | tee -a ${LOGFILE}
    echo " LOGFILE:        $LOGFILE"        | tee -a ${LOGFILE}
    echo " LOCKFILE:       $LOCKFILE"       | tee -a ${LOGFILE}
    echo " THREADS:        $THREADS"        | tee -a ${LOGFILE}
    echo ""                                 | tee -a ${LOGFILE}
}

dirs()
{
    mkdir -p "${TMPDIR}"
    ## create subdirectory in TMPDIR and redefine TMPDIR
    export TMPDIR=$(mktemp -d "${TMPDIR}/ctest.XXXXXXXX")

    ## make sure the others exist
    mkdir -p "${TESTROOT}"
    mkdir -p "${DIR}/../log"
}

lock()
{
    # this fails if "lockdir" already exists
    ! mkdir "$LOCKFILE"
}

cleanUP()
{
    rmdir  "$LOCKFILE" 2>/dev/null
    rm -rf "$TMPDIR"
}

_createTrap()
{
    trap cleanUP EXIT TERM INT KILL QUIT HUP SEGV PIPE
}
