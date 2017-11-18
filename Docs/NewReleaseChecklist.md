Creating a new stable branch
----------------------------

If the minor version is updated then a new branch shall be created that can be used to deliver patch releases independently from the developments in the trunk. Follow these steps to create a new stable branch:

<!---->
- PlusBuild
  - Create a new branch from the trunk as Plus-X.Y
  - In the new branch:
    - Update PLUSBUILD_PLUSLIBDATA_GIT_REVISION from master to Plus-X.Y
    - Update PLUSLIB_GIT_REVISION from master to Plus-X.Y
    - Update PLUSLIB_GIT_REVISION from master to Plus-X.Y
    - Update PLUSAPP_GIT_REVISION from master to Plus-X.Y
    - Update SetGitRepositoryTag in dependencies to reference the latest commit
      - External_OpenIGTLink
      - External_OpenIGTLinkIO
      - External_OvrvisionPro
      - External_Tesseract
      - External_aruco
      - External_ndicapi
      - Any others that have been added, and use the 'master' version

<!---->
- PlusLib
  - Create a new branch from the trunk as Plus-X.Y
  - In the new branch:
    - Update minor version number to Y in CmakeLists.txt
  - In the trunk:
    - Update minor version number to Y+1 in CmakeLists.txt

<!---->
- PlusApp
  - Create a new branch from the trunk as Plus-X.Y

<!---->
- PlusLibData
  - Create a new branch from the trunk as Plus-X.Y

<!---->
- Build scripts
  - Update PLUS_STABLE_VERSION in CommonVars.bat to version X.Y

<!---->
- Update this documentation to reflect any changes in the release process
