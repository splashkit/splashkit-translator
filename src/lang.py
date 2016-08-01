#!/usr/bin/env python
# encoding: utf-8
"""
lang_py.py

This file contains the scripts for the post processing required for the Python programming language

Created by Andrew Cain on 2015-12-02.
Copyright (c) 2015 Swinburne. All rights reserved.
"""

import logging
import sys

from lang_data import LangMethodData, LangBasicData

from sg import parser_runner, wrapper_helper
from sg.sg_cache import logger, find_or_add_file
from sg.print_writer import PrintWriter
from sg.file_writer import FileWriter
from sg.sg_type import SGType
from sg.sg_parameter import SGParameter

import py_lib
import lang_helper    

_out_path="../../Generated/Python"


def create_py_code_for_file(the_file, other):
    '''
        This is called by the parser runner 
        so that the passed in file can have the
        post processing for the Python language.
    '''    
    
    logger.info('Post Processing "%s" for Python wrapper creation', the_file.name)

    # Members of the file will be types for Type, or the unit for other files.    
    for member in the_file.members:
        if member.is_class or member.is_struct or member.is_enum or member.is_type:
            # Setup the language data
            member.lang_data['c'] = LangBasicData(member)
            member.lang_data['cpp'] = LangBasicData(member)
            
            _do_create_type_code(member)
        elif member.is_module or member.is_library:
            for key, method in member.methods.items():
                # Setup the language data
                method.lang_data['c'] = LangMethodData(method)
                method.lang_data['cpp'] = LangMethodData(method)
                
                if the_file.name == 'SGSDK':
                    _do_create_adapter_code(method)
                else:
                    # Process parameters - adding length and result parameters to functions/procedures
                    _do_c_parameter_processing(method)
                    
                    # Build method signature and code
                    _do_c_create_method_code(method)


def main():
    # logging.basicConfig(level=logging.ERROR,format='%(asctime)s - %(levelname)s - %(message)s',stream=sys.stdout)
    
    # Process all units -- creating object model
    parser_runner.parse_all_units()

    logging.basicConfig(level=logging.INFO,format='%(asctime)s - %(levelname)s - %(message)s',stream=sys.stdout)

    # Get the Parser Runner to visit each of the Pascal units
    # and call `create_py_code_for_file`
    # This will create code in memory for each of these 
    parser_runner.visit_all_units(create_py_code_for_file)

if __name__ == '__main__':
    main()
