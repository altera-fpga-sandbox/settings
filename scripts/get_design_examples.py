#! /usr/bin/env python

import re
import json
import os
import requests
import optparse
import sys
import logging
import base64
from pathlib import Path
from urllib.parse import urlparse, parse_qs, urlunparse


VERSION = '1.0'

DEFAULT_USAGE_TEXT = ("""
===============================================================================================
Usage: %prog [options] arg
Tool to get design examples
===============================================================================================
""")

LIST_JSON = "list.json"

def get_design_examples(options):
  print("get_design_examples")

def check_prerequisite(options):
    if options.output:
        output_dir = Path(options.output).parent
        if not output_dir.exists():
            try:
                output_dir.mkdir(parents=True, exist_ok=True)
            except Exception as e:
                logging.error(f"Error encountered while attempting to create output directory '{output_dir}': {e}")
                exit(1)
    else:
        # If --output is not defined, we will use the current working directory as default list.json.
        options.output = os.path.join(os.getcwd(), LIST_JSON)


def configure_logging(silent=False, log_file=None):
    handlers = []

    if not silent:
        handlers.append(logging.StreamHandler(sys.stdout))

    if log_file:
        log_dir = Path(log_file).parent
        if not log_dir.exists():
            try:
                log_dir.mkdir(parents=True, exist_ok=True)
            except Exception as e:
                logging.error(f"Error encountered while attempting to create log directory '{log_dir}': {e}")
                exit(1)

        file_handler = logging.FileHandler(log_file, mode='w')
        file_handler.setFormatter(logging.Formatter(LOG_FORMAT))
        handlers.append(file_handler)

    logging.basicConfig(level=logging.INFO, format=LOG_FORMAT, handlers=handlers)


def close_logging():
    for handler in logging.getLogger().handlers[:]:
        handler.close()
        logging.getLogger().removeHandler(handler)


def main(argv):
    option_parser = optparse.OptionParser(usage=DEFAULT_USAGE_TEXT, version=VERSION)

    option_parser.add_option("-o", "--output", dest="output", action="store", default="", help="The output file full path to store the consolidation of all the list.json after scanning all the directories. Optional.")
    option_parser.add_option("-l", "--log", dest="log", action="store", default="", help="The log file full path. If this is specified, the log will be piped to the file. Optional.")
    option_parser.add_option("-s", "--silent", dest="silent", action="store_true", default=False, help="Set this to true to avoid printing to STDOUT. Optional.")

    options, args = option_parser.parse_args(argv)

    configure_logging(options.silent, options.log)

    check_prerequisite(options)
    get_design_examples(options)

    close_logging()


if "__main__" == __name__:
    result = main(sys.argv)
    sys.exit(result)
