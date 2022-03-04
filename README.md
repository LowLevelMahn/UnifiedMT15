# UnifiedMT15

Reverse engineered and C ported **MT15.DRV** (MT32-Sound-Driver) of [Stunts](https://www.mobygames.com/game/stunts) 1.0 and 1.1 in one source
The Sound driver is not a dos typical com or exe file, its starts at offset 0 with an jump table to the driver functions and gets loaded into its own segment by the game

1. Assembler source can be rebuild to 100% binary exact version of the original
2. Assembler can be partially mixed with C ported functions or all functions can be replaced by C code

# History:

Stunts 1.0 MT15.DRV seems to sound better than the 1.1 version (some strange slowdowns happen)
i want to understand what the differences are and how to port that stuff to C

**Result**: the timing code is different - but only some lines of assembler nothing big

# Structure:

| File              | Info                                                                                                                     |
| :---------------- | :----------------------------------------------------------------------------------------------------------------------- |
| \org              | original driver versions - the pure assembler source builds gets validated agains these files (100% binary exact result) |
| build.cmd         | main buid batch                                                                                                          |
| build_helper.cmd  | to keep the build options under control (original asm, asm with partial C, mostly C, ...) **tools_dir variable in build_helper.cmd needs to be set to suits your environment** |
| clang_test.cmd    | using clang/clang-tidy for building (just to find silly bugs in the C port)                                              |
| drv.c             | the ported C code                                                                                                        |
| MT15.asm          | reversed assembler code with version 1.0/1.1, jumper for C ported functions                                              |
| tools_howto.txt   | how to get the needed build tools (UASM, ulink, OpenWatcom) very easy to install                                         |

 **tools_dir variable in build_helper.cmd needs to be set to suits your environment**

build.cmd will create a ..\_build folder (out of source build) with subfolder 10 and 11 for the different versions

# TODO

merge MT15.drv versions of other [Distinctive Software, Inc.](https://www.mobygames.com/company/distinctive-software-inc) games

| Game    | Date  | Size  | MD5   | Info  |
| :----- | :--- | :--- | :--- | :--- |
| Stunts 1.0                             | 11.10.1990 | 1667 | 7048D28F2A0FE8C8C09141D5C89706DB | UnifiedMT15 |
| 4D Sports Boxing 1.0                   | 05.10.1990 | 1667 | 7048D28F2A0FE8C8C09141D5C89706DB |             |
| Bill Elliotts Nascar Challenge         | ~1991      | 1667 | 7048D28F2A0FE8C8C09141D5C89706DB |             |
| Stunts 1.1                             | ~1991      | 1750 | ACC5D03D038F1EF0AFA0CF4DCAD72EF9 | UnifiedMT15 |
| 4D Sports Boxing 1.1                   | 22.04.1991 | 1788 | B17BBC19ED37C9413DD68E20D4D9848F |             |
| Mission Impossible                     | 22.04.1991 | 1788 | B17BBC19ED37C9413DD68E20D4D9848F |             |
| World Tour Tennis                      | ~1993      | 1789 | 53F6BCAEBC097893868C69CE994A3321 |             |
| 4D Sports Tennis                       | 03.03.1992 | 1789 | 53F6BCAEBC097893868C69CE994A3321 |             |
| Michael Jordan in Flight               | 21.12.1992 | 1813 | 372ED87FEE4FB0762D2531DC8BB34337 |             |
| The Simpsons: Barts House of Weirdness | ~1991      | 1982 | 8326A348DCC756EEB77466AD53F742EA |             |   
| Top Gun Danger Zone                    | ?          | ?    | ?                                |             |   
| NFL                                    | ?          | ?    | ?                                |             |

and more



