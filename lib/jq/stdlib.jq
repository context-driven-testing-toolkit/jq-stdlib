#          __      _____ __      _
#    _____/ /_____/ / (_) /_    (_)___ _
#   / ___/ __/ __  / / / __ \  / / __ `/
#  (__  ) /_/ /_/ / / / /_/ / / / /_/ /
# /____/\__/\__,_/_/_/_.___/_/ /\__, /
#                         /___/   /_/
#
# Copyright 2013-2019 Noah Sussman New Media, LLC
# Copyright 2020 Noah Sussman New Media, LLC and Brian Goad
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
   ]
;

# Collect
#
# pluck() all the values for a property and return an object with a
# single property whose value is an array containing all of the values
# for that property.
#
# Synopsis:
#
#    [{A:0},{x:{A:1,b:9},y:{A:2,b:8}}] | collect("A") => {"A":[0,1,2]}

def collect($key):
  pluck($key)
  | map(reduce . as $doc ([]; $doc[$key]))
  | {
     "\($key)": .
     }
;


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
  | round / pow(10; 3)
;


# Average
#
# Synopsis:
#
#     [1, 10, 100] | avg => 37

def avg:
  add / length
;


# Mean
#
# Alias for avg()

def mean:
  avg
;


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
end
;


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
  map(select(. != null))
;


# Decant
#
# pluck() and then dereference each of the returned values.
#
# Synopsis:
#
#    [{A:0},{x:{A:1,b:9},y:{A:2,b:8}}] | decant("A") => [0,1,2}]

def decant($key):
  pluck($key)
  | map(.[])
;


# cons and cdr
#
# These classic Lisp functions return the first item in a list and all
# *but* the first item in a list, respectively.
#
# Synopsis:
#
#    [1,2,3,4,5] | cons => 1
#
#    [1,2,3,4,5] | cdr => [2,3,4,5]

def cons:
  .[0]
;

def cdr:
  .[1:length]
;

# fromepoch/0 and fromepoch/1
#
# Aliases for handling epoch objects. Both the /0 and /1 aritys enable value
# to be passed from a pipe or directly into the function.
#
# Synopsis:
#
#    1577836800 | fromepoch => "2020-01-01T00:00:00Z"
#
#    fromepoch(1577836800) => "2020-01-01T00:00:00Z"

def fromepoch:
    . | todate
;

def fromepoch(epoch):
    epoch | fromepoch
;

# fromepochms/0 and fromepochms/1
#
# Aliases for handling epoch millisecond objects. Both the /0 and /1 aritys enable value
# to be passed from a pipe or directly into the function.
#
# Synopsis:
#
#    1577836800000 | fromepochms => "2020-01-01T00:00:00Z"
#
#    fromepochms(1577836800000) => "2020-01-01T00:00:00Z"

def fromepochms:
    . / 1000 | todate
;

def fromepochms(epoch):
    epoch | fromepochms
;

# toepoch/0 and toepoch/1
# toepochms/0 and toepochms/1
#
# The inverse of fromepoch/0, fromepoch/1, fromepochms/0 and fromepochms/1.
# Converts a date object into an epoch seconds or milliseconds object.
#

def toepoch:
    . | fromdate
;

def toepoch(d):
    d | toepoch
;

def toepochms:
    . | fromdate * 1000
;

def toepochms(d):
    d | toepochms
;

# fetchpath/2 and fetchpath/1
#
# Helper utilities for #fetch
# $key must be an array-path, as with getpath/1
#

def fetchpath($key; default):
  getpath($key) as $value
  | if $value != null then $value
    elif ($key|length) == 1
    then if has($key[-1]) then null else default end
    else getpath($key[:-1]) as $x
    | if $x == null then default
      elif $x|has($key[-1]) then null
      else default
      end
  end
;

def fetchpath(key):
    fetchpath(key; empty)
;

# fetch/2 and fetch/1
#
# Utility to return a default object (or empty) if the path expression returns no values.
# Same idea as #fetch in Ruby
#
# Synopsis:
#
#    {"foo": "bar"} | fetch(.foo; "baz") => "bar"
#    {"foo": "bar"} | fetch(.idontexist; "baz") => "baz"
#

def fetch(key; default):
    fetchpath({} | path(key); default)
;

def fetch(key):
    fetch(key; empty)
;

# grep/1
#
# Utility to find a value in a nested object based on the name of the key
#
# Synopsis:
#
#    {"a": {"b": {"c": "d": "e" } } } | grep(.d) => "e"
#

def grep(key):
    ..
    | key?
    | select(. != null)
    | .
;

# pairwise/1
#
# Emits a stream consisting of pairs of items taken from `stream`
# See https://stackoverflow.com/a/48792655/1052013
#
# Synopsis:
#
#    [0,1,"a","b"] | pairwise(.[]) => [0,1] ["a", "b"]

def pairwise(stream):
  foreach stream as $i ([];
      if length == 1 then . + [$i] else [$i] end;
      select(length == 2))
;

# Assertions

def is_number:
  type == "number"
;
