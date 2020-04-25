*** Settings ***
Documentation     Test suite to test BSNLibrary
...
...               This test suite is suitable for Robot Framework v3.1 or earlier. This is the same test suite as in directory BSNLibrary_test with the only difference that this test suite uses the old ``:FOR`` loop syntax.
...
...               The primary use of this test suite is for the developer to test BSNLibrary before it is released.
...
...               Possible other uses:
...               - test whether BSNLibrary works on your system
...               - check out how certain errors can be reproduced under _2 Error handling_
...               - check test cases under _3 Demos_ as referred to by the keyword documentation
Test Setup        Clear Lists
Resource          Resource.robot
