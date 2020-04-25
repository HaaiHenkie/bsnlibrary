*** Settings ***
Documentation     Test suite to test BSNLibrary
...
...               This test suite is suitable for Robot Framework v3.1 or later. If you want to use it for earlier versions, you need to change the ``FOR ... END`` loops to ``:FOR`` loops.
...
...               The primary use of this test suite is for the developer to test BSNLibrary before it is released.
...
...               Possible other uses:
...               - test whether BSNLibrary works on your system
...               - check out how certain errors can be reproduced under _2 Error handling_
...               - check test cases under _3 Demos_ as referred to by the keyword documentation
Test Setup        Clear Lists
Resource          Resource.robot
