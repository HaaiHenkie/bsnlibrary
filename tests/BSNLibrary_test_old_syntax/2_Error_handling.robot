*** Settings ***
Documentation     These are errors to notify the user about wrong input or of some exceptions that can occur with certain combinations of arguments and other factors.
Resource          Resource.robot

*** Test Cases ***
Length of given number exceeds maximum
    [Documentation]    Generates a BSN where ``given`` has a length greater than the maximum allowed length: ``length -2``. This test covers ``given`` length equal to ``length - 1`` and equal to ``length`` for the allowed lengths 6, 7, 8 and 9. Default value 9 is covered by passing ``length=9`` to _Generate BSN_ as well as by leaving out the ``length`` argument.
    ...
    ...    Checks:
    ...    - Results in fail with correct error message
    @{lengths}    Create List    ${None}    ${9}    ${8}    ${7}    ${6}
    :FOR    ${length}    IN    @{lengths}
    \    ${max}    Set Variable If    ${length}    ${length - 2}    ${7}
    \    ${given}    Generate Random String    ${max + 1}    [NUMBERS]
    \    Run Keyword If    ${length}    Run Keyword and Expect Error    The length of the given number, ${max + 1} digits, exceeds the maximum value. This maximum value equals \n'length' argument - 2, in this case ${max + 2} - 2 = ${max}.    Generate BSN    ${given}    ${length}
    \    ...    ELSE    Run Keyword and Expect Error    The length of the given number, ${max + 1} digits, exceeds the maximum value. This maximum value equals \n'length' argument - 2, in this case ${max + 2} - 2 = ${max}.    Generate BSN    ${given}
    \    ${given}    Generate Random String    ${max + 2}    [NUMBERS]
    \    Run Keyword If    ${length}    Run Keyword and Expect Error    The length of the given number, ${max + 2} digits, exceeds the maximum value. This maximum value equals \n'length' argument - 2, in this case ${max + 2} - 2 = ${max}.    Generate BSN    ${given}    ${length}
    \    ...    ELSE    Run Keyword and Expect Error    The length of the given number, ${max + 2} digits, exceeds the maximum value. This maximum value equals \n'length' argument - 2, in this case ${max + 2} - 2 = ${max}.    Generate BSN    ${given}

Given argument contains character that is not a digit with variable lengths
    [Documentation]    Generates a BSN with a ``given`` string that contains a character that is not a digit for the allowed lengths 6, 7, 8 and 9. Default value 9 is covered by passing ``length=9`` to _Generate BSN_ as well as by leaving out the ``length`` argument.
    ...
    ...    Checks:
    ...    - Results in fail with correct error message
    ${givens}    Create List    1#4567    3B45q    83S45?    58N5)    22!@
    ${lengths}    Create List    ${None}    ${9}    ${8}    ${7}    ${6}
    ${chars}    Create List    \#    B    S    N    !
    :FOR    ${given}    ${length}    ${char}    IN ZIP    ${givens}    ${lengths}    ${chars}
    \    Run Keyword If    ${length}    Run Keyword and Expect Error    ValueError: Character '${char}' is not a digit. Only use digits as part of a BSN.    Generate BSN    ${given}    ${length}
    \    ...    ELSE    Run Keyword and Expect Error    ValueError: Character '${char}' is not a digit. Only use digits as part of a BSN.    Generate BSN    ${given}

Generate BSN with an invalid length argument
    [Documentation]    Generates a BSN with a ``length`` value that is not one of the allowed values 6, 7, 8 or 9. It cover a value smaller than all values, a value greater than all value and a value that is not a digit.
    ...
    ...    Checks:
    ...    - Results in fail with correct error message
    Run Keyword and Expect Error    ValueError: Value for length must be 6, 7, 8 or 9.    Generate BSN    length=5
    Run Keyword and Expect Error    ValueError: Value for length must be 6, 7, 8 or 9.    Generate BSN    length=10
    Run Keyword and Expect Error    ValueError: Value for length must be 6, 7, 8 or 9.    Generate BSN    length=q

Validate a BSN with a wrong length
    [Documentation]    Validates a BSN with a length of ``bsn`` other than the allowed values 6, 7, 8 or 9.. A length shorter than those values and a length longer than those values is included.
    ...
    ...    Checks:
    ...    - Results in fail with correct error message
    Run Keyword and Expect Error    ValueError: Length of BSN can only be 6, 7, 8 or 9 digits.    Validate BSN    12345
    Run Keyword and Expect Error    ValueError: Length of BSN can only be 6, 7, 8 or 9 digits.    Validate BSN    1234567890

Validate a BSN with a character that is not a digit
    [Documentation]    Validates a BSN with a ``bsn`` string that contains a character that is not a digit. Strings of all allowed lengths 6, 7, 8 and 9 are included.
    ...
    ...    Checks:
    ...    - Results in fail with correct error message
    ${bsns}    Create List    12345678B    1234567S    123456N    12345!
    ${chars}    Create List    B    S    N    !
    :FOR    ${bsn}    ${char}    IN ZIP    ${bsns}    ${chars}
    \    Run Keyword and Expect Error    ValueError: Character '${char}' is not a digit. Only use digits as part of a BSN.    Validate BSN    ${bsn}

Not able to generate a unique BSN after 1000 retries
    [Documentation]    Steps:
    ...    - Generate 9 out of 9 unique and valid BSNs permitted by ``given``
    ...    - Try to generate another BSN out of 9 unique and valid BSNs permitted by the same ``given`` value
    ...
    ...    Checks:
    ...    - Results in fail with correct error message
    :FOR    ${i}    IN RANGE    9
    \    ${bsn}    Generate BSN    1234567
    Run Keyword and Expect Error    'Generate BSN' was not able to generate a unique BSN after 1000 retries. You have generated 9 \nout of the 9 or 10 unique BSNs that are permitted by 0 excluded BSNs and arguments given=1234567 \nand length=9. See section Troubleshooting on web page https://haaihenkie.github.io/bsnlibrary/ \nfor possible solutions.    Generate BSN    1234567

Not able to generate a unique BSN with exclusion
    [Documentation]    Steps:
    ...    - Exclude 5 out of 9 unique and valid BSNs permitted by ``given``
    ...    - Exclude BSNs for other ``given`` and ``length`` arguments.
    ...    - Generate 4 out of 9 unique and valid BSNs permitted by the same ``given`` value.
    ...    - Generate unique BSNs for other ``given`` and ``length`` arguments.
    ...    - Try to generate another BSN out of 9 unique and valid BSNs permitted by the same ``given`` value
    ...
    ...    Checks:
    ...    - Results in fail with correct error message
    ...    - Numbers in error mesage are correct.
    :FOR    ${i}    IN RANGE    5
    \    ${bsn}    Generate BSN    1234567
    ${generated_BSNs}    Get Generated BSNs
    Exclude BSNs    ${generated_BSNs}
    Clear Generated BSNs
    :FOR    ${i}    IN RANGE    9
    \    ${bsn}    Generate BSN    7654321
    ${generated_BSNs}    Get Generated BSNs
    Exclude BSNs    ${generated_BSNs}
    Clear Generated BSNs
    :FOR    ${i}    IN RANGE    9
    \    ${bsn}    Generate BSN    123456    8
    ${generated_BSNs}    Get Generated BSNs
    Exclude BSNs    ${generated_BSNs}
    Clear Generated BSNs
    :FOR    ${i}    IN RANGE    4
    \    ${bsn}    Generate BSN    1234567
    :FOR    ${i}    IN RANGE    9
    \    ${bsn}    Generate BSN    8765432
    :FOR    ${i}    IN RANGE    9
    \    ${bsn}    Generate BSN    12345    7
    Run Keyword and Expect Error    'Generate BSN' was not able to generate a unique BSN after 1000 retries. You have generated 4 \nout of the 4 or 5 unique BSNs that are permitted by 5 excluded BSNs and arguments given=1234567 \nand length=9. See section Troubleshooting on web page https://haaihenkie.github.io/bsnlibrary/ \nfor possible solutions.    Generate BSN    1234567

Not able to generate a unique BSN with length 7 and exclusion
    [Documentation]    Steps:
    ...    - Exclude 6 out of 9 unique and valid BSNs permitted by ``given`` and ``length`` 7.
    ...    - Generate 3 out of 9 unique and valid BSNs permitted by the same ``given`` value and ``length`` 7.
    ...    - Try to generate another BSN out of 9 unique and valid BSNs permitted by the same ``given`` value and ``length`` 7.
    ...
    ...    Checks:
    ...    - Results in fail with correct error message
    ...    - Numbers in error mesage are correct.
    :FOR    ${i}    IN RANGE    3
    \    ${bsn}    Generate BSN    12345    7
    ${generated_BSNs}    Get Generated BSNs
    Exclude BSNs    ${generated_BSNs}
    Clear Generated BSNs
    :FOR    ${i}    IN RANGE    6
    \    ${bsn}    Generate BSN    12345    7
    Run Keyword and Expect Error    'Generate BSN' was not able to generate a unique BSN after 1000 retries. You have generated 6 \nout of the 6 or 7 unique BSNs that are permitted by 3 excluded BSNs and arguments given=12345 \nand length=7. See section Troubleshooting on web page https://haaihenkie.github.io/bsnlibrary/ \nfor possible solutions.    Generate BSN    12345    7

Not able to generate an invalid unique BSN with length 8 and exclusion
    [Documentation]    Steps:
    ...    - Exclude 40 out of 91 unique and invalid BSNs permitted by ``given`` and ``length`` 8.
    ...    - Generate 51 out of 91 unique and invalid BSNs permitted by the same ``given`` value and ``length`` 8.
    ...    - Try to generate another BSN out of 91 unique and invalid BSNs permitted by the same ``given`` value and ``length`` 8.
    ...
    ...    Checks:
    ...    - Results in fail with correct error message
    ...    - Numbers in error mesage are correct.
    :FOR    ${i}    IN RANGE    40
    \    ${bsn}    Generate BSN    999456    8
    ${generated_BSNs}    Get Generated BSNs
    Exclude BSNs    ${generated_BSNs}
    Clear Generated BSNs
    :FOR    ${i}    IN RANGE    51
    \    ${bsn}    Generate BSN    999456    8
    Run Keyword and Expect Error    'Generate BSN' was not able to generate a unique BSN after 1000 retries. You have generated 51 \nout of the 50 or 51 unique BSNs that are permitted by 40 excluded BSNs and arguments given=999456 \nand length=8. See section Troubleshooting on web page https://haaihenkie.github.io/bsnlibrary/ \nfor possible solutions.    Generate BSN    999456    8

Not able to generate a BSN with length 8 all permitted BSNs excluded
    [Documentation]    Steps:
    ...    - Exclude 9 out of 9 unique and valid BSNs permitted by ``given`` and ``length`` 8.
    ...    - Try to generate another BSN permitted by the same ``given`` value and ``length`` 8.
    ...    - Try to generate another BSN permitted by the same ``given`` value and ``length`` 8 and with ``unique=False``.
    ...
    ...    Checks:
    ...    - Results in fail with correct error message for both values of ``unique``
    ...    - Numbers in error mesage are correct.
    :FOR    ${i}    IN RANGE    9
    \    ${bsn}    Generate BSN    123456    8
    ${generated_BSNs}    Get Generated BSNs
    Exclude BSNs    ${generated_BSNs}
    Clear Generated BSNs
    Run Keyword and Expect Error    'Generate BSN' was not able to generate a BSN outside the list of excluded BSNs after 1000 \nretries. You have excluded 9 out of the 9 or 10 BSNs that are permitted by arguments given=123456 \nand length=8. See section Troubleshooting on web page https://haaihenkie.github.io/bsnlibrary/ \nfor possible solutions.    Generate BSN    123456    8
    Run Keyword and Expect Error    'Generate BSN' was not able to generate a BSN outside the list of excluded BSNs after 1000 \nretries. You have excluded 9 out of the 9 or 10 BSNs that are permitted by arguments given=123456 \nand length=8. See section Troubleshooting on web page https://haaihenkie.github.io/bsnlibrary/ \nfor possible solutions.    Generate BSN    123456    8    unique=False

Not able to generate a BSN with length 6 all permitted BSNs excluded
    [Documentation]    Steps:
    ...    - Exclude 9 out of 9 unique and valid BSNs permitted by ``given`` and ``length`` 6.
    ...    - Try to generate another BSN permitted by the same ``given`` value and ``length`` 6.
    ...    - Try to generate another BSN permitted by the same ``given`` value and ``length`` 6 and with ``unique=False``.
    ...
    ...    Checks:
    ...    - Results in fail with correct error message for both values of ``unique``
    ...    - Numbers in error mesage are correct.
    :FOR    ${i}    IN RANGE    9
    \    ${bsn}    Generate BSN    1234    6
    ${generated_BSNs}    Get Generated BSNs
    Exclude BSNs    ${generated_BSNs}
    Clear Generated BSNs
    Run Keyword and Expect Error    'Generate BSN' was not able to generate a BSN outside the list of excluded BSNs after 1000 \nretries. You have excluded 9 out of the 9 or 10 BSNs that are permitted by arguments given=1234 \nand length=6. See section Troubleshooting on web page https://haaihenkie.github.io/bsnlibrary/ \nfor possible solutions.    Generate BSN    1234    6
    Run Keyword and Expect Error    'Generate BSN' was not able to generate a BSN outside the list of excluded BSNs after 1000 \nretries. You have excluded 9 out of the 9 or 10 BSNs that are permitted by arguments given=1234 \nand length=6. See section Troubleshooting on web page https://haaihenkie.github.io/bsnlibrary/ \nfor possible solutions.    Generate BSN    1234    6    unique=False

Not able to generate an invalid BSN with length 7 all permitted BSNs excluded
    [Documentation]    Steps:
    ...    - Exclude 91 out of 91 unique and invalid BSNs permitted by ``given`` and ``length`` 7.
    ...    - Try to generate another invalid BSN permitted by the same ``given`` value and ``length`` 7.
    ...    - Try to generate another invalid BSN permitted by the same ``given`` value and ``length`` 7 and with ``unique=False``.
    ...
    ...    Checks:
    ...    - Results in fail with correct error message for both values of ``unique``
    ...    - Numbers in error mesage are correct.
    :FOR    ${i}    IN RANGE    91
    \    ${bsn}    Generate BSN    99945    7
    ${generated_BSNs}    Get Generated BSNs
    Exclude BSNs    ${generated_BSNs}
    Clear Generated BSNs
    Run Keyword and Expect Error    'Generate BSN' was not able to generate a BSN outside the list of excluded BSNs after 1000 \nretries. You have excluded 91 out of the 90 or 91 BSNs that are permitted by arguments given=99945 \nand length=7. See section Troubleshooting on web page https://haaihenkie.github.io/bsnlibrary/ \nfor possible solutions.    Generate BSN    99945    7
    Run Keyword and Expect Error    'Generate BSN' was not able to generate a BSN outside the list of excluded BSNs after 1000 \nretries. You have excluded 91 out of the 90 or 91 BSNs that are permitted by arguments given=99945 \nand length=7. See section Troubleshooting on web page https://haaihenkie.github.io/bsnlibrary/ \nfor possible solutions.    Generate BSN    99945    7    unique=False
