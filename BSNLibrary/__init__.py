"""
Robot Framework Library for generating a random BSN (Burger Service Nummer, i.e. a
Dutch citizen service number) for test purposes.

A BSN is used in Netherlands to identify a person for government organisations, see
[https://www.government.nl/topics/personal-data/citizen-service-number-bsn|
this information of the Dutch government]. The number consists of 9 digits and has
to pass the eleven test.

This test can be explained with the example 211551557. Each digit is multiplied with
its position and the results are added up together:

``(9*2) + (8*1) + (7*1) + (6*5) + (5*5) + (4*1) + (3*5) + (2*5) - (1*7) = 110``

Note that the digit in position 1 is subtracted from the other results. The total
sum can be divided by 11, which means that this number has passed the eleven test.

This library brings the following features to Robot Framework:
- generating a valid BSN
- generating a BSN that is unique within the current test run
- generating a number that will not pass the eleven test
- generating a BSN that starts with specific digits
- generating a BSN that is less than 9 digits long
- checking if a given number passes the eleven test
- returning a list of BSNs generated during the current test run
- clearing the list of BSNs generated during the current test run

Possible use cases
- A test message that is processed by one or more systems can be tracked by its unique BSN
- Creating messages with BSNs in a certain range that leads to a certain response from a system or stub
- Checking whether a test message contains a valid BSN

[https://haaihenkie.github.io/bsnlibrary/|Keyword documentation]

Create date: 01-03-2020

Author: Henk van den Akker
"""

import random
import textwrap
from BSNLibrary import exceptions
from robot.api import deco
import logging

__version__ = '0.2'
ROBOT_LIBRARY_SCOPE = 'GLOBAL'
VALID_LENGTH = {6, 7, 8, 9}
used_bsns = []


@deco.keyword('Generate BSN')
def generate_bsn(given="", length=9, unique=True):
    """
    Generates a number between 100000000 and 799999999 that passes the eleven test. By default
    this BSN is unique within a test run and is added to a list that can be accessed with Get
    Generated BSNs

    ``given`` argument can be used to specify the first digits of the number to be generated, thus
    restricting the range within which the number is generated.
    - To generate a number outside the default range, specify 0, 8 or 9 as the first digit
    - To validate a number, specify the complete number (the number of digits is equal to ``length``)
    - To generate an invalid number, specify '999' as the first three digits
    - The ``given`` string can only contain digits
    - The number of digits should be smaller than ``length - 1`` or equal to ``length``

    ``length`` argument can be used to generate a number of less than 9 positions, for example
    when a BSN of 8 positions is needed.
    - Only values 6, 7, 8 or 9 are allowed

    If ``unique`` is given a ``False`` value the keyword no longer enforces that the generated
    BSN is unique within a test run, nor will it add the generated number to the list of generated
    BSNs. Can be used in situations that uniqueness is not a requirement and enforcing it leads
    to problems.

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
    if str(unique).lower() in ('false', 'none', 'no', 'off', '0') or given_length == length:
        unique = False
    else:
        unique = bool(unique)
    if length not in VALID_LENGTH:
        raise ValueError("Value for length must be 6, 7, 8 or 9.")
    if given_length > length or given_length == length - 1:
        raise exceptions.GivenNumberWrongLength(textwrap.dedent("""\
            The length of the given number, %d digits, is longer than length, %d, 
            or equal to length - 1. That is not allowed.""" % (given_length, length)))
    if unique:
        generated_bsn = ""
        iteration = 0
        while generated_bsn == "" or generated_bsn in used_bsns:
            iteration += 1
            if iteration == 1000:
                raise exceptions.FailedToGenerateUniqueBSN(textwrap.dedent("""\
                    Keyword Generate BSN was not able to generate an unique BSN after 1000 
                    retries. Possible solutions are:
                    - Use argument unique=False if you do not need unique BSNs 
                    - Use keyword Clear Generated BSNs in the suite or test setup so that 
                      BSNs only need to be unique within scope of the suite or test 
                    - Limit the length of the given argument and/or avoid using the same 
                      given argument repeatedly 
                    - Use keyword Get Generated BSNs in the test teardown to be able to  
                      inspect the BSNs that have been generated during a test run."""))
            generated_bsn = generate_bsn(given, length, False)
        used_bsns.append(generated_bsn)
        return generated_bsn
    else:
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
            if pos == length - 2 and generated_bsn[:1] == "9":
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
    Returns a list of unique BSNs that are generated with the Generate BSN keyword within the current
    test run. It can be used to create such a list or to inspect the current list in case there is a
    problem with creating unique BSNs.

    == Example ==

    | Clear Generated BSNs | | | | | # Clears BSNs generated so far |
    | FOR | ${i} | IN RANGE | 0 | 100 |
    | | Generate BSN | | | | # Do not use unique=False |
    | END | | | | | # for no list will be generated |
    | @{generated_bsn} = | Get Generated BSNs | | | | # A list of 100 unique BSNs |

    """
    return used_bsns


@deco.keyword('Clear Generated BSNs')
def clear_generated_bsns():
    """
    Clears the list of BSNs generated by keyword Generate BSN with argument unique=True. This could
    be used in situations where it is not necessary to enforce unique BSNs throughout the whole test
    run, but enforcing uniqueness within test cases or suites is sufficient. In that case this
    keyword can be used in Suite Setup or Test Setup.
    """
    global used_bsns
    count = len(used_bsns)
    del used_bsns[:]
    logging.info("List of %d generated BSNs has been cleared." % count)
