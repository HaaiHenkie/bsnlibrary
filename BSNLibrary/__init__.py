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

== Backward compatibility ==
BSNLibrary v1.0.0 and later is not compatible with previous versions in the sense that is does not allow you to
validate a BSN with `Generate BSN`. You should use `Validate BSN` instead. If your test suite still uses `Generate
BSN` for validation it will generate an error saying that the length of ``given`` exceeds the maximum value. In case
you have test suites using `Generate BSN` for validation you can install BSNLibrary v0.4.0 for a smooth transition:

``pip install robotframework-bsnlibrary==0.4.0``

Your test suite will still run, but you will receive a warning of any deprecated use of `Generate BSN` and a
recommendation to replace it with the keyword `Validate BSN`. This allows you to convert your test suites at your own
pace.

== Installation ==
``pip install robotframework-bsnlibrary``

Apart from the library files, the following files are installed

| *File* | *Description* |
| <python dir>/Lib/site-packages/BSNLibrary/docs/index.html | Local copy of this keyword documentation |
| <python dir>/Lib/site-packages/BSNLibrary/tests/BSNLibrary_test/ | Robot Framework (v3.1 or later) test suite for testing BSNLibrary |
| <python dir>/Lib/site-packages/BSNLibrary/tests/BSNLibrary_test_old_syntax/ | Robot Framework (v3.1 or earlier) the same test suite for testing BSNLibrary with the old ``:FOR`` loop syntax |

== General information ==

[https://pypi.org/project/robotframework-bsnlibrary/|Installation package on PyPI]

[https://github.com/HaaiHenkie/bsnlibrary|GitHub repository]

[https://github.com/HaaiHenkie/bsnlibrary/releases|Release notes]

Create date: 01-03-2020

Author: Henk van den Akker

License: MIT License (Expat)

= Scope of uniqueness and exclusion =
`Generate BSN` will by default generate a unique BSN every time it is used throughout the test run. After using
`Exclude BSNs` with a list of BSNs, `Generate BSN` will exclude those BSNs every time it is used until the end of the
test run. These are the normal scopes for uniqueness and exclusion and they are suitable for most purposes. The
following information is relevant for the few cases that need a smaller or larger scope.

== Reducing the scope ==
Uniqueness is established by a list of generated BSNs. Every time `Generate BSN` is used it will exclude the BSNs on
this list and add the generated BSN to this list. The scope of uniqueness and exclusion can be ended by clearing the
list of generated BSNs and the list of excluded BSNs respectively. So to limit, for example, the scope of uniqueness
to a suite, use `Clear Generated BSNs` in the teardown of the suite and of the previous suite. Suppose you need each
test to have its own set of excluded BSNs, use `Exclude BSNs` in de setup of each test and `Clear Excluded BSNs` in
the teardown of each test.

== Extending the scope ==
It is possible to extend the scope of uniqueness of BSNs over test runs with `Get Generated BSNs` and `Get Excluded
BSNs` at the end of the test run and appending this list to a file. Then at the start of a test run read the list
from the file and offer it as input to `Exclude BSNs`. However, you cannot do this infinitely, because after a
certain amount of repetitions the list of excluded BSNs will be so large that it will lead to performance or other
problems. The BSNLibary_test suite, see `Installation`, contains example 'Extending the scope of uniqueness beyond
one test run' under '3 Demos'.

= Troubleshooting =
Most exceptions are self-explanatory. The BSNLibary_test suite, see `Installation`, demonstrates how  BSNLibrary
exceptions can be reproduced.

The following exception (with example counts and arguments) needs more explanation:

| 'Generate BSN' was not able to generate a unique BSN after 1000 retries. You have generated 900 out of the 900 or
| 901 unique BSNs that are permitted by 9 excluded BSNs and arguments given=12345 and length=9.

This means that all or more than 99% of all possible BSNs within the given restrictions have been generated. For
further insight you could use `Get Generated BSNs` and `Get Excluded BSNs` to log those lists just before this
exception occurs. The exception only counts generated and excluded BSNs that could have been generated with the
current arguments.

Possible solutions are:
- Use ``unique=False`` if you do not need unique BSNs
- Use a smaller scope for uniqueness and exclusion, see `Reducing the scope`
- Limit the length of ``given`` and/or avoid using the same value for ``given`` repeatedly
- Reduce the list of excluded BSNs

`Generate BSN` generates numbers randomly and is not suitable for generating all possible numbers in a range of 10000
or more number. If you want to find all BSNs in a range, divide the range in smaller ranges of 100 numbers and loop
through those ranges. The BSNLibary_test suite, see `Installation`, contains example 'Finding all BSNs in a range'
under '3 Demos'.

There is a similar second exception (again with example counts and arguments)

| 'Generate BSN' was not able to generate a BSN outside the list of excluded BSNs after 1000 retries. You have
| excluded 909 out of the 909 or 910 BSNs that are permitted by arguments given=12345 and length=9.

In this case only the last two possible solutions apply. Unless your were intentionally trying to do the impossible,
I would like you [https://github.com/HaaiHenkie/bsnlibrary/issues/new|to log] how you ended up with this last
exception, so that I have anecdotal evidence that I did not include this exception for nothing.

If you experience slow performance this is probably caused by a large number of both generated BSNs and excluded BSNs
that have used a large percentage of all BSNs that are permitted by current arguments. The possible solutions are the
same as for the exceptions above.

When you are not able to resolve a problem regarding BSNLibrary,
[https://github.com/HaaiHenkie/bsnlibrary/issues/new|register an issue].
"""

import random
import textwrap
from BSNLibrary import exceptions
from robot.api import deco
import logging

__version__ = '1.1.0'
ROBOT_LIBRARY_SCOPE = 'GLOBAL'
VALID_LENGTH = {6, 7, 8, 9}
used_bsns = []
excluded_bsns = []


@deco.keyword('Generate BSN')
def generate_bsn(given="", length=9, unique=True):
    """
    Generates a number between 100000000 and 799999999 that passes the eleven test. By default this BSN is unique
    within a test run and is added to a list that can be accessed with `Get Generated BSNs`. It will not generate
    numbers specified with `Exclude BSNs`. As of BSNLibrary version 1.0.0 it is not possible to use this keyword
    for validation of BSNs anymore. Use `Validate BSN` instead.

    ``given`` argument can be used to specify the first digits of the number to be generated, thus
    restricting the range within which the number is generated.
    - To generate a number outside the default range, specify 0, 8 or 9 as the first digit
    - To generate an invalid number, specify '999' as the first three digits
    - The ``given`` string can only contain digits
    - The maximum number of digits is ``length - 2``

    ``length`` argument can be used to generate a number of less than 9 positions, for example to test a situation
    where it is permitted to leave out leading zeroes or a situation where this is not permitted.
    - Only values 6, 7, 8 or 9 are allowed

    If ``unique`` is given a ``False`` value the keyword no longer enforces that the generated BSN is unique within a
    test run, nor will it add the generated number to the list of generated BSNs. Can be used in situations that
    uniqueness is not a requirement and enforcing it leads to problems.

    Examples:
    | ${bsn1} = | Generate BSN | | # Generates a valid BSN between 100000000 and 799999999. |
    | Validate BSN | ${bsn1} | | # Validates the generated valid BSN. |
    | ${bsn2} = | Generate BSN | 85 | # Generates a valid BSN with '85' as the first 2 digits. |
    | ${bsn3} = | Generate BSN | 9994 | # Generates an invalid BSN. |
    | Validate BSN | ${bsn3} | | # Validates the generated invalid BSN. |
    | ${bsn4} = | Generate BSN | length=8 | # Generates a BSN with 8 positions. |
    =>
    | ${bsn1} = 771052066
    | INFO : The BSN '771052066' is valid.
    | ${bsn2} = 853380107
    | ${bsn3} = 999450437
    | FAIL : The given number '999450437' is not a valid BSN.
    | ${bsn4} = 30340731
    """
    given = str(given)
    given_length = len(given)
    try:
        length = int(length)
    except (TypeError, ValueError) as e:
        e.args = ("Value for length must be 6, 7, 8 or 9.",)
        raise
    if length not in VALID_LENGTH:
        raise ValueError("Value for length must be 6, 7, 8 or 9.")
    max_length = length - 2
    if given_length > max_length:
        raise exceptions.GivenNumberWrongLength(textwrap.dedent("""\
            The length of the given number, %d digits, exceeds the maximum value. This maximum value equals 
            'length' argument - 2, in this case %d - 2 = %d.""" % (given_length, length, max_length)))
    if str(unique).lower() in ('false', 'none', 'no', 'off', '0') or given_length == length:
        unique = False
    else:
        unique = bool(unique)
    power = length - given_length
    all_numbers = 10 ** power
    min_numbers = int(all_numbers / 11)
    if given[:3] == "999":
        min_numbers = all_numbers - min_numbers - 1
    excluded_matches = sum(e[:given_length] == given and len(e) == length for e in excluded_bsns)
    if unique:
        generated_bsn = _check_uniqueness(given, length, given_length, excluded_matches, min_numbers)
    else:
        generated_bsn = _check_exclusion(given, length, given_length, excluded_matches, min_numbers)
    return generated_bsn


def _check_uniqueness(given, length, given_length, excluded_matches, min_numbers):
    global used_bsns
    generated_bsn = ""
    min_possible = min_numbers - excluded_matches
    max_possible = min_possible + 1
    iteration = 0
    while generated_bsn == "" or generated_bsn in used_bsns:
        iteration += 1
        if iteration == 1001:
            used_matches = sum(e[:given_length] == given and len(e) == length for e in used_bsns)
            raise exceptions.FailedToGenerateAllowedBSN(textwrap.dedent("""\
                'Generate BSN' was not able to generate a unique BSN after 1000 retries. You have generated %d 
                out of the %d or %d unique BSNs that are permitted by %d excluded BSNs and arguments given=%s 
                and length=%d. See section Troubleshooting on web page https://haaihenkie.github.io/bsnlibrary/ 
                for possible solutions.""" % (used_matches, min_possible, max_possible, excluded_matches, given,
                                              length)))
        generated_bsn = _check_exclusion(given, length, given_length, excluded_matches, min_numbers)
    used_bsns.append(generated_bsn)
    return generated_bsn


def _check_exclusion(given, length, given_length, excluded_matches, min_numbers):
    generated_bsn = ""
    max_numbers = min_numbers + 1
    iteration = 0
    while generated_bsn == "" or generated_bsn in excluded_bsns:
        iteration += 1
        if iteration == 1001:
            raise exceptions.FailedToGenerateAllowedBSN(textwrap.dedent("""\
                'Generate BSN' was not able to generate a BSN outside the list of excluded BSNs after 1000 
                retries. You have excluded %d out of the %d or %d BSNs that are permitted by arguments given=%s 
                and length=%d. See section Troubleshooting on web page https://haaihenkie.github.io/bsnlibrary/ 
                for possible solutions.""" % (excluded_matches, min_numbers, max_numbers, given, length)))
        generated_bsn = _generate_validate(given, length, given_length)
    return generated_bsn


def _generate_validate(given, length, given_length):
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
                e.args = ("Character '%s' is not a digit. Only use digits as part of a BSN." % d,)
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
        if given_length == length:
            if digit1 != mod:
                raise exceptions.NumberNotValid("The given number '%s' is not a valid BSN." % given)
        elif mod == 10:
            # logging.info("REMAINDER 10 GENERATION PATH: generated string '%s'." % generated_bsn)
            sum_product = sum_product - digit2 * 2
            generated_bsn = generated_bsn[:-1]
            digit2 = _exclude_digit(digit2)
            generated_bsn += str(digit2)
            sum_product = sum_product + digit2 * 2
            mod = sum_product % 11
            digit1 = mod
        else:
            digit1 = mod
    generated_bsn += str(digit1)
    return generated_bsn


def _exclude_digit(digit):
    new = digit
    while new == digit:
        new = random.randint(0, 9)
    return new


@deco.keyword('Validate BSN')
def validate_bsn(bsn):
    """
    Validates the given BSN, i.e. checks if it passes the eleven test.

    ``bsn`` argument is a string of 6, 7, 8 or 9 digits

    Examples:
    | Validate BSN | 627708195 | # Validation of a valid BSN. |
    | Validate BSN | 566709883 | # Validation of an invalid BSN. |
    =>
    | INFO : The BSN '627708195' is valid.
    | FAIL : The given number '566709883' is not a valid BSN.
    """
    bsn = str(bsn)
    length = len(bsn)
    if length not in VALID_LENGTH:
        raise ValueError("Length of BSN can only be 6, 7, 8 or 9 digits.")
    _generate_validate(bsn, length, length)
    logging.info("The BSN '%s' is valid." % bsn)


@deco.keyword('Get Generated BSNs')
def get_generated_bsns():
    """
    Returns a list of unique BSNs that are generated with `Generate BSN` within the current test run. It can be used
    to create such a list or to inspect the current list for troubleshooting purposes.

    Example:
    | Clear Generated BSNs |                    |          |   | # Clears BSNs generated so far  |
    | FOR                  | ${i}               | IN RANGE | 3 |                                 |
    |                      | Generate BSN       |          |   | # Do not use ``unique=False``   |
    | END                  |                    |          |   | # for no list will be generated |
    | ${generated_bsns} =  | Get Generated BSNs |          |   | # A list of 3 unique BSNs       |
    =>
    | INFO : List of 0 generated BSNs has been cleared.
    | INFO : ${generated_bsns} = ['143828654', '123095141', '189392307']
    """
    return used_bsns


@deco.keyword('Clear Generated BSNs')
def clear_generated_bsns():
    """
    Clears the list of BSNs generated by `Generate BSN` with argument ``unique=True``. See in `Scope of uniqueness and
    exclusion` how this can be used to reduce the scope of uniqueness.

    Example:
    | FOR                  | ${i}               | IN RANGE | 3 |
    |                      | Generate BSN       |
    | END                  |                    |
    | ${generated_bsns} =  | Get Generated BSNs |
    | Clear Generated BSNs |                    |
    | ${generated_bsns} =  | Get Generated BSNs |
    =>
    | INFO : ${generated_bsns} = ['514169138', '287516635', '715755407']
    | INFO : List of 3 generated BSNs has been cleared.
    | INFO : ${generated_bsns} = []
    """
    global used_bsns
    count = len(used_bsns)
    del used_bsns[:]
    logging.info("List of %d generated BSNs has been cleared." % count)


@deco.keyword('Exclude BSNs')
def exclude_bsns(bsnlist):
    """
    Excludes BSNs from being generated from the moment it is used until the end of the test run or until `Clear
    Excluded BSNs` is used. It will combine ``bsnlist`` with previously excluded BSNs. If you need ``bsnlist`` to
    replace previously excluded BSNs, use `Clear Excluded BSNs` first.

    ``bsnlist`` is a single BSN or a list of BSNs to be excluded

    Example:
    | ${bsnlist} =       | Create List       | 267227607 | 307684945 | 643897100 |
    | Exclude BSNs       | ${bsnlist}        |
    | Exclude BSNs       | 501840151         |
    | ${excluded_bsns} = | Get Excluded BSNs |
    =>
    | INFO : ${bsnlist} = ['267227607', '307684945', '643897100']
    | INFO : ${excluded_bsns} = ['501840151', '307684945', '267227607', '643897100']
    """
    global excluded_bsns
    if type(bsnlist) is not list:
        bsn = bsnlist
        bsnlist = [bsn]
    excluded_bsns = bsnlist + list(set(excluded_bsns) - set(bsnlist))


@deco.keyword('Clear Excluded BSNs')
def clear_excluded_bsns():
    """
    Clears list of excluded BSNs and ends the scope of `Exclude BSNs`. See also `Scope of uniqueness and exclusion`.

    Example:
    | ${bsnlist} =        | Create List       | 469641459 | 376670149 | 671472847 |
    | Exclude BSNs        | ${bsnlist}        |
    | ${excluded_bsns} =  | Get Excluded BSNs |
    | Clear Excluded BSNs |
    | ${excluded_bsns} =  | Get Excluded BSNs |
    =>
    | INFO : ${bsnlist} = ['469641459', '376670149', '671472847']
    | INFO : ${excluded_bsns} = ['469641459', '376670149', '671472847']
    | INFO : The list of excluded BSNs has been cleared.
    | INFO : ${excluded_bsns} = []
    """
    global excluded_bsns
    del excluded_bsns[:]
    logging.info("The list of excluded BSNs has been cleared.")


@deco.keyword('Get Excluded BSNs')
def get_excluded_bsns():
    """
    Gets the list of excluded BSNs to inspect it for troubleshooting purposes.

    Example:
    | ${bsnlist} =        | Create List       | 423932020 | 107004422 | 233354773 |
    | Exclude BSNs        | ${bsnlist}        |
    | ${excluded_bsns} =  | Get Excluded BSNs |
    =>
    | INFO : ${bsnlist} = ['423932020', '107004422', '233354773']
    | INFO : ${excluded_bsns} = ['423932020', '107004422', '233354773']
    """
    return excluded_bsns
