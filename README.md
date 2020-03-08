# BSNLibrary for Robot Framework

Robot Framework Library for generating a random BSN (Burger Service Nummer, i.e. a
Dutch citizen service number)

A BSN is used in Netherlands to identify a person for governmental organisations.
The number consists of 9 digits and has to pass the eleven test.

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

Create date: 01-03-2020

Author: Henk van den Akker
