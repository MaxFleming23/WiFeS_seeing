

```
export DYLD_LIBRARY_PATH=/opt/homebrew/lib
export LDFLAGS="-L/opt/homebrew/lib"
export CFLAGS="-I/opt/homebrew/include"
```

```
export CPATH=/opt/homebrew/include
export LIBRARY_PATH=/opt/homebrew/lib
export LIBRARY_PATH=/library/developer/commandlinetools/sdks/macosx.sdk/usr/lib
```

```
./configure --with-atlas-libdir="/Users/astqx/Desktop/ANU - 2023 S2/DREAMS/numerics/ATLAS3.10.3/lib" --with-atlas-incdir="/Users/astqx/Desktop/ANU - 2023 S2/DREAMS/numerics/ATLAS3.10.3/include"
```

sextractor 

```
llvm
If you need to have llvm first in your PATH, run:
  echo 'export PATH="/opt/homebrew/opt/llvm/bin:$PATH"' >> ~/.zshrc

For compilers to find llvm you may need to set:
  export LDFLAGS="-L/opt/homebrew/opt/llvm/lib"
  export CPPFLAGS="-I/opt/homebrew/opt/llvm/include"
```

```
../configure  --with-netlib-lapack-tarfile="/Users/astqx/Desktop/DREAMS/lapack-3.11.tar.gz" -Ss kern /opt/homebrew/opt/llvm/bin/clang -C gc /opt/homebrew/opt/llvm/bin/clang -Fa gc '-masm=intel'
../configure  --with-netlib-lapack-tarfile="/Users/astqx/Desktop/DREAMS/lapack-3.11.tar.gz" -Ss kern /usr/bin/gcc -C gc /usr/bin/gcc
```

# Installing dependencies

## Sextractor

- available on `homebrew` but relevant sub packages needed by other dependencies 

### FFTW

- `pyfftw` (FFT) install failed - follow https://github.com/pyFFTW/pyFFTW
    - `pyfftw3` python2 print statement?
    - works with conda (not used) - used later
    - works with macports? - no

- installed with `homebrew` - fftw3.h found in homebrew/include

### ATLAS
conda 
- `macports` - ? does not complete
- `homebrew` - old/does not exist
- manual installation - ? can not interpret intel asm files with `clang+llvm`
                      - manual override section empty 
                      - 32-bit? apple silicon can not run it
- `conda` - package exists (? .conda not .tar.bz), can not find it (even with suggested label)

run Rosetta 2 terminal
```
/usr/bin/arch -arch x86_64 /bin/zsh
```
(https://stackoverflow.com/a/70222469/14094985)

single threaded attempt - ? didn't matter

modified conditions in `/ATLAS3.10.3/CONFIG/src/probe_comp.c` (call caught in log) to prevent error: call to undeclared function
- CompIsClang
- CompIsMinGW
Actual fix not discovered yet

clang, `error: unknown FP unit 'sse' M1` - ? cause SSE2, used flag `-Si nocygwin 1` fixed to SSE3 (unsure why)
- not sure if `M1` was a part of the message

```
Cannot find MinGW gcc in /usr/bin, with names beginning with
/usr/bin/x86_64-w64-mingw32-* ; Make sure MinGW is installed, then try again.
If your MinGW compiler not named like this, specify them using file
...
make[1]: *** [atlas_run] Error 255
make: *** [IRun_comp] Error 2
ERROR 512 IN SYSCMND: 'make IRun_comp args="-v 0 -o atlconf.txt -O 12 -A 29 -Si nof77 1 -V 896  -C gc '/opt/homebrew/opt/llvm/bin/clang' -b 64 -Si nocygwin 1"'
```

installed `mingw-w64` (? cross compiler) using `homebrew`
- located at `/opt/homebrew/bin` but looking in `/usr/bin`
- `/usr/bin` is write protected by System Integrity Protection. Need to turn off a security feature to get access (https://superuser.com/a/1363080)
    <blockquote>
    In general, the best answer is: don't. Changing things in the protected directories may break parts of the OS that use them. Local customizations belong in /usr/local rather than the main hierarchy, and /usr/local/bin is already in the default PATH (and before /usr/bin and /bin, so commands there will be used in preference to the builtins). Just put the modified script there, and it should work for most purposes.

    If you do need to make mods in /usr/bin, you can turn off filesystem protection by restarting in recovery mode, and running the command:

    csrutil enable --without fs
    ...then restart normally, do the changes, then restart in recovery again, run csrutil enable, and restart again. See Rich Trouton's blog for way more information.
    </blockquote>

- ```
  If your MinGW compiler not named like this, specify them using file
  ```
  incomplete message - no `configure` flag to specify this or other mention in the documentation

- Found the lines used for searching the location in `/ATLAS3.10.3/CONFIG/src/probe_comp.c` and updated it to the actual location of the compiler files. This case found in `/opt/homebrew/Cellar/mingw-w64/11.0.1/bin` (this is the real location `/opt/homebrew/bin` is a link)
  ```
  const char *pref = (ptrbits == 64) ? "/opt/homebrew/Cellar/mingw-w64/11.0.1/bin/x86_64-w64-mingw32-" : 
                                       "/opt/homebrew/Cellar/mingw-w64/11.0.1/bin/i686-w64-mingw32-";
  ```

New error!
```
/bin/sh: line 1: 14391 Illegal instruction: 4  ./xprobe_comp -v 0 -o atlconf.txt -O 12 -A 29 -Si nof77 1 -V 896 -C sm '/opt/homebrew/opt/llvm/bin/clang' -C dm '/opt/homebrew/opt/llvm/bin/clang' -C sk '/opt/homebrew/opt/llvm/bin/clang' -C dk '/opt/homebrew/opt/llvm/bin/clang' -C xc '/opt/homebrew/opt/llvm/bin/clang' -C gc '/opt/homebrew/opt/llvm/bin/clang' -b 64 -Si nocygwin 1 -d b /Users/astqx/Desktop/DREAMS/numerics/ATLAS3.10.3/build2 > config1.out
make[1]: *** [atlas_run] Error 132
make: *** [IRun_comp] Error 2
ERROR 512 IN SYSCMND: 'make IRun_comp args="-v 0 -o atlconf.txt -O 12 -A 29 -Si nof77 1 -V 896  -C sm '/opt/homebrew/opt/llvm/bin/clang' -C dm '/opt/homebrew/opt/llvm/bin/clang' -C sk '/opt/homebrew/opt/llvm/bin/clang' -C dk '/opt/homebrew/opt/llvm/bin/clang' -C xc '/opt/homebrew/opt/llvm/bin/clang' -C gc '/opt/homebrew/opt/llvm/bin/clang' -b 64 -Si nocygwin 1"'
```

- minimal command with the same error `../configure -Si nocygwin 1`
 
❌ **Abandoned** - wasted almost a day :( 

### OpenBLAS

- precompiled installed using `conda`, missing `LAPACKE_dpotrf`
- source compilation instructions: https://github.com/OpenMathLib/OpenBLAS/wiki/Installation-Guide
  - error: library not found for -lSystem
  - attempt with gcc compiler instead of cc - didn't matter
  - correct the library source 
    ```
    export LIBRARY_PATH=/library/developer/commandlinetools/sdks/macosx.sdk/usr/lib
    ```

    build command:
    ```
    make CC=cc FC=/opt/homebrew/Cellar/gcc/13.2.0/bin/aarch64-apple-darwin23-gfortran-13
    ```

    success:
    ```
    OpenBLAS build complete. (BLAS CBLAS LAPACK LAPACKE)

    OS               ... Darwin             
    Architecture     ... arm64               
    BINARY           ... 64bit                 
    C compiler       ... CLANG  (cmd & version : Apple clang version 14.0.3 (clang-1403.0.22.14.1))
    Fortran compiler ... GFORTRAN  (cmd & version : GNU Fortran (Homebrew GCC 13.2.0) 13.2.0)
    -n   Library Name     ... libopenblas_vortexp-r0.3.25.a
    (Multi-threading; Max num-threads is 8)
    ```

### CFITSIO

- `homebrew`: `brew install cfitsio`
- specify the location (homebrew) using flags

### Building 

- command from documentation: `make -j`
- error with `finite()` call: `undeclared library function`
  ```
    Making all in levmar
    gcc -DHAVE_CONFIG_H -I. -I../..     -g -O2 -MT lmbc.o -MD -MP -MF .deps/lmbc.Tpo -c -o lmbc.o lmbc.c
    gcc -DHAVE_CONFIG_H -I. -I../..     -g -O2 -MT lm.o -MD -MP -MF .deps/lm.Tpo -c -o lm.o lm.c
    In file included from lm.c:81:
    ./lm_core.c:206:7: error: call to undeclared library function 'finite' with type 'int (double)'; ISO C99 and later do not support implicit function declarations [-Wimplicit-function-declaration]
    if(!LM_FINITE(p_eL2)) stop=7;
    ^
    ./compiler.h:63:19: note: expanded from macro 'LM_FINITE'
    #define LM_FINITE finite // ICC, GCC
                ^
    ./lm_core.c:206:7: note: include the header <math.h> or explicitly provide a declaration for 'finite'
    ./compiler.h:63:19: note: expanded from macro 'LM_FINITE'
    #define LM_FINITE finite // ICC, GCC
                ^
    In file included from lmbc.c:84:
    ./lmbc_core.c:324:13: error: call to undeclared library function 'finite' with type 'int (double)'; ISO C99 and later do not support implicit function declarations [-Wimplicit-function-declaration]
            if (!LM_FINITE(fpls)) {
                ^
    ./compiler.h:63:19: note: expanded from macro 'LM_FINITE'
    #define LM_FINITE finite // ICC, GCC
                ^
    ./lmbc_core.c:324:13: note: include the header <math.h> or explicitly provide a declaration for 'finite'
    ./compiler.h:63:19: note: expanded from macro 'LM_FINITE'
    #define LM_FINITE finite // ICC, GCC
                ^
    1 error generated.
    1 error generated.
    make[3]: *** [lm.o] Error 1
  ```
- linked to building `levmar` (math package)
- found: `/sextractor/src/levmar`
- tried flags `-framework accelerate` (Apple) and `-lm` (math) to `gcc` in Makefile - no success
- fixed by changing `#define LM_FINITE finite // ICC, GCC` to `#define LM_FINITE isfinite // ICC, GCC` as suggested https://zhuanlan.zhihu.com/p/621464953.
- loading success
- Note: flag `-framework accelerate` retained, not checked if any impact on removal

```
LD = /Library/Developer/CommandLineTools/usr/bin/ld
```

## SCAMP

### PlPlot

- `homebrew`: `brew install plplot`
- path with flags
- flawless configure :)
- flawless build :)
- flawless install :) 
- loading error:
  ```
  dyld[61681]: Library not loaded: ./openblas/lib/libopenblas.0.dylib
  Referenced from: <5EB89180-CCA8-323B-8670-3F31EACB59A0> /usr/local/bin/scamp
  Reason: tried: './openblas/lib/libopenblas.0.dylib' (no such file), '/System/Volumes/Preboot/Cryptexes/OS./openblas/lib/libopenblas.0.dylib' (no such file), './openblas/lib/libopenblas.0.dylib' (no such file), '/usr/local/lib/libopenblas.0.dylib' (no such file), '/usr/lib/libopenblas.0.dylib' (no such file, not in dyld cache)
  ```
  - fixed by creating `/usr/local/lib` folder and adding `/openblas/lib/libopenblas.0.dylib` file from the manual build (link and the original)

## SWARP

- recent documentation not found (https://www.astromatic.net/pubsvn/software/swarp/trunk/doc/swarp.pdf)
- pdf documentation (https://raw.githubusercontent.com/astromatic/swarp/legacy_doc/prevdoc/swarp.pdf)
- downloaded from GitHub release 
- flawless configure :)
- flawless build :)
- flawless install :)
- loading success


## PSFEx

- downloaded from GitHub release 
- flawless configure :)
- build: `error: call to undeclared library function 'finite'` in `Making all in levmar`
  - same fix as in sextractor
  - confirmed just the change from `finite` to `isfinitie` is enough (accelerate -framework flag not needed)
- flawless install :)
- loading success

## Astrometry.net 

- `homebrew`: `brew install astrometry-net`
- !TODO (done): download index files and place in `/opt/homebrew/Cellar/astrometry-net/0.94_3/data`
  - for downloading entire folder: `brew install lftp` (https://stackoverflow.com/a/61796867/14094985)
    ```
    lftp -c 'mirror --parallel=100 --use-pget-n=10 https://portal.nersc.gov/project/cosmo/temp/dstn/index-5200/LITE/ ;exit'
    ```

## PostgreSQL       

- `homebrew`: `brew install postgresql@16`
  ```
    This formula has created a default database cluster with:
    initdb --locale=C -E UTF-8 /opt/homebrew/var/postgresql@16
    For more details, read:
    https://www.postgresql.org/docs/16/app-initdb.html

    postgresql@16 is keg-only, which means it was not symlinked into /opt/homebrew,
    because this is an alternate version of another formula.

    If you need to have postgresql@16 first in your PATH, run:
    echo 'export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"' >> ~/.zshrc

    For compilers to find postgresql@16 you may need to set:
    export LDFLAGS="-L/opt/homebrew/opt/postgresql@16/lib"
    export CPPFLAGS="-I/opt/homebrew/opt/postgresql@16/include"

    For pkg-config to find postgresql@16 you may need to set:
    export PKG_CONFIG_PATH="/opt/homebrew/opt/postgresql@16/lib/pkgconfig"

    To start postgresql@16 now and restart at login:
    brew services start postgresql@16
    Or, if you don't want/need a background service you can just run:
    LC_ALL="C" /opt/homebrew/opt/postgresql@16/bin/postgres -D /opt/homebrew/var/postgresql@16
  ```

# Testing 

```
Found 1 counts of error AstrometrySourceError, affecting 1 images: 
  File "/Users/astqx/Desktop/DREAMS/mirar/mirar/processors/astrometry/autoastrometry/detect.py", line 189, in get_img_src_list.
 
Found 1 counts of error RemoteDisconnected, affecting 2 images: 
  File "/Users/astqx/miniconda3/envs/mirar/lib/python3.11/http/client.py", line 287, in _read_status.
```

Accidentally put calibration files in raw

```
Found 1 counts of error AstrometryReferenceError, affecting 7 images: 
  File "/Users/astqx/Desktop/DREAMS/mirar/mirar/processors/astrometry/autoastrometry/reference.py", line 293, in get_ref_sources_from_catalog_astroquery.
```

`/pipelines/wirc/load_wirc_image.py`
```
    if header["OBJECT"] in ["acquisition", "pointing", "focus", "none"]:
        header[OBSCLASS_KEY] = header["OBJECT"]
    else:
        header[OBSCLASS_KEY] = "science"
```
changes `dark` to `science`?

mirar.data.cache hard disable - NO

dark calibration
```
called: select_from_images
batch: <An ImageBatch object, containing []>
```

Test files (`winterdrp`)
- Dark 
  ```
  load,csvlog,mask,select,
  ```
- Flat
  ```
  load,csvlog,mask,select,dark,debatch,select,batch,
  ```
- Sky 
  ```
  load,csvlog,mask,select,dark,debatch,select,batch,flat,
  ```

calibrations from a different pipeline

Installing `PyRegions` to plot regions 
```
export LIBRARY_PATH=/opt/homebrew/lib
export CC=cc
pip install --no-deps pyregion
```

header change from `wcs` to `fk5` (frmae) for `astropy` conversion, in
```
/wirc/20210330/phot/image0092_stack.fitscleaned_img.reg
```
later note - other `.reg` had `image` as the frame which worked straightaway.

`matplotlib`/`ipython` broke?
```
pip install matplotlib --force
```

plotting in world coordiates - https://docs.astropy.org/en/stable/visualization/wcsaxes/

SCOR test within 2 decimals
```
assertAlmostEqual(value, header[key], places=2)
```
```
SCORMEAN expected: -0.04392849749015427
            found: -0.0439284742002671
```

Starting `conda`
```
conda init zsh 
conda activate ...
```

sextractor location does not line up (or mutually present in both sci and ref) so not considered as a source `sex_can_vs_not.png` [nvm changing the contrast made it apparent that it is centered and exists in both]

## Candidate detection

## Cross matching 

VizieR (https://vizier.cds.unistra.fr/viz-bin/VizieR)

```
'DB_USER': 'postgres',
'DB_PWD': ''
```

```
ALTER ROLE "postgres" WITH LOGIN;
ALTER ROLE postgres WITH CREATEDB;
ALTER USER postgres WITH SUPERUSER;
```

```
NotSupportedError: (psycopg.errors.FeatureNotSupported) extension "q3c" is not available
```

Installing `q3c`

```
prepare.c:23:10: fatal error: 'stdlib.h' file not found
   23 | #include <stdlib.h>
      |          ^~~~~~~~~~
1 error generated.
```

found: `/opt/homebrew/Cellar/gcc/13.2.0/include/c++/13/stdlib.h`
NO, use: `/opt/homebrew/Cellar/llvm/17.0.5/include/c++/v1/stdlib.h` with `clang`

```
export C_INCLUDE_PATH=/opt/homebrew/Cellar/llvm/17.0.5/include/c++/v1
```

```
clang: warning: no such sysroot directory: '/Library/Developer/CommandLineTools/SDKs/MacOSX14.sdk' [-Wmissing-sysroot]
```
create link (https://stackoverflow.com/a/66245713/14094985)
```
sudo ln -s /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX14.sdk /Library/Developer/CommandLineTools/SDKs/MacOSX14.sdk
```
Did not fix*

FIXED! - link the right SDK
```
sudo ln -s /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk /Library/Developer/CommandLineTools/SDKs/MacOSX14.sdk 
```
after installation 
```
psql postgres
CREATE EXTENSION q3c
```

# Tests

## test1

- Test the pipeline from scratch in a new location 
- needed to run twice for reduction
  ```
  DEBUG:mirar.catalog.gaia:Querying 2MASS - Gaia cross-match around RA 160.6055, Dec 34.4015 with a radius of 10.0000 arcmin
  DEBUG:mirar.catalog.gaia:Found 90 sources in Gaia
  DEBUG:mirar.catalog.gaia:Adding 0.89 to convert from 2MASS to AB magnitudes
  DEBUG:mirar.catalog.base_catalog:Saving catalog to /Users/astqx/Desktop/DREAMS/test/pipeline/test2/wirc/night/phot/image0092_stack.tmass.cat
  DEBUG:mirar.paths:Copying from /Users/astqx/Desktop/DREAMS/test/pipeline/test2/wirc/night/final_sextractor/image0092_stack.cat to /Users/astqx/Desktop/DREAMS/test/pipeline/test2/wirc/night/phot/temp_image0092_stack.cat
  DEBUG:mirar.data.utils.coords:Writing regions path to /Users/astqx/Desktop/DREAMS/test/pipeline/test2/wirc/night/phot/image0092_stack.fitsref.reg
  DEBUG:mirar.data.utils.coords:Writing regions path to /Users/astqx/Desktop/DREAMS/test/pipeline/test2/wirc/night/phot/image0092_stack.fitscleaned_img.reg
  DEBUG:mirar.data.utils.coords:Writing regions path to /Users/astqx/Desktop/DREAMS/test/pipeline/test2/wirc/night/phot/image0092_stack.fitsimg.reg
  DEBUG:mirar.processors.base_processor:Deleted temporary file /Users/astqx/Desktop/DREAMS/test/pipeline/test2/wirc/night/phot/temp_image0092_stack.cat
  DEBUG:mirar.processors.photcal:Found 13 clean sources in image.
  DEBUG:mirar.processors.base_processor:Cross-matching 63 sources in catalog to 13 image with radius 1.0 arcsec.
  DEBUG:mirar.processors.base_processor:Cross-matched 0 sources from catalog to the image.
  DEBUG:mirar.processors.photcal:Cross-matched 0 sources from catalog to the image.
  ERROR:mirar.processors.photcal:Not enough cross-matched sources found to calculate a reliable zeropoint. Only found 0 crossmatches, while 5 are required. Used 63 reference sources and 13 image sources.
  ERROR:mirar.processors.base_processor:Error for processor mirar.processors.photcal at time 2023-12-12 10:10:02.404398 UT: PhotometryCrossMatchError affected batch of length 1. This error was a known error raised by mirar.. 
  ```
  ```
  PhotometryCrossMatchError: Not enough cross-matched sources found to calculate a reliable zeropoint.
  ```
- 

## test2

- use result from `final` instead of `stack` for imsub 
- and `wirc_reference_generator` instead of `wirc_test_reference_generator`
- same twice for reduction 
- region file is not complete, ie, consistent with candidates.pkl


## test3 

- edge masking + usiing final
- ! does not exist

## test4

- ```
  PhotometryCrossMatchError: Not enough cross-matched sources found to calculate a reliable zeropoint. Only found 0 crossmatches, while 5 are required. Used 63 reference sources and 13 image sources.
  ```
  in all tests - works on second run [!?FIX]
- restart DB server when load is slow
  ```
  brew services restart postgresql@16
  ```
- `PhotCalibrator` does not use standard `WriteRegions`, does it internally instead, so the crossmatched sources or the regions are not written. [!CHECK]
- ? kernel restart on config change - NO I'm dumb :) (changed the wrong config)
- photometry is done after subtraction
- [!CHECK] `base_catalog_xmatch_processor/get_sextractor_apertures`

## test 5 

Using provided sky and flat frames

## test 6


# PSF Photometry 

- `stdpsf_reader(filename[, detector_id])`
  Generate a GriddedPSFModel from a STScI standard-format ePSF (STDPSF) FITS file
  
- `webbpsf_reader(filename)`
  Generate a GriddedPSFModel from a WebbPSF FITS file containing a PSF grid.
  - ? does not exist
  
- > it is hard to do high-accuracy PSF analysis on the drizzle product
  (https://www.stsci.edu/hst/instrumentation/wfc3/data-analysis/psf)

- Zoggy for PSF (psfex)
  - different for each source? - YES - maybe not
  - access how? -  
  - [!CHECK] is the final image background corrected? does PSF photometry need local background correction?
  - 

# Flat correction and sky subtraction

- `header["FILTER"] = header["AFT"].split("__")[0]` and uses `header["FILTER"] = 'object'` later to look for sky
- `DEBUG:mirar.processors.flat:Median combining 7 flats` flat calibration maybe wrong
- `flat_mask_key: str = None` reason for taking all images as being suitable?
- what?
  > Function to match a new wirc image to a reference image directory
- 

# Notes to self

- check the source for congig call that suggested --enable-openblas as backup 
- find github issue that moved from atlas to openblas
- define edge detections 

Automatically Tuned Linear Algebra Software

## Fix ipympl issues 
https://github.com/matplotlib/ipympl

## Report 

- Check proposal (Tony's email)
  - Survay and cadence 
  - mass estimation
- Entire pipleline description (check Gattini's paper)
- Time domain astronomy
  - /sky monitoring (existing stars to we know exactly when it went SNe)
  - importance and use/science cases for different transient objects
  - maybe talk a little more about SNe
  - why infrared important 
- Remmeber what Tony mentioned (if not ask him tomorrow)
- PSF and aperture photometry (and why need both)
- Zoggy sex, psfext, sex ? (some combination, as a part of the pipeliine)
- Calibration frames, compare to spectrograph (WiFeS)
  - General CCD information too
- Current pipeline photometry done after image subtraction and detection, maybe all-sky in the future 
- PhoSim (? Trevor - monte carlo photon simulation) and ScopeSim (used by some ELT instruments like MICADO) - Use simulated data to best understand the difference, cadidate and photometric imformation outputed by the pipeline. Simulated to DREAMS.
- Build the enitre reduction pipeline for DREAMS using/to run the simulated data through (inc. all internal files.)
- Find a title haha
- sim for faint as can't be certified from ground based observations 
- salvage presentation slide ideas
- DREAMS hardware details and design choices (motivate)
  - spectral coverage and filters
- add sex detection images from the paper (maybe)
- report all your finidings (check all notes to makes sure) [don't foregt sex and zoggy papers]
- read the paper on sex so you can mention some stuff also in comparision to photutis
- explain where/what photutils or starlet (or others) can replace
- IR mapping good?
- is mentioning everything you learned too detailed? (or even the summary of it)
- compare different subtraction results from reduced data and provided stack
- shoud have started writing the report early and update as you go [lesson learned]
- ML classification and human vetting
- meridian flip
- challenges
- plot some internal files under `wirc/wirc_files`
- scarlet and future
- conclusion detailing things for further investigation
- photometry and kind of objects
- edge candidates
- streaks (satelite)
- multi-messenger
- what past survays have done 
- what differentiates dreams from others
- old, optical too stretched
- multimessenger and importance of photometry
- SNe
- signal to noise
- IR and what my research will be helping
- Simluation** and its need and importance to this research
- Testing structure when the pipeline for DREAMS is built could be based on what I have so far
- read something about polarisation somewhere
- magnitues and equations 
- goodness of PSF fit
- does exp time matter in photometry?
- an important change happens to be the brightness
- so it is important to have a robust pipeline to perform acurate photometry
- photometry on corrected individual exposure vs. stacked
- internal digging needs to be done
- historical evolution of photometry 
- absolute photometry
- theoretical difference between default and photutils
- different but how different
- intergalactic extiction under anotehr subsection?
- super resolution (qunatum) (anu resphy research)
- all-sky montoring needs good photometry
- dependence of PSF on apperture
- why bother to look for another implementation
- brigntness happens to be one of those things and we need to quantify it 
- moon (maybe in the pipeline as a quality cut)
- binning to reduce noise
- FOV
- bigger scince goal as mentioned by tony (finding supernovae and understanding the universe)
- resampling to help photometry
- zodiacal light
- photocal vs photometry
- filter to fight light pollution
- zero points and mag
- finite pixel resolution of the detector
- dither
- telescopic and effective psf (!check)
- soruces of uncertainity
- psf important for transients as they are point sources
- psf normalization
- use real psf to show brigtness-size comprision (later)
- extinction correction
- For point sources, we combine dithered p , images to get sky frames (!check, from ppt)
- apperture correction vs. normalization
- check the output of photocal
- difference imaging is another method
- daophot
- check what flags are in the source table and where they come from
- tophat psf = aperture photometry
- adu positive due to unwanted 
- apperture size and noise can not be subtracted
- curve of growth correction (faint stars ? setting the limit for the aperture size)
- aperture correction to account for the different sized appertures for the target and reference star
- psf subtraction before proceeding futher and recompute the sky to get a better reading
- adaptive optics
- `photutis` fractional
- a little bit about CMOS instead of CCD (NO)
- is vingetting a type of speherical aberation 

Checks removed from the draft [not followed beyond the first few points, the rest are general notes]
- (!confirm if there is a dependence on aperture shape)
- apperture normalization
- supersampling in psf
- (blue wavelengths are absorbed and scattered more than the red)
- (the intensity of light is reduced)
- frame overlap and similar calibration based on one frame
- bias corrections in MIRAR
- images with in the pipeline section along the steps
- check the database (portridgeSQL)
- polarimetry
- ccd equation and noise
- number of bias, flat, sky (or other calibration) frames needed and its effects (need for a master frame)
- more on filter response cuves (website trevor shared) and calculation of atmospheric extinction, etc
- transformation coefficients
- is centroiding important for centering or calculating the shift in psf fitting
- check existing photometry (methods) comparision papers
- WIRC pipeline - test pipeline hereafter
- confusion limited 
- absolute error map
- grizy filter
- convolution performed in astrometric configuration of sex call (WINTER)
- motivate deblending based on dark energy survey (check the challenges in general to increase motivation) [check the `scarlet` paper]
- above ^ and a little more on scarlet
- extinction correction for absolute phot [?check]
- psf convolved for psf fitting (portolio paper)
- photometic cal retained if using similarly processed dithers (the Rubin youtube video)
- transient activity not affected by crowdedness
- !! PHOTOCAL
- simulation frist then implement so we can compare and sim doesn't need to fit the entire pipeline, just needs to be enough to benchmark the photometric reults
- improve the introduction
- read all the points here
- include sample simulation using ScopeSim
- real time and data release
- neural network galaxy star separation (better than `scarlet`)
- gain
- linearlized field debledning

## Terms

- Survay data
- qulaity cuts

## to check 

- galaxy catalog
- connected contiguous 
- isophotal
- Kron's first moment algorithm
- what Zoggy uses for PSF estimation and photometry
- ? (I came up with it) median normalized (check if exists/meaning)
- segmentation in `sex`
- `plotfilename` to save the ouptut
- is zoggy doing photometry?
- Image photometry (not source) check what
- overscan under dark frame
- check if sex detection ellipse can be saved/plotted
- keep the log files ready to show Tony the default inital flat calibration 
- zoggy vs sex psf
- move corrections section to the pipeline section to avoid repetition
- mirar manually calulating error and background and just using `photutils.aperture_photometry` for aperture count? they also make a background mask but do not use it 
- detail the `sex` configurations in the flow diagram
- linear deblend
- push S/N up to the third subsection
- when to use image convolved with psf (check some paper mentioned it)


## to do 

- sync vscode to overleaf? 


# Trash 

block old
```
header_annotator = [
    ImageSaver(output_dir_name="darkcal"),
    HeaderAnnotator(input_keys=LATEST_SAVE_KEY, output_key=RAW_IMG_KEY),
    ImageDebatcher()
]

skyflat_calibration = [
    ImageSelector((OBSCLASS_KEY, "science")),
    # ImageSelector(("object", "ZTF18aavqmki")),
    ImageBatcher(split_key=["filter", "object"]),
    SkyFlatCalibrator()
] 
```

# Report Draft

## Testing pipeline and parameters

Once we have our calibrated simulated test images, out first test pipeline will be the one under 'Image Photometry', that uses defaut implementations in `mirar`.

Sextractor parameters and configuration files will be borrwoed from the WIRC pipeline to begin with and will be modified as required.

Impacting parameters

Stage 1: Understanding `mirar` and `photutils` (difference imaging)

Difference imaging photometry uisng the WIRC pipeline but with modules from `photutils`.

Stage 2: Various pipelines in `mirar` and `photutils` (all sources)

(a) Background estimation - `Sextractor` vs. `NightSkyMedian` (and the long procedure)
(b) Source detection - `Sextractor`
(c) Deblending - `Sextractor`
(d) PSF extraction - `PSFEx`
-- `photutils` without cutouts? --
(e) PSF photometry - `mirar` vs. `photutils`
(f) Apperture photometry - `mirar` (already uses `photutils`) vs. `photutils`

  what is not considered/assumed
  - Spatial variability of PSF and the need to split the image
  - perfect astrometry
  - photometric calibration
  - 

Stage 3: `SCARLET`

## Simulations

- clear discription for each simulation set (check `scopesim`) - max hour on this
- sources (distribution) convolved with PSF

-- pipeline benchmark at the end -- 
## Comparative analysis (or) quantifying performance

- overall and photometry: 
  - relative flux error (obs-true)/true (plot with all sources)
  - find a metric to quantify accuracy (if not the above)
- background: 
- deblending: not tested in stage 2 as only `sex` 
  - maybe test with `SCARLET` in stage 3
- psf extraction: not teseted inividually as only `PSFEx` (enough sources to model psf?)
- photometry: compare resutls from PSF and apperture based on relative and comparitive flux errors
- timing: 
  - ratio to eliminate platform varience
  - multiple runs to account for system performance variablity

**different pipelines based on the science observation, types and density of sources (crowded/galaxy/etc) and the effect of sky (probably not useful (the sky part))**

### Accuracy
- flux or mag

### Error spread

### Time (and complexity? bit too much)

What's a good real time pipeline?
- Time 

What's a good data release pipeline?
- Accuracy

We present a primitive approach for now, this may be improved as we contiune to develop better methods of analysis.


and we make the follwoing assumpions and considerations: (not be focusing on)

----- maybe into the report -----

(a) The input data is flat-fielded and not affected by bias and dark
(b) The astrometry 
(c) photometric calibration

Difference imaging photometry (? not mine)

----- into the report -----

# Image photometry

<!-- ## Testing pipeline and parameters -->
## Testing procedure

The test pipelines will involve the following operations:

(a) Background estimation (and subtraction)

(b) Source detection (includes deblending)

(c) PSF extraction

(d) PSF photometry

(e) Aperture photometry

The results will be compared as follows:

|Component|Methedologies|
|:---:|:---:|
|Photometry ($p$)|Relative flux error (accuracy)|
|Phot. error ($e$)|Uncertainity|
|Phot. difference ($d$)|PSF fitting vs. aperture (rel. comp.) (variance)|
|Background|Residual map (?)|
|Source detection|TBD in stage 3|
|PSF extraction|[not planned]|
|Computation time ($t$)||

For initial testing, we will exculude the background, source detection and PSF extraction as The overall score of a pipeline can be determined by appropriately weighing the parameters:
<!-- For initial testing we will use the follwoing scheme: -->

$$
S_P = \alpha(p) + \beta(t) + \gamma(e) + + \delta(d)
$$

where $\alpha$, $\beta$, $\gamma$ and $\delta$ are the weights between 0 and 1 of the respective parameters.

systematic errors

relaive error between 5 and 95 percentile of data

acceptable relative error

what about resampling and stacking?

<!-- the photometry ($p$), computation time ($t$) and photometric difference using PSF fitting and aperture photometry ($d$) parameters, respectively. -->




# Phomertry test pipeline 

## Config files 

### SExtractor

### PSFEx

- `photom.config`: [diff](_notes_files/psfex_config_winter_wirc.html)
- `photomCat.sex`: [diff](_notes_files/sex_photomCat_winter_wirc.html)
- `photom.param`: same
- `default.conv`: same
- `default.nnw`: same
- `astrom.sex`: [diff](_notes_files/sex_astrom_winter_wirc.html)
- `astrom.param`: [diff](_notes_files/astrom_param_winter_wirc.html)
- `Scorr.param`

## Thooughts 

- dynamic config files


## Critical errors

- `sex` adds wrong SAVEPATH key to be of the temporary mask not the actual image
- incorrect cutout 
  ```
  DEBUG:mirar.processors.photometry.utils:making cutout at (2,81) with shape (100, 100) - nothing
  DEBUG:mirar.processors.photometry.utils:making cutout at (38,17) with shape (100, 100) - incorrect shape
  ```
  ```
  ValueError: operands could not be broadcast together with shapes (41,41) (41,0) 
  ```
- ```
  DEBUG:mirar.processors.photometry.utils:making cutout at (96,54) of image with shape (100, 100)
  INFO:mirar.processors.photometry.utils:Cutout parameters are 75, 76, 117,100,100
  ```
  ```
  DEBUG:mirar.processors.photometry.utils:making cutout at (2,81) of image with shape (100, 100)
  INFO:mirar.processors.photometry.utils:Cutout parameters are 102, -18, 23,100,100
  ```

  - disaster in `utils.py`
    - y-h < 0 and x-h < 0 (bottom left)
      `SourceDetector`
      ```
      DEBUG:mirar.processors.photometry.utils:making cutout at (39,18) of image with shape (100, 100)
      DEBUG:mirar.processors.photometry.utils:x+h = 79,x-h = -1,y+h = 58,y-h = -22
      ```
    - x-h < 0 and y+h > img - (top left)
      `PSFPhotometry`
      ```
      DEBUG:mirar.processors.photometry.utils:making cutout at (2,81) of image with shape (100, 100)
      DEBUG:mirar.processors.photometry.utils:x+h = 22,x-h = -18,y+h = 101,y-h = 61
      ```
    - bottom left: `/_images/img_base+noise_poiss+noise_gauss_(119, 198)_(2,81).fits`
    - x+h > img - works

  - fixed [complete]
    - top left: `/detection/img_base+noise_poiss+noise_gauss_embedded_cutout_5.0.fits`
    - bottom left: `/detection/img_base+noise_poiss+noise_gauss_embedded_cutout_2.0.fits`
    - top right: added

testing notes:
  - include errors in position and theta measurements
  - y-axis is where angle is measured from (of major axis) -> -ve is clockwise
    - so the major axis needs to be along the y-axis before rotation [WRONG]
  - `Ellipse` draws major axis along y but [think] it is meant to be from x acc. to `sex` [NEEDCONF]
    - co2d hostrrected [CHECK] with theta-90
  - formalize (normalize) cutouts (sizes) like `/test/pipeline/phot/test_moffat_0/results/det_in_src.png`
  - maybe with the right config SE can be made to run as well as others
  - read: https://www.gnu.org/software/gnuastro/manual/html_node/PSF.html
  - check alpha (power) dependance on Moffat function and all other detection/blend/phot parameters
  - psf fitting time matters on the centeroiding? check how much
  - mag important otherwise the flux can not be compared (zero pointing)
  - cutouts are probably wrong as 80x80 but need 40x04? [CHECK] [NO] i checked detection no psf_phot which does have 40x40
  - psf fitting problem 
  - [WHAT] `make_psf_shifted_array` hardcoded values
    ```
    File ~/Desktop/DREAMS/mirar/mirar/processors/photometry/psf_photometry.py:92, in SourcePSFPhotometry._apply_to_sources(self, batch)
        84 logger.debug(f'SourcePSFPhotometry: containing {fits.open(psf_filename)[0].data.astype(float)}')
        85 psf_photometer = PSFPhotometry(psf_filename=psf_filename)
        86 (
        87     flux,
        88     fluxunc,
        89     minchi2,
        90     xshift,
        91     yshift,
    ---> 92 ) = psf_photometer.perform_photometry(image_cutout, unc_image_cutout)
        93 fluxes.append(flux)
        94 fluxuncs.append(fluxunc)

    File ~/Desktop/DREAMS/mirar/mirar/processors/photometry/base_photometry.py:78, in PSFPhotometry.perform_photometry(self, image_cutout, unc_image_cutout)
        75 def perform_photometry(
        76     self, image_cutout: np.array, unc_image_cutout: np.array
        77 ) -> tuple[float, float, float, float, float]:
    ---> 78     psfmodels = make_psf_shifted_array(
        79         psf_filename=self.psf_filename,
        80         cutout_size_psf_phot=int(image_cutout.shape[0] / 2),
        81     )
        83     flux, fluxunc, minchi2, xshift, yshift = psf_photometry(
        84         image_cutout, unc_image_cutout, psfmodels
        85     )
        86     return flux, fluxunc, minchi2, xshift, yshift

    File ~/Desktop/DREAMS/mirar/mirar/processors/photometry/utils.py:293, in make_psf_shifted_array(psf_filename, cutout_size_psf_phot)
        291 padpsfs = np.zeros((60, 60, ngrid))
        292 for i in range(ngrid):
    --> 293     padpsfs[
        294         int(10 + grid_y[i]) : int(51 + grid_y[i]),
        295         int(10 + grid_x[i]) : int(51 + grid_x[i]),
        296         i,
        297     ] = normpsf
        299 normpsfmax = np.max(normpsf)
        300 xcen_1, xcen_2 = np.where(padpsfs[:, :, 12] == normpsfmax)

    ValueError: could not broadcast input array from shape (21,21) into shape (41,41)
    ``` 
   - so does that mean the psf shouuld be 41x41 but the image cutout can be anything? [CHECK] [YES]
     - but this should be parametric not restricted unless there is a reason [CHECK]
   - chi2 and error increase rate based on plots like `/test/pipeline/phot/test_moffat_3/results/flux_error_psf_chisq.png` and `/test/pipeline/phot/test_moffat_1/results/flux_error_psf_chisq.png`
mirar drawbacks:
  - faint or does not match 8-connectedness for `sex`
  - maximum likelyhood with single cutout - not good for crowded fields 
  - check if shifts are high
  - `photutils.calc_total_error` can be used with SKYFLAT [CHECK]
  - maybe output .cat file from SourceCatalog
  - `EPSFBuilding`
    ```
    Notes
    -----
    If your image image contains NaN values, you may see better
    performance if you have the `bottleneck`_ package installed.

    .. _bottleneck:  https://github.com/pydata/bottleneck
    ``` 
    - recentering_func=centroid_2dg, # maybe not needed as centroding is already done - [NO]
    - bad fit warning with `centroid_2dg`
    - our data is well sampled so no need to oversample [CHECK]
      - ref: https://www.stsci.edu/files/live/sites/www/files/home/hst/instrumentation/wfc3/documentation/instrument-science-reports-isrs/_documents/2016/WFC3-2016-12.pdf
    - star galaxy separation not done before making cutouts [CRITICAL]
    - too many detections, increase threshold parameter [CHECK] 
      - [YES] `thereshold_factor=10` seems to work well
      - [NO] damages fainter/smaller
      - change min separation across iterations?
    - automating optimal threshold [CHECK]
    - `thereshold_factor=1.5` resuls: save true with almost same error
    - check `minimum_separation` dependence
    - high error and 
    - why faint detected were not subtracted
    - the imp. is fine as the args can be loaded from a config file in blocks [OK]
    - automate best picking
    - [CRITICAL] extreme psf variance - dont change the gamma and alpha, only amp
    - 

TEST INFO
  - test_moffat_0: mirar_winter with sim
  - test_moffat_1: mirar_winter with sim
    - more results
  - test_moffat_2: 21x21 psf model and cutout - error in `make_shifted_array`
  - test_moffat_3: 41x41 psf model and 21x21 cutout 
  - test_moffat_4: realized extreme PSF variance in simulated image
      - also [CHECK] if model can be fitted in all ways [last row in grid not fit thrice]
        - i.e. model fitting is constrained
        - find acceptable PSF variation
    - distribute different range of Moffat in sections and then compute PSF for each segment - PSF spatial variability
    - segment table can be used for PSF fitting
      - don't put known blended segments or check if a segment could be blended
      - [IMP] deblending needs to be good in the initial catalog
    - group by group_id while plotting to show closeness dependance
    - color code iteration
    - model (PSF) serialization: https://docs.astropy.org/en/stable/modeling/models.html#model-serialization-writing-a-model-to-a-file [LATER]
    - inital convolution can improve connectedness for detection
  - test_moffat_5: continued 4
  - test_moffat_fixed_model_with_crop: only one duplicate and all detected :)
    - changed way of detecrtion to be 50% in either det or src for PSF Phot (saved with _ suffix)
  - test_moffat_fixed_model_with_crop: in row 2 the secondary detectiosn were far away compared to before
  - test_moffat_sub_box_11: fewer false positives, nice subtraction
    - row 3 interesting, see the bright residul on the top left
    - more duplicates this time: indicates that the sub box size affects where the search happens in future iterations [CHECK]
    - flux vs psf count interesting, completely different from the rest!
      - likely hasn't changed the outliers are less [CHECK]
  - for total error calculation, the flat (sky) would include possion so just the dark frames for dark current and readout noise (gaussian)
local bkg reported 0.0 for all, just check again

- check more info on weight map
- default mask `~np.isnan(img_data)`
  - if `weight_path` is not provided then `nan` mask is used throughout
  - `load_proc_winter_image`:
    ```python
    if "weight" in path:
        header[OBSCLASS_KEY] = "weight"
    ``` 
  - [IMP] https://sextractor.readthedocs.io/en/latest/Weighting.html

- conclusion table 
- comparision
- all first part non detections are are mostly from bad deblending/segment centeroiding.
- Petrosian Radius
- SourceExtractor’s centroid and morphological parameters are always calculated from a convolved, or filtered, “detection” image (convolved_data), i.e., the image used to define the segmentation image. The usual downside of the filtering is the sources will be made more circular than they actually are. If you wish to reproduce SourceExtractor centroid and morphology results, then input the convolved_data (or kernel, but not both). If convolved_data and kernel are both None, then the unfiltered data will be used for the source centroid and morphological parameters. Note that photometry is always performed on the unfiltered data. (https://photutils.readthedocs.io/en/stable/segmentation.html)
- explain where your math notation (\hat f) comes from.
- [IMP] note the pixel scale of the simulation 
- use only bright sources for PSF modelling 
- talk about why Moffat
- convolution kernel spreading it more
- things that match within some amount of distance (almost overalapping) amy be rejected
- check if super sampling made sense and read more as the image kinda sucks
- mention the realistic generator from astrometry
- volume normalisation for preserving threshold
- make the saddle view for showing deblending
- [IMP] talk about `mirar` non-detections
- [IMP] [IMP] soruce detection plots - this will tell you the skeqnees 
- [IMP] SNR error 
- [IMP] method of flux ratio
- [IMP] not a centeroding issue 
- [IMP] inidcate correcct detections
- [IMP] fig and table captions need improvement
- [IMP] source match and forced phot
- kron's 1980 first moment algorithm

This allows better assessment of the performace of these pipelies and the methods involved.

Our testing program allows us to easily modify the parameters and output all the critical results. If we use a scoring model, like the one described Section \ref{}, we can automate the optimisation procedure by running the tests over a large space of all reasonable parameter values.


!! S/N in plots
do both distance and morphology for matching

PRESENTATION NOTES:
- check all prononountiations

REMOVED COMMENTS:
- `# TODO: calc_total_error with SKYFLAT (!check) [not really]`


 as mentioned in [this example](https://photutils.readthedocs.io/en/stable/segmentation.html) in the documentation:

> Next, let’s convolve the data with a 2D Gaussian kernel with a FWHM of 3 pixels:
> ```
> ...
> kernel = make_2dgaussian_kernel(3.0, size=5)  # FWHM = 3.0
> convolved_data = convolve(data, kernel)
> ```
> Now we are ready to detect the sources in the background-subtracted convolved image. ...


1
2
- remove ota col. (other details)
- brief (very) near IR
- slide 3 stuff brief
3 - no
4
8 only - mark faiint
9,10 no
10-13 - no - bring it up later
14-15 drop
16 + 17 (merge) quick 
18 quick 
19 no 
20 quick 
23- no
27 more details
28-29 merge - no real data - idependent
30+31 - compare the works, keep message in mind
merge all conv 
37 - less text and just working
all future at the end
37 - key messages 
39 - no over samp
40 at the end
41 - eg. better organization and less text
43 - ... left fixed right change arrows for change (one slide with all changes) - no editiing
43/44 pick one - went through some iterations 
50 no - brief - maybe at the end 
51 specify what matched duplicate 
53+54 together
55 - what about fainer - less signal as expected - as prilim 
58 - future
end summary slide - comparision 
future work
