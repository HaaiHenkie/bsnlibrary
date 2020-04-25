*** Settings ***
Documentation     Some demos referred to by the keyword documentation.
Resource          Resource.robot

*** Test Cases ***
Extending the scope of uniqueness beyond one test run
    [Documentation]    Demonstrates how to extend the scope of uniqueness of BSNs beyond one test run. It saves 100 generated and all excluded BSNs to a file. The next run it wil read the BSNs from the file and exclude them. It is not possible to save lists directly in a file. This example shows how it could be done with an underscore as
    ...    separator. It also shows how to reset the stored list after a threshold of 1000 BSNs is reached. Note that in this solution the BSNs generated in previous runs are also excluded when you use _Generate BSN_ with argument ``unique=False``. In that sense it is different from uniqueness within a run.
    ...
    ...    This should not be used as a standard practice. In case you really need this, test it thoroughly especially if you are going to generate large numbers.
    ${status}    Run Keyword And Return Status    File Should Exist    bsnlist.txt
    ${bsnlist}    Run Keyword If    ${status}==True    Get File    bsnlist.txt
    ${bsnlist}    Run Keyword If    ${status}==True    Split String    ${bsnlist}    _
    ${length}    Run Keyword If    ${status}==True    Get Length    ${bsnlist}
    ...    ELSE    Set Variable    0
    Run Keyword If    ${status}==True and ${length}<1000    Exclude BSNs    ${bsnlist}
    FOR    ${i}    IN RANGE    100
        Generate BSN
    END
    ${excluded}    Get Excluded BSNs
    ${generated}    Get Generated BSNs
    ${bsnlist}    Combine Lists    ${excluded}    ${generated}
    Get Length    ${bsnlist}
    ${bsnlist}    Evaluate    "_".join($bsnlist)
    Create File    bsnlist.txt    ${bsnlist}

Why you should not try to generate the last 1% of all permitted BSNs
    [Documentation]    Demonstrates that error "'Generate BSN' was not able to generate a unique BSN after 1000 retries." can occur when approximately 99% of all permitted unique BSNs are generated. In this example there are 909 permitted BSNs. In one test run the test tries to find all 909 permitted BSNs. If it meets the error the test will stop and record how many of the 909 BSNs it has generated. This test is automatically repeated 11 times. At the end you will see a list of the different recorded numbers.
    ...
    ...    When you repeat this demonstration you will see this list will vary in numbers and in length. The numbers can vary from 901 to all 909 permitted BSNs that could be found in one test run. That is approximately the last 1 percent.
    ...
    ...    This is because _Generate BSN_ is designed to generate a random BSN within a range. When it randomly generates a BSN that has already has generated before, it will retry up to a 1000 times to randomly generae an number that has not been generated yet. In this way it is unsuitable for finding all numbers in large ranges.
    ...
    ...    Suppose you really need to find all possible BSNs in larges ranges: _Finding all BSNs in a ranges_ demonstrates how this can be done.
    ${counts}    Create List
    FOR    ${i}    IN RANGE    11
        ${count}    Not able to generate the last 1% of 909 permitted BSNs
        Append To List    ${counts}    ${count}
    END
    ${counts}    Remove Duplicates    ${counts}
    Sort List    ${counts}
    Log    ${counts}

Finding all BSNs in a range
    [Documentation]    If you came to see the demonstration of _Why you should not try to generate the last 1% of all permitted BSNs_ you might have the exceptional need to find all numbers within a range. _Generate BSNs_ is not suitable for that purpose, because it was developed for generating random BSNs within a range. If you really need this, you should divide your range in ranges of 100 numbers. A range of 100 numbers contains 9 or 10 numbers. That means that you have 10% to 11% of finding the last BSN in this range. That is very well above the 1 percent and you will certainly find all BSNs. This demonstration shows how this can be done.
    FOR    ${given}    IN RANGE    1234500    1234600
        Generate all BSNs in a smaller range    ${given}
    END
    ${allbsns}    Get Generated BSNs
    Get Length    ${allbsns}
