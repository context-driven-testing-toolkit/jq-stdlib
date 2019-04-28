#          __      _____ __      _
#    _____/ /_____/ / (_) /_    (_)___ _
#   / ___/ __/ __  / / / __ \  / / __ `/
#  (__  ) /_/ /_/ / / / /_/ / / / /_/ /
# /____/\__/\__,_/_/_/_.___/_/ /\__, /
#                         /___/   /_/
#
# Copyright 2013-2019 Noah Sussman New Media, LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# jq Standard Library Of Functions


# Pluck
#
# Implementation of underscore.js pluck(): "A convenient version of
# what is perhaps the most common use-case for map(): extracting a
# list of property values."
#
# Synopsis:
#
#    [{A:0},{x:{A:1,b:9},y:{A:2,b:8}}] | pluck("A") => [{"A":0},{"A":1},{"A":2}]

def pluck($key):

[..
   | .[$key]?
   | select(. != null)
   | {
      "\($key)": .
      }
 ];


# Collect
#
# pluck() all the values for a property and return an object with a
# single property whose value is an array containing all of the values
# for that property.
#
# Synopsis:
#
#    [{A:0},{x:{A:1,b:9},y:{A:2,b:8}}] | collect => {"A":[0,1,2]}

def collect($key):

pluck($key)
  | map(reduce . as $doc ([]; $doc[$key]))
  | {
     "\($key)": .
     };


# RoundF
#
# Round floating point numbers.
#
# Synopsis:
#
#     3.14159 | roundf    => 3.141
#
#     3.14159 | roundf(4) => 3.1416

def roundf($places):
  (. * pow(10; $places))
  | round / pow(10; $places);

def roundf:
  (. * pow(10; 3))
  | round / pow(10; 3);


# Average
#
# Synopsis:
#
#     [1, 10, 100] | avg => 37

def avg:
  add / length;


# Mean
#
# Alias for avg()

def mean:
  avg;


# Median
#
# Synopsis:
#
#     [1, 10, 100] | median => 10
#
#     [1, 10, 100, 1000] | median => 55

def median:
  sort
  | if length % 2 == 1
  then
    .[length / 2 | floor]
  else
    (.[length / 2 | floor]
      + .[length / 2 | floor - 1])
    / 2
  end;


# Compact
#
# Remove null entries from an array.
#
# Unlike underscore.js compact(), only null values are removed here:
# entries of false or 0 are left intact.
#
# Synopsis:
#
#     [null,0,null,1,2] | compact => [0,1,2]

def compact:
  map(select(. != null));
