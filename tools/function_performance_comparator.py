# # Example usage:
# def add(a, b):
#     return a + b

# def multiply(a, b):
#     return a * b

# def subtract(a, b):
#     return a - b

# comparator = FunctionPerformanceComparator()
# comparator(add, multiply, subtract, 2, 3)

# FunctionPerformanceComparator.compare_performance(add, multiply, subtract, 2, 3)

# compare_performance(add, multiply, subtract, 2, 3, iterations=1.0e6)

# # Output:
# # subtract is fastest: 1.16e-02 seconds over 100000 iterations
# # multiply is slower : 1.24e-02 seconds over 100000 iterations
# #      add is slower : 2.49e-02 seconds over 100000 iterations

import timeit
from typing import Any, Callable, List, Tuple


class FunctionPerformanceComparator:

    def __call__(self, *args, **kwargs) -> None:
        functions: List[Callable] = [arg for arg in args if callable(arg)]
        arguments: List[Any] = [arg for arg in args if not callable(arg)]

        iterations: int = int(kwargs.pop("iterations", 100000))
        assert iterations <= 1e6, "Max iterations allowed is 1e6"
        execution_times: List[Tuple[str, float]] = []

        for function in functions:
            time: float = timeit.timeit(lambda: function(*arguments, **kwargs), number=iterations)
            execution_times.append((function.__name__, time))

        execution_times.sort(key=lambda x: x[1])

        # Print the result
        name_max_len: int = max(len(item[0]) for item in execution_times)
        for i, (function_name, exec_time) in enumerate(execution_times):
            speed_status: str = 'fastest' if i == 0 else 'slower'
            print(
                f"{function_name:>{name_max_len}s} is {speed_status:<7s}: {exec_time:.2e} seconds over {iterations} iterations"
            )

    @classmethod
    def compare_performance(cls, *args, **kwargs) -> None:
        comparator = cls()
        comparator(*args, **kwargs)


def compare_performance(*args, **kwargs) -> None:
    FunctionPerformanceComparator.compare_performance(*args, **kwargs)
