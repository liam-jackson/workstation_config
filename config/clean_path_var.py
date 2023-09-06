from argparse import ArgumentParser
import os
import sys
from collections import OrderedDict
import subprocess
from typing import List, Optional, Tuple

def main(env_var: str, verbose: bool, force_lower: bool) -> Tuple[int, Optional[str]]:
    PASS: int = 0
    FAIL: int = -1
    EXITSTATUS: int = PASS
    paths_new_str: Optional[str] = None
    try:
        if force_lower:
            print(f'Warning: you forced to keep this variable name lowercase: {env_var}',file=sys.stderr)
            env_var = env_var.lower()
        else:
            env_var = env_var.upper()

        paths_old_str: Optional[str] = os.environ.get(env_var, None)
        if paths_old_str is None or len(paths_old_str) == 0:
            print(f'{env_var} was not found!',file=sys.stderr)
            raise Exception(f'{env_var} was not found!')

        if verbose:
            print(f'Condensing {env_var}...',file=sys.stderr)

        paths_old_str = paths_old_str.strip()
        paths_old_str = paths_old_str.strip(':')
        paths_old_list: List[str] = paths_old_str.split(':')
        paths_new_odict = OrderedDict()
        paths_new_odict.update({path: None for path in paths_old_list if os.path.isdir(path)})
        paths_new_list = list(paths_new_odict.keys())
        paths_new_str = ':'.join(paths_new_list)

        # region subprocess export
        # cmd_unset_export_seq: str = f'unset {env_var}'
        # unset_retcode: int = subprocess.run(cmd_unset_export_seq, shell=True, start_new_session=True).returncode
        # if bool(unset_retcode):
        #     print(f'Failed to unset {env_var}!',file=sys.stderr)
        #     raise

        # cmd_unset_export_seq2: str = f'export {env_var}={paths_new_str}'
        # export_retcode: int = subprocess.run(cmd_unset_export_seq2, shell=True, start_new_session=True).returncode
        # if bool(export_retcode):
        #     print(f'Failed to export {env_var}!',file=sys.stderr)
        #     raise
        # endregion subprocess export

        if verbose:
            print_paths_verbose(env_var, paths_old_list, paths_new_list)
        EXITSTATUS = PASS
    except Exception as e:
        print(f'Exception: {e}',file=sys.stderr)
        EXITSTATUS = FAIL
    finally:
        return EXITSTATUS, paths_new_str

def print_paths_verbose(env_var: str, paths_old: List[str], paths_new: List[str]):
    print(f'\nOriginal {env_var}:',file=sys.stderr)
    for old_path in paths_old:
        print(f'\t{old_path = }',file=sys.stderr)

    print(f'\nCondensed {env_var}:',file=sys.stderr)
    for new_path in paths_new:
        print(f'\t{new_path = }',file=sys.stderr)

    cmd_echo_updated_env = f'echo ${env_var}'
    p0: subprocess.CompletedProcess = subprocess.run(
        cmd_echo_updated_env, capture_output=True, shell=True, start_new_session=True
    )
    output= p0.stdout.decode("utf-8")
    print(f'\necho ${env_var}: \n{output}',file=sys.stderr)

    path_fixed: str = output.strip()
    path_fixed: str = path_fixed.strip(':')

    for env_path in path_fixed.split(':'):
        print(f'{env_path = }',file=sys.stderr)


if __name__ == "__main__":
    parser = ArgumentParser(
        prog=os.path.basename(__file__),
        usage='%(prog)s [options]',
        description='Condense an environment variable containing a list of paths, removing duplicates while maintaining their order precedence.',
        prefix_chars='-',
        add_help=True,
    )
    parser.add_argument(
        "-n",
        '--env-var',
        nargs="?",
        default='PATH',
        help='Name of the environment variable to condense. Defaults to PATH.',
        metavar="ENV-VAR",
        dest="env_var",
    )
    parser.add_argument(
        "-V",
        '--verbose',
        help='Whether to output the contents to the terminal. Defaults to False.',
        dest="verbose",
        action='store_true',
    )
    parser.add_argument(
        "-F",
        '--force-lowercase',
        help='If true, an environment variable passed as a lowercase remains lowercase. Defaults to False.',
        dest="force_lower",
        action='store_true',
    )

    args = parser.parse_args(sys.argv[1:])
    exitcode, cleaned_path = main(args.env_var, args.verbose, args.force_lower)
    if exitcode == 0:
        print(f"{cleaned_path}",file=sys.stdout)
    else:
        sys.exit(exitcode)