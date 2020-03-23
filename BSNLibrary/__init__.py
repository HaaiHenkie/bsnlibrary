"""
Robot Framework Library for generating a random BSN (Burger Service Nummer, i.e. a Dutch citizen service number) for
test purposes.

A BSN is used in Netherlands to identify a person for government organisations,
see [https://www.government.nl/topics/personal-data/citizen-service-number-bsn|this information of the Dutch
government]. The number consists of 9 digits and has to pass the eleven test.

This test can be explained with the example 211551557. Each digit is multiplied with its position and the results are
added up together:

``(9*2) + (8*1) + (7*1) + (6*5) + (5*5) + (4*1) + (3*5) + (2*5) - (1*7) = 110``

Note that the digit in position 1 is subtracted from the other results. The total sum can be divided by 11,
which means that this number has passed the eleven test.

This library generates BSNs for test purposes in the sense that it generates random 9 digit numbers that pass the
eleven test. By coincidence a generated number could be a real person's BSN. Yet this library cannot violate such a
person's privacy, because it cannot tell you whether a number belongs to a real person or not, nor will it provide
you with any personal data related to a BSN. Obviously you should only use this library in test environments.

This library brings the following features to Robot Framework:
- generating a valid BSN
- generating a BSN that is unique within the current test run
- generating a number that will not pass the eleven test
- generating a BSN that starts with specific digits
- generating a BSN that is less than 9 digits long
- checking if a given number passes the eleven test
- returning a list of BSNs generated during the current test run
- specifying BSNs that should not be generated

Possible use cases:
- A test message that is processed by one or more systems can be tracked by its unique BSN
- Creating messages with BSNs in a certain range that leads to a certain response from a system or stub
- Checking whether a test message contains a valid BSN

Installation:

``pip install robotframework-bsnlibrary``

[https://pypi.org/project/robotframework-bsnlibrary/|Installation package on PyPI]

[https://github.com/HaaiHenkie/bsnlibrary|GitHub repository]

Create date: 01-03-2020

Author: Henk van den Akker

License: GNU General Public License v3.0

= Scope of uniqueness and exclusion =
`Generate BSN` will by default generate a unique BSN every time it is used throughout the test run. After using
`Exclude BSNs` with a list of BSNs, `Generate BSN` will exclude those BSNs every time it is used until the end of the
test run. These are the normal scopes for uniqueness and exclusion and they are suitable for most purposes. The
following information is relevant for the few cases that need a smaller or larger scope.

== Reducing the scope ==
Uniqueness is established by a list of generated BSNs. Every time `Generate BSN` is used it will exclude the BSNs on
this list add the generated BSN to this list. The scope of uniqueness and exclusion can be ended by clearing the list
of generated BSNs and the list of excluded BSNs respectively. So to limit, for example, the scope of uniqueness to a
suite, use `Clear Generated BSNs` in the teardown of the suite and of the previous suite. Suppose you need each test
to have its own set of excluded BSNs, use `Exclude BSNs` in de setup of each test and `Clear Excluded BSNs` in the
teardown of each test.

== Extending the scope ==
It is possible to extend the scope of uniqueness of BSNs over test runs with `Get Generated BSNs` and `Get Excluded
BSNs` at the end of the test run and appending this list to a file. Then at the start of a test run read the list
from the file and offer it as input to `Exclude BSNs`. However, you cannot do this infinitely, because after a
certain amount of repetitions the list of excluded BSNs will be so large that it will lead to performance or other
problems.

=== Example ===
It is not possible to save lists directly in a file. This example shows how it could be done with an underscore as
separator. It also shows how to reset the stored list after a threshold of 100000 BSNs is reached.

| ${status}= | Run Keyword And Return Status | File Should Exist | bsnlist.txt |
| ${bsnlist}= | Run Keyword If | ${status}==True | Get File |  bsnlist.txt |
| ${bsnlist}= | Run Keyword If | ${status}==True | Split String | ${bsnlist} | _ |
| ${length}= | Run Keyword If | ${status}==True | Get Length | ${bsnlist} |
| ... | ELSE | Set Variable | 0 |
| Run Keyword If | ${status}==True and ${length}<100000 | Exclude BSNs | ${bsnlist} |
| FOR | ${i} | IN RANGE | 100 |
| | Generate BSN |
| END |
| ${excluded}= | Get Excluded BSNs |
| ${generated}= | Get Generated BSNs |
| ${bsnlist}= | Combine Lists | ${excluded} | ${generated} |
| ${bsnlist}= | Evaluate | "_".join($bsnlist) |
| Create File | bsnlist.txt | ${bsnlist} |

= Troubleshooting =
Most exceptions are self-explanatory. The following exception (with example counts and arguments) needs more
explanation:

| 'Generate BSN' was not able to generate a unique BSN after 1000 retries. You have generated 900 of approximately
| 900 unique BSNs that are possible with 9 excluded BSNs and arguments given=12345 and length=9.

This means that all or almost all possible BSNs within the given restrictions have been generated. For further insight
you could use `Get Generated BSNs` and `Get Excluded BSNs` to log those lists just before this exception occurs. The
exception only counts generated and excluded BSNs that could have been generated with the current arguments.

Possible solutions are:
- Use `unique=False` if you do not need unique BSNs
- Use a smaller scope for uniqueness and exclusion, see `Reducing the scope`
- Limit the length of `given` and/or avoid using the same value for `given` repeatedly
- Reduce the list of excluded BSNs

There is a similar second exception (again with example counts and arguments)

| 'Generate BSN' was not able to generate a BSN outside the list of excluded BSNs after 1000 retries. You have
| excluded 909 of approximately 909 BSNs that are possible with arguments given=12345 and length=9.

In this case only the last two possible solutions apply.

If you experience slow performance this is probably caused by a large number of both generated BSNs and excluded BSNs
combined with a relatively small number of BSNs that possibly can be generated. The possible solutions are the same as
for the exceptions above.

When you are not able to resolve a problem regarding BSNLibrary,
[https://github.com/HaaiHenkie/bsnlibrary/issues/new|register an issue].
"""

import random
import textwrap
from BSNLibrary import exceptions
from robot.api import deco
import logging

__version__ = '0.3'
ROBOT_LIBRARY_SCOPE = 'GLOBAL'
VALID_LENGTH = {6, 7, 8, 9}
used_bsns = []
excluded_bsns = []


@deco.keyword('Generate BSN')
def generate_bsn(given="", length=9, unique=True):
    """
    Generates a number between 100000000 and 799999999 that passes the eleven test. By default this BSN is unique
    within a test run and is added to a list that can be accessed with Get Generated BSNs. It will not generate
    numbers specified with `Exclude BSNs`.

    `given` argument can be used to specify the first digits of the number to be generated, thus
    restricting the range within which the number is generated.
    - To generate a number outside the default range, specify 0, 8 or 9 as the first digit
    - To validate a number, specify the complete number (the number of digits is equal to `length`)
    - To generate an invalid number, specify '999' as the first three digits
    - The `given` string can only contain digits
    - The number of digits should be smaller than `length - 1` or equal to `length`

    `length` argument can be used to generate a number of less than 9 positions, for example when a BSN of 8
    positions is needed.
        - Only values 6, 7, 8 or 9 are allowed

    If `unique` is given a `False` value the keyword no longer enforces that the generated BSN is unique within a
    test run, nor will it add the generated number to the list of generated BSNs. Can be used in situations that
    uniqueness is not a requirement and enforcing it leads to problems.

    == Examples ==

    | ${bsn1} = | Generate BSN | | # Generates a valid BSN between 100000000 and 799999999. |
    | ${bsn2} = | Generate BSN | 85 | # Generates a valid BSN with '85' as the first 2 digits. |
    | ${bsn3} = | Generate BSN | 211551557 | # Validates the given (valid) BSN. |
    | ${bsn4} = | Generate BSN | 9994 | # Generates an invalid BSN. |
    | ${bsn5} = | Generate BSN | ${bsn4} | # Validates the given (invalid) BSN. |
    | ${bsn6} = | Generate BSN | length=8 | # Generates a BSN with 8 positions. |

    === Example results ===

    | ${bsn1} = 771052066
    | ${bsn2} = 853380107
    | ${bsn3} = 211551557
    | ${bsn4} = 999450437
    | ${bsn5} => FAIL : The given number '999450437' is not valid.
    | ${bsn6} = 30340731
    """
    global used_bsns
    given = str(given)
    given_length = len(given)
    length = int(length)
    if length not in VALID_LENGTH:
        raise ValueError("Value for length must be 6, 7, 8 or 9.")
    if given_length > length or given_length == length - 1:
        raise exceptions.GivenNumberWrongLength(textwrap.dedent("""\
            The length of the given number, %d digits, is longer than length, %d, 
            or equal to length - 1. That is not allowed.""" % (given_length, length)))
    if str(unique).lower() in ('false', 'none', 'no', 'off', '0') or given_length == length:
        unique = False
    else:
        unique = bool(unique)
    power = length - given_length
    all_numbers = 10 ** power
    valid_numbers = int(all_numbers / 11)
    if given[:3] == "999":
        valid_numbers = all_numbers - valid_numbers
    excluded_matches = sum(e[:given_length] == given and len(e) == length for e in excluded_bsns)
    approx_possible = valid_numbers - excluded_matches
    if unique:
        generated_bsn = ""
        iteration = 0
        while generated_bsn == "" or generated_bsn in used_bsns:
            iteration += 1
            if iteration == 1001:
                used_matches = sum(e[:given_length] == given and len(e) == length for e in used_bsns)
                raise exceptions.FailedToGenerateAllowedBSN(textwrap.dedent("""\
                    'Generate BSN' was not able to generate a unique BSN after 1000 retries. You have generated %d of 
                    approximately %d unique BSNs that are possible with %d excluded BSNs and arguments given=%s and 
                    length=%d. See section Troubleshooting on web page https://haaihenkie.github.io/bsnlibrary/ for 
                    possible solutions.""" % (used_matches, approx_possible, excluded_matches, given, length)))
            generated_bsn = generate_bsn(given, length, False)
        used_bsns.append(generated_bsn)
        return generated_bsn
    else:
        generated_bsn = ""
        iteration = 0
        excluded = []
        if given_length < length:
            excluded = excluded_bsns
        while generated_bsn == "" or generated_bsn in excluded:
            iteration += 1
            if iteration == 1001:
                raise exceptions.FailedToGenerateAllowedBSN(textwrap.dedent("""\
                    'Generate BSN' was not able to generate a BSN outside the list of excluded BSNs after 1000 
                    retries. You have excluded %d of approximately %d BSNs that are possible with arguments given=%s
                    and length=%d. See section Troubleshooting on web page https://haaihenkie.github.io/bsnlibrary/ for 
                    possible solutions.""" % (excluded_matches, valid_numbers, given, length)))
            sum_product = 0
            pos = length
            digit1 = None
            digit2 = None
            generated_bsn = ""
            if given_length > 0:
                for d in given:
                    try:
                        d = int(d)
                        if pos > 1:
                            sum_product = sum_product + d * pos
                            generated_bsn += str(d)
                        else:
                            digit1 = d
                        pos = pos - 1
                    except (TypeError, ValueError) as e:
                        e.args = ("The character '%s' is not a digit. Only use digits in the given number." % d,)
                        raise
            else:
                digit = random.randint(1, 7)
                sum_product = sum_product + digit * pos
                generated_bsn = str(digit)
                pos = pos - 1
            while pos > 1:
                if pos == length - 2 and generated_bsn[:2] == "99":
                    digit = random.randint(0, 8)
                else:
                    digit = random.randint(0, 9)
                sum_product = sum_product + digit * pos
                generated_bsn += str(digit)
                if pos == 2:
                    digit2 = digit
                pos = pos - 1
            mod = sum_product % 11
            if given[:3] == "999" and given_length < length:
                digit1 = _exclude_digit(mod)
            else:
                if mod == 10:
                    if given_length == length:
                        raise exceptions.NumberNotValid("The given number '%s' is not valid." % given)
                    else:
                        sum_product = sum_product - digit2 * 2
                        generated_bsn = generated_bsn[:-1]
                        digit2 = _exclude_digit(digit2)
                        generated_bsn += str(digit2)
                        sum_product = sum_product + digit2 * 2
                        mod = sum_product % 11
                        digit1 = mod
                elif given_length == length:
                    if digit1 != mod:
                        raise exceptions.NumberNotValid("The given number '%s' is not valid." % given)
                else:
                    digit1 = mod
            generated_bsn += str(digit1)
        return generated_bsn


def _exclude_digit(digit):
    new = digit
    while new == digit:
        new = random.randint(0, 9)
    return new


@deco.keyword('Get Generated BSNs')
def get_generated_bsns():
    """
    Returns a list of unique BSNs that are generated with `Generate BSN` within the current test run. It can be used
    to create such a list or to inspect the current list for troubleshooting purposes.

    == Example ==

    | Clear Generated BSNs | | | | | # Clears BSNs generated so far |
    | FOR | ${i} | IN RANGE | 0 | 100 |
    | | Generate BSN | | | | # Do not use `unique=False` |
    | END | | | | | # for no list will be generated |
    | @{generated_bsns} = | Get Generated BSNs | | | | # A list of 100 unique BSNs |
    """
    return used_bsns


@deco.keyword('Clear Generated BSNs')
def clear_generated_bsns():
    """
    Clears the list of BSNs generated by `Generate BSN` with argument `unique=True`. See in `Scope of uniqueness and
    exclusion` how this can be used to reduce the scope of uniqueness.
    """
    global used_bsns
    count = len(used_bsns)
    del used_bsns[:]
    logging.info("List of %d generated BSNs has been cleared." % count)


@deco.keyword('Exclude BSNs')
def exclude_bsns(bsnlist):
    """
    Excludes BSNs from being generated from the moment it is used until the end of the test run or until `Clear
    Excluded BSNs` is used. It will combine `bsnlist` with previously excluded BSNs. If you need `bsnlist` to replace
    previously excluded BSNs, use `Clear Excluded BSNs` first.

    `bsnlist` is the list of BSNs to be excluded

    == Example ==

    | ${bsnlist}= | Create List | 267227607 | 307684945 | 643897100 |
    | Exclude BSNs | ${bsnlist} |
    """
    global excluded_bsns
    if type(bsnlist) is not list:
        raise ValueError("Input for argument bsnlist is not a list.")
    excluded_bsns = bsnlist + list(set(excluded_bsns) - set(bsnlist))


@deco.keyword('Clear Excluded BSNs')
def clear_excluded_bsns():
    """
    Clears list of excluded BSNs and ends the scope of `Exclude BSNs`. See also `Scope of uniqueness and exclusion`.
    """
    global excluded_bsns
    del excluded_bsns[:]
    logging.info("The list of excluded BSNs has been cleared.")


@deco.keyword('Get Excluded BSNs')
def get_excluded_bsns():
    """
    Gets the list of excluded BSNs to inspect it for troubleshooting purposes.
    """
    return excluded_bsns
