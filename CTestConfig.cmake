## This file should be placed in the root directory of your project.
## Then modify the CMakeLists.txt file in the root directory of your
## project to incorporate the testing dashboard.
## # The following are required to uses Dart and the Cdash dashboard
##   enable_testing()
##   include(CTest)
set(CTEST_PROJECT_NAME "PlusBuild")
set(CTEST_BUILD_NAME "PlusBuild")
set(CTEST_NIGHTLY_START_TIME "00:00:00 EST")

set(CTEST_DROP_METHOD "https")
set(CTEST_DROP_SITE "open.cdash.org")
set(CTEST_DROP_LOCATION "/submit.php?project=PlusBuild")
set(CTEST_DROP_SITE_CDASH TRUE)
