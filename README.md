# BSNLibrary for Robot Framework

Robot Framework Library for generating a random BSN (Burger Service Nummer, i.e. a
Dutch citizen service number) for test purposes.

A BSN is used in Netherlands to identify a person for government organisations, see
[this information of the Dutch government](https://www.government.nl/topics/personal-data/citizen-service-number-bsn).
The number consists of 9 digits and has to pass the eleven test.

This test can be explained with the example 211551557. Each digit is multiplied with
its position and the results are added up together:

``(9*2) + (8*1) + (7*1) + (6*5) + (5*5) + (4*1) + (3*5) + (2*5) - (1*7) = 110``

Note that the digit in position 1 is subtracted from the other results. The total
sum can be divided by 11, which means that this number has passed the eleven test.

This library generates BSNs for test purposes in the sense that it generates random
9 digit numbers that pass the eleven test. By coincidence a generated number could
be a real person's BSN. Yet this library cannot violate such a person's privacy,
because it cannot tell you whether a number belongs to a real person or not, nor
will it provide you with any personal data related to a BSN. Obviously you should
only use this library in test environments.

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

## Backward compatibility
BSNLibrary v1.0.0 and later is not compatible with previous versions in the sense that is does not allow you to 
validate a BSN with _Generate BSN_. You should use _Validate BSN_ instead. If your test suite still uses _Generate 
BSN_ for validation it will generate an error saying that the length of ``given`` exceeds the maximum value. In case 
you have test suites using _Generate BSN_ for validation you can install BSNLibrary v0.4.0 for a smooth transition: 

``pip install robotframework-bsnlibrary==0.4.0``

Your test suite will still run, but you will receive a warning of any deprecated use of _Generate BSN_ and a 
recommendation to replace it with the keyword _Validate BSN_. This allows you to convert your test suites at your own 
pace. 

## Installation
``pip install robotframework-bsnlibrary``

## General information
[Keyword documentation](https://haaihenkie.github.io/bsnlibrary/)

[Installation package on PyPI](https://pypi.org/project/robotframework-bsnlibrary/)

[Release notes](https://github.com/HaaiHenkie/bsnlibrary/releases)

Create date: 01-03-2020

Author: Henk van den Akker
