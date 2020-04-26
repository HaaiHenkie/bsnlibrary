*** Settings ***
Library           BSNLibrary
Library           String
Library           Collections
Library           OperatingSystem

*** Keywords ***
Clear Lists
    [Documentation]    Start new scope for unique and excluded BSNs
    Clear Generated BSNs
    Clear Excluded BSNs

Generate and validate 100 BSNs
    [Arguments]    ${length}
    [Documentation]    See _Generate and validate BSNs with variable length_ under _1 Functional tests_.
    FOR    ${i}    IN RANGE    100
        ${odd}    Evaluate    ${i} % 2
        ${bsn}    Run Keyword If    ${odd} == 0 and ${length} == 9    Generate BSN
        ...    ELSE    Generate BSN    length=${length}
        Validate BSN    ${bsn}
        ${check}    Get Length    ${bsn}
        Should Be Equal As Integers    ${length}    ${check}
        ${min}    Evaluate    100000*10**${length-6}-1
        ${max}    Evaluate    800000*10**${length-6}
        Should be true    ${bsn} > ${min} and ${bsn} < ${max}
    END

Generate and validate 100 invalid BSNs
    [Arguments]    ${length}
    [Documentation]    See _Generate and validate invalid BSNs with variable length_ under _1 Functional tests_.
    FOR    ${i}    IN RANGE    100
        ${odd}    Evaluate    ${i} % 2
        ${bsn}    Run Keyword If    ${odd} == 0 and ${length} == 9    Generate BSN    999
        ...    ELSE    Generate BSN    999    length=${length}
        Run Keyword and Expect Error    The given number '${bsn}' is not a valid BSN.    Validate BSN    ${bsn}
        ${check}    Get Length    ${bsn}
        Should Be Equal As Integers    ${length}    ${check}
        ${min}    Evaluate    999000*10**${length-6}-1
        ${max}    Evaluate    1000000*10**${length-6}
        Should be true    ${bsn} > ${min} and ${bsn} < ${max}
    END

Generate 1000 BSNs starting with 9
    [Arguments]    ${length}
    [Documentation]    See _Generated valid BSNs are not allowed to start with 999_ under _1 Functional tests_.
    ${count9on2}    Set Variable    ${0}
    ${count9on3}    Set Variable    ${0}
    FOR    ${i}    IN RANGE    1000
        ${odd}    Evaluate    ${i} % 2
        ${bsn}    Run Keyword If    ${odd} == 0 and ${length} == 9    Generate BSN    9
        ...    ELSE    Generate BSN    9    length=${length}
        Validate BSN    ${bsn}
        ${first_three}    Get Substring    ${bsn}    0    3
        Should Not Be Equal    ${first_three}    999
        ${second}    Get Substring    ${bsn}    1    2
        ${count9on2}    Set Variable If    ${second} == 9    ${count9on2+1}    ${count9on2}
        ${third}    Get Substring    ${bsn}    2    3
        ${count9on3}    Set Variable If    ${third} == 9    ${count9on3+1}    ${count9on3}
    END
    Should Be True    ${count9on2} > 30 and ${count9on2} < 200
    Should Be True    ${count9on3} > 30 and ${count9on3} < 200

Generate 100 BSNs with enforcing unique BSNs turned off
    [Arguments]    ${length}
    [Documentation]    See _Generate with enforcing unique BSNs turned off_ under _1 Functional tests_.
    ${end}    Set Variable    ${length - 2}
    ${given}    Get Substring    1234567    0    ${end}
    FOR    ${i}    IN RANGE    9
        ${bsn}    Generate BSN    ${given}    length=${length}    unique=True
    END
    Run Keyword and Expect Error    'Generate BSN' was not able to generate a unique BSN after 1000 retries. You have generated 9 \nout of the 9 or 10 unique BSNs that are permitted by 0 excluded BSNs and arguments given=${given} \nand length=${length}. See section Troubleshooting on web page https://haaihenkie.github.io/bsnlibrary/ \nfor possible solutions.    Generate BSN    ${given}    length=${length}    unique=True
    FOR    ${i}    IN RANGE    100
        ${odd}    Evaluate    ${i} % 2
        ${bsn}    Run Keyword If    ${odd} == 0 and ${length} == 9    Generate BSN    ${given}    unique=False
        ...    ELSE    Generate BSN    ${given}    length=${length}    unique=False
        Validate BSN    ${bsn}
        ${check}    Get Length    ${bsn}
        Should Be Equal As Integers    ${length}    ${check}
        ${min}    Evaluate    ${given} * 100 -1
        ${max}    Evaluate    (${given} +1) * 100
        Should be true    ${bsn} > ${min} and ${bsn} < ${max}
    END

Exclude BSNs as list from being generated
    [Arguments]    ${length}    ${checklist}
    [Documentation]    See _Exclude BSNs as list with variable length from being generated_ under _1 Functional tests_.
    Clear Lists
    ${end}    Set Variable If    ${length}    ${length - 2}    7
    ${given}    Get Substring    1234567    0    ${end}
    FOR    ${i}    IN RANGE    5
        ${bsn}    Run Keyword If    ${length}    Generate BSN    ${given}    length=${length}
        ...    ELSE    Generate BSN    ${given}
    END
    ${generated_BSNs}    Get Generated BSNs
    Exclude BSNs    ${generated_BSNs}
    Exclude BSNs    ${generated_BSNs}    # No duplicates should be added
    Clear Generated BSNs
    FOR    ${i}    IN RANGE    4
        ${bsn}    Run Keyword If    ${length}    Generate BSN    ${given}    length=${length}
        ...    ELSE    Generate BSN    ${given}
    END
    ${generated_BSNs}    Get Generated BSNs
    Exclude BSNs    ${generated_BSNs}
    Clear Generated BSNs
    Run Keyword If    ${length}    Run Keyword and Expect Error    'Generate BSN' was not able to generate a BSN outside the list of excluded BSNs after 1000 \nretries. You have excluded 9 out of the 9 or 10 BSNs that are permitted by arguments given=${given} \nand length=${length}. See section Troubleshooting on web page https://haaihenkie.github.io/bsnlibrary/ \nfor possible solutions.    Generate BSN    ${given}    length=${length}
    ...    ELSE    Run Keyword and Expect Error    'Generate BSN' was not able to generate a BSN outside the list of excluded BSNs after 1000 \nretries. You have excluded 9 out of the 9 or 10 BSNs that are permitted by arguments given=${given} \nand length=9. See section Troubleshooting on web page https://haaihenkie.github.io/bsnlibrary/ \nfor possible solutions.    Generate BSN    ${given}
    Run Keyword If    ${length}    Run Keyword and Expect Error    'Generate BSN' was not able to generate a BSN outside the list of excluded BSNs after 1000 \nretries. You have excluded 9 out of the 9 or 10 BSNs that are permitted by arguments given=${given} \nand length=${length}. See section Troubleshooting on web page https://haaihenkie.github.io/bsnlibrary/ \nfor possible solutions.    Generate BSN    ${given}    length=${length}    unique=False
    ...    ELSE    Run Keyword and Expect Error    'Generate BSN' was not able to generate a BSN outside the list of excluded BSNs after 1000 \nretries. You have excluded 9 out of the 9 or 10 BSNs that are permitted by arguments given=${given} \nand length=9. See section Troubleshooting on web page https://haaihenkie.github.io/bsnlibrary/ \nfor possible solutions.    Generate BSN    ${given}    unique=False
    ${excluded_BSNs}    Get Excluded BSNs
    Sort List    ${excluded_BSNs}
    Lists Should Be Equal    ${excluded_BSNs}    ${checklist}

Exclude BSNs as string from being generated
    [Arguments]    ${length}    ${checklist}
    [Documentation]    See _Exclude BSNs as string with variable length from being generated_ under _1 Functional tests_.
    Clear Lists
    ${end}    Set Variable If    ${length}    ${length - 2}    7
    ${given}    Get Substring    1234567    0    ${end}
    FOR    ${i}    IN RANGE    5
        ${bsn}    Run Keyword If    ${length}    Generate BSN    ${given}    length=${length}
        ...    ELSE    Generate BSN    ${given}
        Exclude BSNs    ${bsn}
        Exclude BSNs    ${bsn}    # No duplicates should be added
    END
    Clear Generated BSNs
    FOR    ${i}    IN RANGE    4
        ${bsn}    Run Keyword If    ${length}    Generate BSN    ${given}    length=${length}
        ...    ELSE    Generate BSN    ${given}
        Exclude BSNs    ${bsn}
    END
    Clear Generated BSNs
    Run Keyword If    ${length}    Run Keyword and Expect Error    'Generate BSN' was not able to generate a BSN outside the list of excluded BSNs after 1000 \nretries. You have excluded 9 out of the 9 or 10 BSNs that are permitted by arguments given=${given} \nand length=${length}. See section Troubleshooting on web page https://haaihenkie.github.io/bsnlibrary/ \nfor possible solutions.    Generate BSN    ${given}    length=${length}
    ...    ELSE    Run Keyword and Expect Error    'Generate BSN' was not able to generate a BSN outside the list of excluded BSNs after 1000 \nretries. You have excluded 9 out of the 9 or 10 BSNs that are permitted by arguments given=${given} \nand length=9. See section Troubleshooting on web page https://haaihenkie.github.io/bsnlibrary/ \nfor possible solutions.    Generate BSN    ${given}
    Run Keyword If    ${length}    Run Keyword and Expect Error    'Generate BSN' was not able to generate a BSN outside the list of excluded BSNs after 1000 \nretries. You have excluded 9 out of the 9 or 10 BSNs that are permitted by arguments given=${given} \nand length=${length}. See section Troubleshooting on web page https://haaihenkie.github.io/bsnlibrary/ \nfor possible solutions.    Generate BSN    ${given}    length=${length}    unique=False
    ...    ELSE    Run Keyword and Expect Error    'Generate BSN' was not able to generate a BSN outside the list of excluded BSNs after 1000 \nretries. You have excluded 9 out of the 9 or 10 BSNs that are permitted by arguments given=${given} \nand length=9. See section Troubleshooting on web page https://haaihenkie.github.io/bsnlibrary/ \nfor possible solutions.    Generate BSN    ${given}    unique=False
    ${excluded_BSNs}    Get Excluded BSNs
    Sort List    ${excluded_BSNs}
    Lists Should Be Equal    ${excluded_BSNs}    ${checklist}

Clear list of generated BSNs
    [Arguments]    ${length}
    [Documentation]    See _Clear list of generated BSNs with variable length_ under _1 Functional tests_.
    Clear Lists
    ${end}    Set Variable If    ${length}    ${length - 2}    7
    ${given}    Get Substring    1234567    0    ${end}
    FOR    ${i}    IN RANGE    9
        ${bsn}    Run Keyword If    ${length}    Generate BSN    ${given}    length=${length}
        ...    ELSE    Generate BSN    ${given}
    END
    Run Keyword If    ${length}    Run Keyword and Expect Error    'Generate BSN' was not able to generate a unique BSN after 1000 retries. You have generated 9 \nout of the 9 or 10 unique BSNs that are permitted by 0 excluded BSNs and arguments given=${given} \nand length=${length}. See section Troubleshooting on web page https://haaihenkie.github.io/bsnlibrary/ \nfor possible solutions.    Generate BSN    ${given}    length=${length}
    ...    ELSE    Run Keyword and Expect Error    'Generate BSN' was not able to generate a unique BSN after 1000 retries. You have generated 9 \nout of the 9 or 10 unique BSNs that are permitted by 0 excluded BSNs and arguments given=1234567 \nand length=9. See section Troubleshooting on web page https://haaihenkie.github.io/bsnlibrary/ \nfor possible solutions.    Generate BSN    ${given}
    ${generated_BSNs}    Get Generated BSNs
    ${count}    Get Length    ${generated_BSNs}
    Should Be Equal As Integers    ${9}    ${count}
    Clear Generated BSNs
    ${generated_BSNs}    Get Generated BSNs
    ${count}    Get Length    ${generated_BSNs}
    Should Be Equal As Integers    ${0}    ${count}
    FOR    ${i}    IN RANGE    9
        ${bsn}    Run Keyword If    ${length}    Generate BSN    ${given}    length=${length}
        ...    ELSE    Generate BSN    ${given}
    END

Clear list of excluded BSNs
    [Arguments]    ${length}
    [Documentation]    See _Clear list of excluded BSNs with variable length_ under _1 Functional tests_.
    Clear Lists
    ${end}    Set Variable If    ${length}    ${length - 2}    7
    ${given}    Get Substring    1234567    0    ${end}
    FOR    ${i}    IN RANGE    9
        ${bsn}    Run Keyword If    ${length}    Generate BSN    ${given}    length=${length}
        ...    ELSE    Generate BSN    ${given}
    END
    ${generated_BSNs}    Get Generated BSNs
    Exclude BSNs    ${generated_BSNs}
    Clear Generated BSNs
    ${excluded}    Get Excluded BSNs
    ${count}    Get Length    ${excluded}
    Should Be Equal As Integers    ${9}    ${count}
    Run Keyword If    ${length}    Run Keyword and Expect Error    'Generate BSN' was not able to generate a BSN outside the list of excluded BSNs after 1000 \nretries. You have excluded 9 out of the 9 or 10 BSNs that are permitted by arguments given=${given} \nand length=${length}. See section Troubleshooting on web page https://haaihenkie.github.io/bsnlibrary/ \nfor possible solutions.    Generate BSN    ${given}    length=${length}
    ...    ELSE    Run Keyword and Expect Error    'Generate BSN' was not able to generate a BSN outside the list of excluded BSNs after 1000 \nretries. You have excluded 9 out of the 9 or 10 BSNs that are permitted by arguments given=${given} \nand length=9. See section Troubleshooting on web page https://haaihenkie.github.io/bsnlibrary/ \nfor possible solutions.    Generate BSN    ${given}
    Clear Excluded BSNs
    ${excluded}    Get Excluded BSNs
    ${count}    Get Length    ${excluded}
    Should Be Equal As Integers    ${0}    ${count}
    FOR    ${i}    IN RANGE    9
        ${bsn}    Run Keyword If    ${length}    Generate BSN    ${given}    length=${length}
        ...    ELSE    Generate BSN    ${given}
    END

Not able to generate the last 1% of 909 permitted BSNs
    [Documentation]    See _Why you should not try to generate the last 1% of all permitted BSNs_ under _3 Demos_.
    Clear Lists
    FOR    ${i}    IN RANGE    910
        ${status}    Run Keyword And Return Status    Generate BSN    12345
        Exit For Loop If    ${status} == ${false}
    END
    ${generated_BSNs}    Get Generated BSNs
    ${count}    Get Length    ${generated_BSNs}
    [Return]    ${count}

Generate all BSNs in a smaller range
    [Arguments]    ${given}
    [Documentation]    See _Finding all BSNs in a range_ under _3 Demos_.
    FOR    ${i}    IN RANGE    10
        ${status}    Run Keyword And Return Status    Generate BSN    ${given}
        Exit For Loop If    ${status} == ${false}
    END
