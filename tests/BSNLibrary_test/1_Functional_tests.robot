*** Settings ***
Documentation     Covers the functionality of all BSNLibrary keywords. _Get Excluded BSNs_ and _Get Generated BSNs_ are covered implicitly, the other keywords have one or more test cases.
...
...               Some of the situations for _Generate BSN_ depend on the combination of randomly selected digits. To be sure all those situations are covered, this keyword is often repeated 100 times of more.
Resource          Resource.robot

*** Test Cases ***
Generate and validate BSNs with variable length
    [Documentation]    Generates 100 BSNs for every possible ``length``: 6, 7, 8 or 9. Default value 9 is covered by passing ``length=9`` to _Generate BSN_ as well as by leaving out the ``length`` argument.
    ...
    ...    Checks:
    ...    - the generated BSNs are valid
    ...    - the lengths of the generated BSNs corresponds with ``length``
    ...    - the generated BSNs have a value in the default range, e.g. between 100000000 and 799999999 for ``length`` 9
    ...    - _Generate BSN_ handles the "remainder of 10" situation correctly, see explanation below.
    ...
    ...    == The "remainder of 10" situation ==
    ...    When generating a BSN _Generate BSN_ calculates the last digit based on the preceding digits:
    ...
    ...    _digit1_ = _sumproduct_ modulo 11
    ...
    ...    _digit1_ is the last digit on positon 1. _sumproduct_ is the sum of _position_ * _digit_ for all preceding digits. _position_ counts down from ``length`` to 2. In this way the generated number will pass the eleven test, because _sumproduct_ - \ _digit1_ can be divided by 11.
    ...
    ...    There is a 9% chance that the result of the calculation is a remainder of 10. In that case there is no solution because a single digit cannot be equal to 10. In order to be able to still generate a valid BSN, _Generate BSN_ randomly chooses another second last digit unequal to the original value and calculates the last digit again.
    ...
    ...    To make sure that this situation is covered, _Generate BSN_ is repeated a 100 times.
    FOR    ${length}    IN RANGE    6    10
        Generate and validate 100 BSNs    ${length}
    END

Generate and validate invalid BSNs with variable length
    [Documentation]    Generates 100 invalid BSNs for every possible ``length``: 6, 7, 8 or 9. Default value 9 is covered by passing ``length=9`` to _Generate BSN_ as well as by leaving out the ``length`` argument.
    ...
    ...    Checks:
    ...    - the generated BSNs are invalid
    ...    - the lengths of the generated BSNs corresponds with ``length``
    ...    - the generated BSNs have a value in the range that is indicated by the ``given`` value 999, e.g. between 999000000 and 999999999 for ``length`` 9
    FOR    ${length}    IN RANGE    6    10
        Generate and validate 100 invalid BSNs    ${length}
    END

Generated valid BSNs are not allowed to start with 999
    [Documentation]    _Generate BSN_ will generate an invalid BSN when ``given`` starts with '999'. To avoid misinterpretation, _Generate BSN_ should not accidentally generate a valid BSN that starts with '999'.
    ...
    ...    Generates 1000 BSNs that start with '9' and for every possible ``length``: 6, 7, 8 or 9. Default value 9 is covered by passing ``length=9`` to _Generate BSN_ as well as by leaving out the ``length`` argument.
    ...
    ...    Checks:
    ...    - the generated BSNs are valid
    ...    - the generated BSNs never start with '999'
    ...    - digit 9 can occur on the second and the third position of the generated BSNs
    ...
    ...    With 9 as the first digit and the second and third digit randomly selected, the chance for a generated number to start with '999' would be 1%. That is why _Generate BSN_ is repeated a 1000 times to make sure the generated numbers never start with '999'.
    FOR    ${length}    IN RANGE    6    10
        Generate 1000 BSNs starting with 9    ${length}
    END

Generate with enforcing unique BSNs turned off
    [Documentation]    Steps:
    ...    - Generate 9 out of 9 unique and valid BSNs permitted by ``given`` and with ``unique=True``
    ...    - Try to generate another BSN permitted by the same ``given`` and with ``unique=True``
    ...    - Generate 100 BSNs with the same ``given`` and with ``unique=False``
    ...    This is repeated for every possible ``length``: 6, 7, 8 or 9. Default value 9 is covered by passing ``length=9`` to _Generate BSN_ as well as by leaving out the ``length`` argument.
    ...
    ...    Checks:
    ...    - with argument ``unique=True`` it is not possible to generate another BSN with the same ``given`` value
    ...    - with argument ``unique=False`` and the same ``given`` value no error error occurs because of not being able to generate unique BSNs
    ...    - the generated BSNs are valid
    ...    - the lengths of the generated BSNs corresponds with ``length``
    ...    - the generated BSNs have a value in the range that is indicated by ``given``
    ...    - _Generate BSN_ handles the "remainder of 10" situation correctly, see explanation under test case _Generate and validate BSNs with variable length_
    FOR    ${length}    IN RANGE    6    10
        Generate 100 BSNs with enforcing unique BSNs turned off    ${length}
    END

Exclude BSNs as list with variable length from being generated
    [Documentation]    Steps:
    ...    - Generate 5 out of 9 unique and valid BSNs permitted by ``given``
    ...    - Exclude the 5 generated BSNs as a list
    ...    - Exclude the 5 generated BSNs \ as a list for a second time
    ...    - Clear the list of generated BSNs (end of scope of uniqueness)
    ...    - Generate 4 out of 9 unique and valid BSNs permitted by the same ``given`` value
    ...    - Exclude the 4 generated BSNs as a list
    ...    - Clear the list of generated BSNs (end of scope of uniqueness)
    ...    - Try to generate another BSN out of 9 unique and valid BSNs permitted by the same ``given`` value
    ...    - Try to generate another BSN out of 9 unique and valid BSNs permitted by the same ``given`` value and with ``unique=False``.
    ...    This is repeated for every possible ``length``: 6, 7, 8 or 9. Default value 9 is covered by passing ``length=9`` to _Generate BSN_ as well as by leaving out the ``length`` argument.
    ...
    ...    Checks:
    ...    - All 9 unique and valid BSNs permitted by ``given`` have been generated and excluded, that proves that the first 5 BSNs were excluded when generating the second 4 BSNs
    ...    - There are no duplicate values in the list of excluded BSNs
    ...    - After excluding all 9 unique and valid BSNs permitted by ``given`` it is not possible to generate another BSN with the same ``given`` value, also with ``unique=False``
    ${lengths}    Create List    ${None}    ${9}    ${8}    ${7}    ${6}
    ${checklists}    Create List
    ${checklist}    Create List    123456708    123456721    123456733    123456745    123456757    123456769    123456770    123456782    123456794
    Append To List    ${checklists}    ${checklist}
    ${checklist}    Create List    123456708    123456721    123456733    123456745    123456757    123456769    123456770    123456782    123456794
    Append To List    ${checklists}    ${checklist}
    ${checklist}    Create List    12345611    12345623    12345635    12345647    12345659    12345660    12345672    12345684    12345696
    Append To List    ${checklists}    ${checklist}
    ${checklist}    Create List    1234511    1234523    1234535    1234547    1234559    1234560    1234572    1234584    1234596
    Append To List    ${checklists}    ${checklist}
    ${checklist}    Create List    123407    123419    123420    123432    123444    123456    123468    123481    123493
    Append To List    ${checklists}    ${checklist}
    FOR    ${length}    ${checklist}    IN ZIP    ${lengths}    ${checklists}
        Exclude BSNs as list from being generated    ${length}    ${checklist}
    END

Exclude BSNs as string with variable length from being generated
    [Documentation]    Steps:
    ...    - Generate 5 out of 9 unique and valid BSNs permitted by ``given``
    ...    - Exclude each of the 5 generated BSNs as a string
    ...    - Exclude each of the 5 generated BSNs for a second time
    ...    - Clear the list of generated BSNs (end of scope of uniqueness)
    ...    - Generate 4 out of 9 unique and valid BSNs permitted by the same ``given`` value
    ...    - Exclude each of the 4 generated BSNs as a string
    ...    - Clear the list of generated BSNs (end of scope of uniqueness)
    ...    - Try to generate another BSN out of 9 unique and valid BSNs permitted by the same ``given`` value
    ...    - Try to generate another BSN out of 9 unique and valid BSNs permitted by the same ``given`` value and with ``unique=False``
    ...    This is repeated for every possible ``length``: 6, 7, 8 or 9. Default value 9 is covered by passing ``length=9`` to _Generate BSN_ as well as by leaving out the ``length`` argument.
    ...
    ...    Checks:
    ...    - All 9 unique and valid BSNs permitted by ``given`` have been generated and excluded, that proves that the first 5 BSNs were excluded when generating the second 4 BSNs
    ...    - There are no duplicate values in the list of excluded BSNs
    ...    - After excluding all 9 unique and valid BSNs permitted by ``given`` it is not possible to generate another BSN with the same ``given`` value, also with ``unique=False``.
    ${lengths}    Create List    ${None}    ${9}    ${8}    ${7}    ${6}
    ${checklists}    Create List
    ${checklist}    Create List    123456708    123456721    123456733    123456745    123456757    123456769    123456770    123456782    123456794
    Append To List    ${checklists}    ${checklist}
    ${checklist}    Create List    123456708    123456721    123456733    123456745    123456757    123456769    123456770    123456782    123456794
    Append To List    ${checklists}    ${checklist}
    ${checklist}    Create List    12345611    12345623    12345635    12345647    12345659    12345660    12345672    12345684    12345696
    Append To List    ${checklists}    ${checklist}
    ${checklist}    Create List    1234511    1234523    1234535    1234547    1234559    1234560    1234572    1234584    1234596
    Append To List    ${checklists}    ${checklist}
    ${checklist}    Create List    123407    123419    123420    123432    123444    123456    123468    123481    123493
    Append To List    ${checklists}    ${checklist}
    FOR    ${length}    ${checklist}    IN ZIP    ${lengths}    ${checklists}
        Exclude BSNs as string from being generated    ${length}    ${checklist}
    END

Clear list of generated BSNs with variable length
    [Documentation]    Steps:
    ...    - Generate 9 out of 9 unique and valid BSNs permitted by ``given``
    ...    - Try to generate another BSN out of 9 unique and valid BSNs permitted by the same ``given`` value
    ...    - Clear the list of generated BSNs (end of scope of uniqueness)
    ...    - Generate again 9 out of 9 unique and valid BSNs permitted by the same ``given`` value
    ...    This is repeated for every possible ``length``: 6, 7, 8 or 9. Default value 9 is covered by passing ``length=9`` to _Generate BSN_ as well as by leaving out the ``length`` argument.
    ...
    ...    Checks:
    ...    - After generating the 9 BSNs it is not possible to generate another unique BSN with the same ``given`` value
    ...    - After generating the 9 BSNs the list of generated BSNs counts 9 BSNs
    ...    - Clearing the generated BSNs gives the right log message
    ...    - After clearing the generated BSNs the list of generated BSNs counts 0 BSNs
    ...    - After clearing the generated BSNs it is possible to generate the same 9 unique BSNs again
    ...
    ...    The following statements are used by ``statuschecker`` to check the messages of _Clear Generated BSNs_
    ...
    ...    LOG 2.1.1.1.1 GLOB: List of * generated BSNs has been cleared.
    ...
    ...    LOG 2.1.1.9 INFO List of 9 generated BSNs has been cleared.
    ...
    ...    LOG 2.2.1.1.1 INFO List of 9 generated BSNs has been cleared.
    ...
    ...    LOG 2.2.1.9 INFO List of 9 generated BSNs has been cleared.
    ...
    ...    LOG 2.3.1.1.1 INFO List of 9 generated BSNs has been cleared.
    ...
    ...    LOG 2.3.1.9 INFO List of 9 generated BSNs has been cleared.
    ...
    ...    LOG 2.4.1.1.1 INFO List of 9 generated BSNs has been cleared.
    ...
    ...    LOG 2.4.1.9 INFO List of 9 generated BSNs has been cleared.
    ...
    ...    LOG 2.5.1.1.1 INFO List of 9 generated BSNs has been cleared.
    ...
    ...    LOG 2.5.1.9 INFO List of 9 generated BSNs has been cleared.
    @{lengths}    Create List    ${None}    ${9}    ${8}    ${7}    ${6}
    FOR    ${length}    IN    @{lengths}
        Clear list of generated BSNs    ${length}
    END

Clear list of excluded BSNs with variable length
    [Documentation]    Steps:
    ...    - Exclude 9 out of 9 unique and valid BSNs permitted by ``given``
    ...    - Try to generate another BSN out of 9 unique and valid BSNs permitted by the same ``given`` value
    ...    - Clear the list of excluded BSNs (end of scope of exclusion)
    ...    - Generate again 9 out of 9 unique and valid BSNs permitted by the same ``given`` value
    ...    This is repeated for every possible ``length``: 6, 7, 8 or 9. Default value 9 is covered by passing ``length=9`` to _Generate BSN_ as well as by leaving out the ``length`` argument.
    ...
    ...    Checks:
    ...    - After excluding the 9 BSNs it is not possible to generate another unique BSN with the same ``given`` value
    ...    - After excluding the 9 BSNs the list of excluded BSNs counts 9 BSNs
    ...    - Clearing the excluded BSNs gives the right log message
    ...    - After clearing the excluded BSNs the list of excluded BSNs counts 0 BSNs
    ...    - After clearing the excluded BSNs it is possible to generate the same 9 unique BSNs again
    ...
    ...    The following statements are used by ``statuschecker`` to check the messages of _Clear Excluded BSNs_
    ...
    ...    LOG 2.1.1.1.2 INFO The list of excluded BSNs has been cleared.
    ...
    ...    LOG 2.1.1.12 INFO The list of excluded BSNs has been cleared.
    ...
    ...    LOG 2.2.1.1.2 INFO The list of excluded BSNs has been cleared.
    ...
    ...    LOG 2.2.1.12 INFO The list of excluded BSNs has been cleared.
    ...
    ...    LOG 2.3.1.1.2 INFO The list of excluded BSNs has been cleared.
    ...
    ...    LOG 2.3.1.12 INFO The list of excluded BSNs has been cleared.
    ...
    ...    LOG 2.4.1.1.2 INFO The list of excluded BSNs has been cleared.
    ...
    ...    LOG 2.4.1.12 INFO The list of excluded BSNs has been cleared.
    ...
    ...    LOG 2.5.1.1.2 INFO The list of excluded BSNs has been cleared.
    ...
    ...    LOG 2.5.1.12 INFO The list of excluded BSNs has been cleared.
    @{lengths}    Create List    ${None}    ${9}    ${8}    ${7}    ${6}
    FOR    ${length}    IN    @{lengths}
        Clear list of excluded BSNs    ${length}
    END

Validate a valid BSN with variable lengths
    [Documentation]    Validates a valid BSN for every possible ``length``: 6, 7, 8 or 9.
    ...
    ...    Checks:
    ...    - Validating a valid BSN gives the right log message
    ...
    ...    The following statements are used by ``statuschecker`` to check the messages of _Clear Generated BSNs_
    ...
    ...    LOG 2.1.1 INFO The BSN '747359489' is valid.
    ...
    ...    LOG 2.2.1 INFO The BSN '25221577' is valid.
    ...
    ...    LOG 2.3.1 INFO The BSN '1763921' is valid.
    ...
    ...    LOG 2.4.1 INFO The BSN '353000' is valid.
    @{bsns}    Create List    747359489    25221577    1763921    353000
    FOR    ${bsn}    IN    @{bsns}
        Validate BSN    ${bsn}
    END

Validate invalid BSNs with variable length
    [Documentation]    Validates an invalid BSN for every possible ``length``: 6, 7, 8 or 9.
    ...
    ...    Per ``length`` two situations are tested:
    ...    - The "remainder of 10" situation: there is no possible last digit that could make it a valid number
    ...    - The number is invalid because the last digit is not equal to the remainder.
    ...    For an explanation of the calculation of the last digit and the "remainder of 10" situation, see test case _Generate and validate BSNs with variable length_.
    ...
    ...    Checks:
    ...    - Results in fail with correct error message
    # Path: remainder is 10
    @{bsns}    Create List    784035889    53876268    5845217    228456
    # Path: last digit not equal to remainder
    Append To List    ${bsns}    207232909    23533128    7894067    314616
    # Validate all given BSNs
    FOR    ${bsn}    IN    @{bsns}
        Run Keyword and Expect Error    The given number '${bsn}' is not a valid BSN.    Validate BSN    ${bsn}
    END
