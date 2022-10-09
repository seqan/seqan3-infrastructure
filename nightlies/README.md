## Setup

The directory containing the content of `files` will be your nightly_build directory.

```
/scratch/local/seiler/nightly-builds$ tree -L 2
.
├── nightly_compiler
│   ├── gcc # Needs checkout
│   ├── gcc-10-git # Needs configure
│   ├── gcc-11-git # Needs configure
│   ├── gcc-12-git # Needs configure
│   ├── gcc-git # Needs configure
│   └── wrapper # Needs correct filepaths
├── nightly_doxygen
│   ├── doxygen # Needs checkout
│   └── doxygen-git # Needs configure
├── seqan3
│   ├── build
│   ├── CTestCustom.cmake
│   ├── fix_skipped.cmake
│   ├── notesfile.txt
│   └── seqan3_nightly.cmake
├── nightly.sh # Needs correct filepaths
└── sharg
    ├── build
    ├── CTestCustom.cmake
    ├── fix_skipped.cmake
    ├── notesfile.txt
    └── sharg_nightly.cmake
```

### Git

Go to `nightly_compiler` and clone the GCC repository:
```
cd nightly_compiler
git clone https://github.com/gcc-mirror/gcc
```

Go to `nightly_doxygen` and clone the Doxygen repository:
```
cd ../nightly_doxygen # relative from nightly_compiler
git clone https://github.com/doxygen/doxygen
```

### File paths

Replace all occurences of `/scratch/local/seiler/nightly-builds` with your nightly build directory path.
Here is a list of affected files:
```
[...]seqan3-infrastructure/nightlies/files$ grep -lR "/scratch/local/seiler/nightly-builds"
nightly.sh
nightly_compiler/wrapper/g++-12-git
nightly_compiler/wrapper/g++-10-git
nightly_compiler/wrapper/gcc-11-git
nightly_compiler/wrapper/gcc-git
nightly_compiler/wrapper/g++-11-git
nightly_compiler/wrapper/gcc-10-git
nightly_compiler/wrapper/gcc-12-git
nightly_compiler/wrapper/g++-git
```

Reconfigure the temporary and ccache config in `nightly.sh`:
```
mkdir -p /dev/shm/seiler/ccache
mkdir -p /dev/shm/seiler/tmp

export TMPDIR=/dev/shm/seiler/tmp
export CCACHE_CONFIGPATH=/home/seiler/.ccache/ccache.conf
```

```
$ cat /home/seiler/.ccache/ccache.conf
max_size = 25.0G
cache_dir = /dev/shm/seiler/ccache
compression = true
compression_level = 12
absolute_paths_in_stderr = true
base_dir = /scratch/local/seiler/nightly-builds
```

### CDash Authorization Header

Replace `TODO_SET` in `HTTPHEADER "Authorization: Bearer TODO_SET"` in the files `seqan3_nightly.cmake` and
`sharg_nightly.cmake` with the proper token (can be created/looked up at https://seqan.cdash.de).

### Configure GCC

```
set -e
cd nightly_compiler
for compiler in "-10" "-11" "-12" ""; do
    if [ "$compiler" = "" ]; then
        branch="master"
    else
        branch="releases/gcc${compiler}"
    fi

    cd gcc
    git fetch -u
    git checkout --force $branch
    rm -fdr gmp* isl* mpc* mpfr*
    ./contrib/download_prerequisites

    cd ../gcc${compiler}-git
    ../gcc/configure \
        --prefix=$(pwd) \
        --disable-multilib \
        --program-suffix=${compiler}-git \
        --disable-bootstrap \
        --disable-werror \
        --enable-languages=c,c++,lto \
        --no-create \
        --no-recursion

    cd ..
done
set +e
```

### Configure Doxygen

```
set -e
cd nightly_doxygen
cd doxygen-git
cmake ../doxygen
set +e
```

### Configure cron

```
crontab -e
```
Content:
```
CRON_TZ=Europe/Berlin
1 2 * * * <ABSOLUTE_PATH_TO>/nightly.sh
```
Replace `<ABSOLUTE_PATH_TO>` with your full path to the nightly build directory.

### Log files

The nightlies create logfiles that will be uploaded (see `nightly.sh`). This feature needs the presents of a suitable
ssh-key.

## Failures

In general, CDash will show failures and the log files are available for download.
If suddenly no builds were submitted, the re-building of the compilers may have failed.
The nightlies stop if any compiler could not be built.
