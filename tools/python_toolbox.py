#!/usr/bin/env python

import functools
import logging
import os
from collections.abc import Mapping
from inspect import Traceback, currentframe, getframeinfo, stack
from types import FrameType
from typing import *
from typing import Optional, Type

import numpy as np

try:
    from arepl_dump import dump
except ImportError:

    def dump(*args, **kwargs):
        pass


from omegaconf import DictConfig
from PyQt5.QtCore import QMutex, pyqtBoundSignal, pyqtSignal

# Set True to log messages to console:
global DEBUG_ENABLED
DEBUG_ENABLED: bool = False
DEBUG_ENABLED = True

# Set True to log color-coded messages:
global LOG_COLORS
LOG_COLORS: bool = False
LOG_COLORS = True


# region Custom Logging

logging.addLevelName(level=logging.INFO + 1, levelName="SUCCESS")
logging.addLevelName(level=logging.INFO + 2, levelName="FAILURE")
logging.addLevelName(level=logging.CRITICAL + 10, levelName="FLAG")

DEBUG: int = logging.DEBUG
INFO: int = logging.INFO
SUCCESS: int = logging.getLevelName("SUCCESS")
FAILURE: int = logging.getLevelName("FAILURE")
WARNING: int = logging.WARNING
ERROR: int = logging.ERROR
FATAL: int = logging.FATAL
CRITICAL: int = logging.CRITICAL
FLAG: int = logging.getLevelName("FLAG")

logging.captureWarnings(True)


def setup_logger(
    cfg: Optional[DictConfig] = None, root_logger: bool = False
) -> Optional[logging.Logger]:
    """Creates a logging.Logger object to use across various scripts/modules. You must pass root_logger=True if you want to have console reporting. Pass cfg.logging hydra config to customize formatting, date format, etc.

    Args:
        cfg (Optional[DictConfig], optional): cfg.logging (hydra) to control message/date formatting. If None, basic defaults are set. Defaults to None.
        root_logger (bool, optional): Flag to indicate a root logger is requested. Defaults to False.

    Returns:
        Optional[logging.Logger]: object to generate log messages
    """
    if not DEBUG_ENABLED:
        return

    caller_scriptname: str = os.path.basename(
        getframeinfo(stack()[1][0]).filename
    ).split(".")[0]
    if cfg is None:
        cfg = DictConfig(
            content={
                "name": __file__,
                "level": logging.DEBUG,
                "format": "[%(asctime)s] [%(levelname)-8s] - %(message)s",
                "date_format": "%Y-%m-%d %H:%M:%S",
            },
        )

    custom_logger: logging.Logger
    if root_logger:
        for handle in logging.getLogger().handlers:
            logging.getLogger().removeHandler(handle)
        custom_logger = logging.getLogger()
        custom_logger.name = caller_scriptname
    else:
        custom_logger = logging.getLogger(cfg.name)
        custom_logger.parent = logging.getLogger(caller_scriptname)

    file_handler: Optional[logging.FileHandler] = None
    if "out_file" in cfg:
        file_formatter = logging.Formatter(
            fmt=cfg.format, datefmt=cfg.date_format)
        file_handler = logging.FileHandler(filename=cfg.out_file, mode="w")
        file_handler.setLevel(cfg.level)
        file_handler.setFormatter(file_formatter)

    stream_handler: Optional[logging.StreamHandler] = None
    if root_logger:
        if LOG_COLORS:
            stream_formatter = LogMessageColorFormatter(
                fmt=cfg.format, datefmt=cfg.date_format
            )
        else:
            stream_formatter = logging.Formatter(
                fmt=cfg.format, datefmt=cfg.date_format
            )
        stream_handler = logging.StreamHandler()
        stream_handler.setLevel(cfg.level)
        stream_handler.setFormatter(stream_formatter)

    if file_handler is not None:
        custom_logger.addHandler(file_handler)
    if stream_handler is not None:
        custom_logger.addHandler(stream_handler)

    custom_logger.propagate = not root_logger
    custom_logger.setLevel(cfg.level)

    return custom_logger


class Colors:

    """ANSI color codes for logging to console."""

    BLACK = "\033[0;30m"
    RED = "\033[0;31m"
    GREEN = "\033[0;32m"
    BROWN = "\033[0;33m"
    BLUE = "\033[0;34m"
    PURPLE = "\033[0;35m"
    CYAN = "\033[0;36m"
    LIGHT_GRAY = "\033[0;37m"
    DARK_GRAY = "\033[1;30m"
    LIGHT_RED = "\033[1;31m"
    LIGHT_GREEN = "\033[1;32m"
    YELLOW = "\033[1;33m"
    LIGHT_BLUE = "\033[1;34m"
    LIGHT_PURPLE = "\033[1;35m"
    LIGHT_CYAN = "\033[1;36m"
    LIGHT_WHITE = "\033[1;37m"
    BOLD = "\033[1m"
    FAINT = "\033[2m"
    ITALIC = "\033[3m"
    UNDERLINE = "\033[4m"
    BLINK = "\033[5m"
    NEGATIVE = "\033[7m"
    CROSSED = "\033[9m"
    END = "\033[0m"

    @classmethod
    def test(cls):
        """Prints all ANSI color codes to console."""
        for _ in dir(cls):
            if isinstance(_, str) and _[0] != "_":
                print(getattr(cls, _), _)
        print(Colors.END)

    # cancel SGR codes if we don't write to a terminal
    if not __import__("sys").stdout.isatty():
        for _ in dir():
            if isinstance(_, str) and _[0] != "_":
                locals()[_] = ""
    else:
        # set Windows console in VT mode
        if __import__("platform").system() == "Windows":
            kernel32 = __import__("ctypes").windll.kernel32
            kernel32.SetConsoleMode(kernel32.GetStdHandle(-11), 7)
            del kernel32


Colors.test()


class LogMessageColorFormatter(logging.Formatter):

    """Custom logging.Formatter class to generate color-coded logging messages."""

    _message_format: str = (
        "[%(asctime)s] [%(levelname)-8s] {%(filename)-32s} - %(message)s"
    )
    _datetime_format: str = "%Y-%m-%d %H:%M:%S"

    def __init__(
        self, fmt: Optional[str] = None, datefmt: Optional[str] = None
    ) -> None:
        """Class initializer.

        Args:
            fmt (Optional[str], optional): message data format. Defaults to None.
            datefmt (Optional[str], optional): datetime format. Defaults to None.
        """
        super().__init__()
        if fmt is not None:
            self._message_format = fmt
        if datefmt is not None:
            self._datetime_format = datefmt

    @property
    def message_format(self) -> str:
        """message_format getter

        Returns:
            str: current message format
        """
        return self._message_format

    @message_format.setter
    def message_format(self, message_format: str) -> None:
        """message_format setter

        Args:
            message_format (str): style for formatting messages in a LogRecord
        """
        self._message_format = message_format

    @property
    def datetime_format(self) -> str:
        """datetime_format getter

        Returns:
            str: current datetime format
        """
        return self._datetime_format

    @datetime_format.setter
    def datetime_format(self, new_datetime_format: str) -> None:
        """datetime_format setter

        Args:
            new_datetime_format (str): style for formatting datetimes in a LogRecord
        """
        self._datetime_format = new_datetime_format

    def get_color_message(self, level_number: int) -> str:
        """generates a color-coded format for a LogRecord's message

        Args:
            level_number (int): logging level

        Returns:
            str: message string formatted with ANSI color codes
        """
        FORMATS: Dict[int, str] = {
            logging.DEBUG: Colors.LIGHT_WHITE + self._message_format + Colors.END,
            logging.INFO: Colors.LIGHT_BLUE + self._message_format + Colors.END,
            logging.getLevelName("FAILURE"): Colors.RED
            + Colors.BOLD
            + self._message_format
            + Colors.END,
            logging.getLevelName("SUCCESS"): Colors.GREEN
            + Colors.BOLD
            + self._message_format
            + Colors.END,
            logging.WARNING: Colors.YELLOW
            + Colors.BOLD
            + self._message_format
            + Colors.END,
            logging.ERROR: Colors.RED + Colors.BOLD + self._message_format + Colors.END,
            logging.CRITICAL: Colors.PURPLE
            + Colors.BOLD
            + self._message_format
            + Colors.END,
            logging.getLevelName("FLAG"): Colors.BOLD
            + Colors.LIGHT_RED
            + self._message_format
            + Colors.BLINK
            + Colors.END,
        }  # Colors.NEGATIVE +
        return FORMATS[level_number]

    def format(self, record: logging.LogRecord) -> str:
        """formats a LogRecord message with color

        Args:
            record (logging.LogRecord): logging record to be formatted

        Returns:
            str: formatted message string
        """
        log_fmt: str = self.get_color_message(record.levelno)
        formatter = logging.Formatter(
            fmt=log_fmt, datefmt=self._datetime_format)
        return formatter.format(record)


# endregion Custom Logging

# region UtilsClass


def method_decorator(func: Callable) -> Callable:
    """decorates a class method with func

    Args:
        func (Callable): the decorator function to wrap around the decorated method
    """

    def decorator_wrapper(*args, **kwargs) -> Callable:
        # Apply the function decorator to the method
        decorated_func: Callable = func(*args, **kwargs)
        return decorated_func

    return decorator_wrapper


def class_decorator(decorator_func: Callable) -> Callable[..., Any]:
    """wraps all valid class methods with decorator_func

    Args:
        decorator_func (Callable): the decorator function to wrap around all callables within a class
    """

    def decorator(cls) -> Callable[..., Any]:
        # Iterate over all the attributes of the class
        for attr_name, attr_value in cls.__dict__.items():
            # Check if the attribute is a method
            if callable(attr_value) and not isinstance(
                attr_value, (pyqtSignal, pyqtBoundSignal)
            ):
                # Apply the method decorator to the method
                setattr(cls, attr_name, decorator_func(attr_value))
        return cls

    return decorator


def exception_logger(func: Callable[..., Any]) -> Callable[..., Any]:
    """Decorator to log exceptions raised by methods."""

    @functools.wraps(func)
    def wrapper(*args, **kwargs) -> Any:
        try:
            return func(*args, **kwargs)
        except Exception as e:
            instance: Any = args[0]
            if isinstance(instance, UtilsClass):
                instance.log_message(
                    f"Exception occured:\n\t{e}", logging.ERROR)

    return wrapper


class ExceptionLoggingMeta(type):
    """Metaclass that decorates all methods with exception_logger."""

    def __new__(
        cls: Type["ExceptionLoggingMeta"],
        name: str,
        bases: Tuple[type, ...],
        class_dict: Dict[str, object],
    ) -> "ExceptionLoggingMeta":
        for attr_name, attr_value in class_dict.items():
            if callable(attr_value) and not attr_name.startswith("__"):
                class_dict[attr_name] = exception_logger(attr_value)
        return super().__new__(cls, name, bases, class_dict)


# For memory profiling:
# @class_decorator(profile)


class UtilsClass(metaclass=ExceptionLoggingMeta):

    """Gives child classes access to commonly used methods for logging, formatting, etc."""

    _logger: Optional[logging.Logger] = None

    # region Class Properties
    @property
    def logger(self) -> Optional[logging.Logger]:
        """Returns the logger object used by the class

        Returns:
            logger: Optional[logging.Logger]
        """
        return self._logger

    @logger.setter
    def logger(self, new_logger: Optional[logging.Logger]) -> None:
        """Set the logger for the class

        Arguments:
            new_logger: Optional[logging.Logger] -- logger desired
        """
        if new_logger is None:
            return
        self._logger = new_logger

    @logger.deleter
    def logger(self) -> None:
        """Sets the logger to None"""
        self._logger = None

    # endregion Class Properties

    @staticmethod
    def _get_frame_info() -> Tuple[str, str, int]:
        """Extracts frame info to be used for logging.

        Returns:
            Tuple: filename (str), method_name (str), line_number (int)
        """
        curr_frame: Optional[FrameType] = currentframe()
        frame: Optional[FrameType] = curr_frame and curr_frame.f_back

        frame_info: Traceback = Traceback("", 0, "", [""], 0)
        method_name: str = ""
        invalid_fxns: List[str] = [
            "print_status",
            "log_message",
            "iterdict",
            "get_frame_info",
            "wrapper",
        ]
        while frame:
            frame_info = getframeinfo(frame)
            method_name = frame_info.function

            if any(invalid_fxn in method_name.lower() for invalid_fxn in invalid_fxns):
                frame = frame.f_back
            else:
                break

        if frame:
            return os.path.basename(frame_info.filename), method_name, frame_info.lineno
        else:
            return "", "", 0

    @staticmethod
    def log_message(
        status_msg: str,
        severity_level: int = DEBUG,
        logger: Optional[logging.Logger] = None,
    ) -> None:
        """Logs message via logging module."""
        if not DEBUG_ENABLED:
            return
        filename: str
        method_name: str
        lineno: int
        filename, method_name, lineno = UtilsClass._get_frame_info()

        msg: str = f"{f'{{{filename}}} - {method_name}:{lineno}':>64} - {status_msg}"

        target_logger: Union[logging.Logger, logging.RootLogger] = (
            logger or logging.getLogger().root
        )
        target_logger.log(level=severity_level, msg=msg)

    def _print_status(self, status_msg: str, severity_level: int = DEBUG) -> None:
        """Internal class logging implementation. Logs message via logging module with class-specific context."""
        if not DEBUG_ENABLED:
            return
        if not self.logger:
            self.logger = logging.getLogger().root
        filename: str
        method_name: str
        lineno: int
        filename, method_name, lineno = self._get_frame_info()
        msg: str = f"{f'{{{filename}}} - {self.__class__.__name__}.{method_name}:{lineno}':>64} - {status_msg}"

        self.log_message(msg, severity_level, self.logger)

    def iterdict(self, d: Dict, level: int = 0) -> None:
        """Recursively logs the information of a dictionary with each level tabbed once more. Note: if numpy array is dictionary value, only the shape is printed.

        Arguments:
            d -- dictionary to be printed (dict)

        Keyword Arguments:
            level -- Not user-specified. Used as tab depth.
        """
        for k, v in d.items():
            if isinstance(v, dict):
                self._print_status("\t" * level + f"{k}")
                level += 1
                self.iterdict(v, level)
                level -= 1
            else:
                if isinstance(v, np.ndarray):
                    self._print_status("\t" * level + f"{k}: {v.shape}")
                else:
                    self._print_status("\t" * level + f"{k}: {v}")


# endregion UtilsClass

# region Utility Functions


class LockCompatibleQMutex(QMutex):
    """Wrapper class to make QMutex compatible with threading.Lock methods.

    Detailed description: if you have a QMutex object, you can't use the threading.Lock methods acquire() and release(). This class is a wrapper around QMutex that allows you to use those methods.
    """

    def __init__(self, *args, **kwargs) -> None:
        super().__init__(*args, **kwargs)

    def acquire(self) -> None:
        super().lock()

    def release(self) -> None:
        super().unlock()

    def locked(self, timeout: int = ...) -> bool:
        """Returns True if the mutex is currently locked, False otherwise.

        Args:
            *args: timeout value to pass to QMutex.isLocked()

        Returns:
            bool: True if the mutex is currently locked, False otherwise.
        """
        return super().tryLock(timeout)

    def __enter__(self) -> bool:
        self.acquire()
        return True

    def __exit__(self, *args) -> None:
        """
        Args:
            exc_type: Optional[type[BaseException]]
            exc_value: Optional[BaseException]
            traceback: Optional[TracebackType]
        """
        self.release()


def _get_keys(value_from: Any, this_map: Mapping) -> List[Optional[str]]:
    """Private prototype. Returns keys of a dictionary-like object (this_map) corresponding to value (val).
    \n\nReturns an empty list if no matches are found.

    Args:
        value_from (Any): Value to search for in dictionary
        this_map (Mapping object): Dictionary-like object within which to search for value_from

    Returns:
        List[Optional[str]]: List of keys corresponding to value_from. Empty list if no matches are found.
    """
    if not isinstance(this_map, Mapping):
        raise TypeError(
            f"this_map must be a dictionary-like, not {type(this_map)}")
    if value_from not in this_map.values():
        raise UserWarning(f"{value_from} not found in {this_map.values()}")
    return [
        key
        for key, value in this_map.items()
        if value_from == value and key is not None
    ]


def get_key(value_from: Any, this_map: Any) -> Optional[str]:
    """Returns first key of a dictionary-like object (this_map) corresponding to value (val).\n\nReturns None if no matches are found.

    Args:
        value_from (Any): Value to search for in dictionary
        this_map (Dict[Any, Any]): Dictionary to search for value

    Returns:
        Optional[str]: First key corresponding to value. None if no match found.
    """
    return (
        _get_keys(value_from, this_map)[0] if _get_keys(
            value_from, this_map) else None
    )


def get_keys(value_from: Any, this_map: Any) -> List[Optional[str]]:
    """Returns keys of a dictionary-like object (this_map) corresponding to value (val).\n\nReturns an empty list if no matches are found.

    Args:
        value_from (Any): Value to search for in dictionary
        this_map (Dict[Any, Any]): Dictionary to search for value

    Returns:
        List[Optional[str]]: List of keys corresponding to value. Empty list if no matches are found.
    """
    return _get_keys(value_from, this_map)


# endregion Utility Functions

# region Testing


class TestHarness(UtilsClass):
    def __init__(self) -> None:
        super().__init__()
        self.logger = setup_logger(root_logger=True)
        self.run_all_tests()

    def test_logger(self) -> None:
        UtilsClass.log_message("UtilsClass.log_message debug", DEBUG)
        UtilsClass.log_message("UtilsClass.log_message info", INFO)
        UtilsClass.log_message("UtilsClass.log_message success", SUCCESS)
        UtilsClass.log_message("UtilsClass.log_message failure", FAILURE)
        UtilsClass.log_message("UtilsClass.log_message warning", WARNING)
        UtilsClass.log_message("UtilsClass.log_message error", ERROR)
        UtilsClass.log_message("UtilsClass.log_message critical", CRITICAL)
        UtilsClass.log_message("UtilsClass.log_message flag", FLAG)
        self.log_message("self.log_message debug", DEBUG)
        self.log_message("self.log_message info", INFO)
        self.log_message("self.log_message success", SUCCESS)
        self.log_message("self.log_message failure", FAILURE)
        self.log_message("self.log_message warning", WARNING)
        self.log_message("self.log_message error", ERROR)
        self.log_message("self.log_message critical", CRITICAL)
        self.log_message("self.log_message flag", FLAG)
        self._print_status("self._print_status debug", DEBUG)
        self._print_status("self._print_status info", INFO)
        self._print_status("self._print_status success", SUCCESS)
        self._print_status("self._print_status failure", FAILURE)
        self._print_status("self._print_status warning", WARNING)
        self._print_status("self._print_status error", ERROR)
        self._print_status("self._print_status critical", CRITICAL)
        self._print_status("self._print_status flag", FLAG)

    def test_get_key(self) -> None:
        test_dict: Dict[Optional[str], str] = {
            "key1": "value1",
            "key2": "value2",
            "key3": "value3",
            "key4": "value4",
            "key5": "value5",
            None: "value6",
        }
        assert (
            get_key("value1", test_dict) == "key1"
        ), f"{get_key('value1', test_dict) = }"
        assert (
            get_key("value3", test_dict) == "key3"
        ), f"{get_key('value3', test_dict) = }"
        assert (
            get_key("value2", test_dict) == "key2"
        ), f"{get_key('value2', test_dict) = }"
        assert (
            get_key("value4", test_dict) == "key4"
        ), f"{get_key('value4', test_dict) = }"
        assert (
            get_key("value5", test_dict) == "key"
        ), f"{get_key('value5', test_dict) = }"
        assert (
            get_key("value6", test_dict) is None
        ), f"{get_key('value6', test_dict) = }"

    def test_get_keys(self) -> None:
        test_dict: Dict[str, str] = {
            "key1": "value1",  # "key1": "value1",
            "key4": "value4",  # "key2": "value5",
            "key2": "value5",  # "key3": "value5",
            "key3": "value5",  # "key4": "value4",
            "key5": "value5",  # "key5": "value5",
            None: "value6",  # None: "value6",
        }
        try:
            assert get_keys("value1", test_dict) == [
                "key1"
            ], f"{get_keys('value1', test_dict) = }"
            assert get_keys("value4", test_dict) == [
                "key4"
            ], f"{get_keys('value4', test_dict) = }"
            assert get_keys("value5", test_dict) == [
                "key2",
                "key3",
                "key5",
            ], f"{get_keys('value5', test_dict) = }"
            assert (
                get_keys("value6", test_dict) == []
            ), f"{get_keys('value6', test_dict) = }"
        except AssertionError as e:
            raise e

    def test_exception_logger(self) -> None:
        try:
            pass
        except Exception as e:
            raise e

        test_bool: bool = False
        assert test_bool, f"{test_bool = }"

    def run_all_tests(self) -> bool:
        """Runs all tests in this module. Returns True if all tests pass.

        Returns:
            bool: True if all tests pass.
        """
        self.test_logger()
        self.test_get_key()
        self.test_get_keys()
        self.test_exception_logger()
        return True

    def throw_exception(self, x: int) -> int:
        assert isinstance(x, int), f"x must be int, not {type(x)}"
        if x < 0:
            raise ValueError("This is a test exception (ValueError)")
        return x


# endregion Testing


def main() -> None:
    UtilsClass.log_message("This is a test message", severity_level=CRITICAL)
    test_harness: TestHarness = TestHarness()
    test_harness.throw_exception("-1")  # type: ignore
    test_harness.throw_exception(-1)
    test_harness.throw_exception(1)
    test_harness2: TestHarness = TestHarness()
    test_harness2.throw_exception(-10)
    test_harness2.throw_exception(10)


if __name__ == "__main__":
    main()
    UtilsClass.log_message("This is a final message", severity_level=FLAG)
