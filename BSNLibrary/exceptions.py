class Error(Exception):
    """Base class for other exceptions."""
    pass


class GivenNumberWrongLength(Error):
    """Raised when the given string is equal to ``length - 1`` or greater than ``length``."""
    ROBOT_SUPPRESS_NAME = True


class NumberNotValid(Error):
    """Raised when the given number is not a valid BSN."""
    ROBOT_SUPPRESS_NAME = True


class FailedToGenerateUniqueBSN(Error):
    """Raised when after 100 retries no unique BSN could be generated."""
    ROBOT_SUPPRESS_NAME = True