Creating a new stable branch
----------------------------

If the minor version is updated then a new branch shall be created that can be used to deliver patch releases independently from the developments in the trunk. Follow these steps to create a new stable branch:
- Create a new SVN branch as Plus-X.Y
- Update PlusBuild\External_PlusLib.cmake to use the new branch by default
- Update PlusBuild\External_PlusApp.cmake to use the new branch by default
- Update Plus version in PlusLib\CMakeLists.txt in the new branch
- Update Plus version in PlusLib\CMakeLists.txt in the trunk (to X . Y+1)
