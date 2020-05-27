# Saltan
#
# Salt definition:
# goldbook.iupac.org/terms/view/S05447
# Salt explanation:
# chemistry.stackexchange.com/questions/86399/are-all-ionic-compounds-salts

# Used to get the elements.json from the web
import httpClient

# Used to parse elements.json
import json

# Used to determine the existance of elements.json
import os

# Used to get permutations
import algorithm

# Used to convert seq to string
import sequtils

# Mess with the wanted string
import strutils

# Parallelism
#import threadpool

var client = newHttpClient()
var string_elements: string

# From github.com/narimiran/itertools
iterator distinctPermutations[T](s: openArray[T]): seq[T] =
  var x = @s
  x.sort(cmp)
  yield x

  while x.nextPermutation():
    yield x

# Convert seq[char] to string
proc `$`(str: seq[char]): string =
  result = newStringOfCap(len(str))
  for character in str:
    add(result, character)

proc reverse(str: string): string =
  var s = str
  for i in 0 .. s.high div 2:
    swap(s[i], s[s.high - i])
  result = s

proc print_ion_or_elem(node : JsonNode) =
  if node.hasKey("summary"):
    echo node["symbol"].getStr, " ", node["name"].getStr, " ",
     node["number"].getInt
  else:
    echo node["symbol"].getStr, " ", node["name"].getStr, " "

proc get_symb(node : JsonNode) : string =
  result = node["symbol"].getStr.toLowerAscii.split(Digits).join("")

# Get the periodic table json
if existsFile "periodic.json":
  # echo "Using local elements.json ..."
  string_elements = readFile("periodic.json")
else:
  # echo "Fetching elements.json ..."
  string_elements = client.getContent("https://websalt.github.io/saltan/periodic.json")

# Parse the json data
let data = parseJson(string_elements)

if paramCount() != 1:
  echo "A word to saltan is needed"
  echo "Example"
  quit "saltan clan"

let wanted = paramStr(1).split(" ").join("").toLower()
if len(wanted) > 10:
  quit "A phrase that long could be troublesome"

proc metal_status(element: JsonNode): string =
  # Determine if the element is a metal or worth considering as one
  if "metalloid" in element["category"].getStr or "nonmetal" in element[
      "category"].getStr:
    result = "non-metal"
  elif "noble gas" in element["category"].getStr:
    result = "noble gas"
  else:
    result = "metal"

var
  list_of_metals = newseq[JsonNode](0)
  list_of_nonmetals = newseq[JsonNode](0)
  elem_status: string

for element in data["elements"]:
  elem_status = metal_status(element)
  if elem_status == "metal":
    list_of_metals.add(element)
  elif elem_status == "non-metal":
    list_of_nonmetals.add(element)

for ion in data["polyatomics"]:
  if ion["charge"].getInt > 0:
    list_of_metals.add(ion)
  else:
    list_of_nonmetals.add(ion)

var
  has_salt = false
  elem: string
  status: string
  otherelem: string
  otherstatus: string
  combo: string

# Paralellism
# proc get_matches(element : JsonNode, wanted : string,
# nonmetals : seq[JsonNode]) {.gcsafe.} =
#     var
#       otherelem : string
#       combo : string

#     for otherelement in nonmetals:
#         otherelem = otherelement["symbol"].getStr.toLowerAscii

#         # combo = elem & otherelem
#         combo = otherelem & element["symbol"].getStr.toLowerAscii
#         for perm in distinctPermutations(combo):
#           if $perm == wanted:
#             # if has_salt:
#               # echo ""
#             echo element["symbol"].getStr, " ",
# element["name"].getStr, " ", element["number"].getInt
#             echo otherelement["symbol"].getStr,
# " ", otherelement["name"].getStr, " ", otherelement["number"].getInt
#             # has_salt = true
#             break

for element in list_of_metals:
  elem = get_symb(element)
  # spawn get_matches(element, wanted, list_of_nonmetals)

  for otherelement in list_of_nonmetals:
    otherelem = get_symb(otherelement)

    combo = elem & otherelem
    if combo.len != wanted.len:
      continue
    for perm in distinctPermutations(combo):
      if $perm == wanted:
        if has_salt:
          echo ""
        print_ion_or_elem(element)
        print_ion_or_elem(otherelement)
        has_salt = true
        break

# Wait for all the threads to finish
# sync()

# when isMainModule:
  # echo("Hello, World!")
