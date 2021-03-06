#===-----------------------------------------------------------------------===//
#
# This source file is part of the Swift.org open source project
#
# Copyright (c) 2020 Apple Inc. and the Swift project authors
# Licensed under Apache License v2.0 with Runtime Library Exception
#
# See https://swift.org/LICENSE.txt for license information
# See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
#
#===-----------------------------------------------------------------------===//

def autogenerated_warning():
  return """
// #############################################################################
// #                                                                           #
// #            DO NOT EDIT THIS FILE; IT IS AUTOGENERATED.                    #
// #                                                                           #
// #############################################################################
"""

commonDice = [
    2, 3, 4, 5, 6, 7, 8, 10, 12, 14, 16, 20, 24, 30, 50, 100
]

def lowerFirst(str):
  return str[:1].lower() + str[1:] if str else ""

def argLabel(label):
  return label + ": " if label <> "_" else ""

