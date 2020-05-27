# Saltan

# Salt definition:
# goldbook.iupac.org/terms/view/S05447
# Salt explanation:
# chemistry.stackexchange.com/questions/86399/are-all-ionic-compounds-salts
import dom

# github.com/stisa/ajax
import ajax

# Used to parse elements.json
import json

# Used to get permutations
import algorithm

# Mess with the wanted string
import strutils

proc getItem*(key: cstring): cstring {.importc: "localStorage.getItem".}
proc setItem*(key, value: cstring) {.importc: "localStorage.setItem".}
proc hasItem*(key: cstring): bool {.importcpp: "(localStorage.getItem(#) !== null)".}
proc clear*() {.importc: "localStorage.clear".}

proc removeItem*(key: cstring) {.importc: "localStorage.removeItem".}
# From github.com/narimiran/itertools
iterator distinctPermutations[T](s: openArray[T]): seq[T] {.exportc.} =
  var x = @s
  x.sort(cmp)
  yield x

  while x.nextPermutation():
    yield x

# Convert seq[char] to string
proc `$`(str: seq[char]): string {.exportc.} =
  result = newStringOfCap(len(str))
  for character in str:
    add(result, character)

proc print(content : string) =
  document.getelementbyid("main").innerhtml = content
  # window.alert(content)

proc get_symb(node : JsonNode) : string {.exportc.} =
  result = node["symbol"].getStr.toLowerAscii.split(Digits).join("")

proc metal_status(element: JsonNode): string {.exportc.} =
  # Determine if the element is a metal or worth considering as one
  if "metalloid" in element["category"].getStr or "nonmetal" in element[
      "category"].getStr:
    result = "non-metal"
  elif "noble gas" in element["category"].getStr:
    result = "noble gas"
  else:
    result = "metal"

proc pretty_present(node : JsonNode) : string =
  result = (node["symbol"].getStr & " " & node["name"].getStr)
  if node.hasKey("summary"):
    result = result & " " & $(node["number"].getInt)


proc doStuff(string_elements : string) =
  let data = parseJson(string_elements)
  var wanted : string
  if hasItem("phrase"):
    if getItem("phrase") != "":
      wanted = ($(getItem("phrase"))).tolower.strip(leading = true, trailing = true).split().join("")
    else:
      wanted = "salt"
  else:
    wanted = "salt"

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
    otherelem: string
    combo: string

  var content = ""
  content = content & "<pre>" & wanted.capitalizeAscii & "\n"

  for element in list_of_metals:
    elem = get_symb(element)

    for otherelement in list_of_nonmetals:
      otherelem = get_symb(otherelement)

      combo = elem & otherelem
      if combo.len != wanted.len:
        continue
      for perm in distinctPermutations(combo):
        if $perm == wanted:
          if has_salt:
            content = content & "\n"
          content = content & pretty_present(element)
          content = content & "\n"
          content = content & pretty_present(otherelement)
          content = content & "\n"
          has_salt = true
          break
  if content == "<pre>" & wanted.capitalizeAscii & "\n":
       content = content & "No salts were found"
  content = content & "</pre>"
  print(content)

proc makeRequest(url:cstring) {.exportc.} =
  var httpRequest = newXMLHttpRequest()

  # if httpRequest.isNil:
  #   window.alert("Giving up :( Cannot create an XMLHTTP instance")
  #   return
  proc alertContents(e:Event) =
    if httpRequest.readyState == rsDONE:
      if httpRequest.status == 200:
        let content = $httpRequest.responseText
        doStuff(content)
      else:
        window.alert("There was a problem with the request.")

  httpRequest.onreadystatechange = alertContents
  httpRequest.open("GET", url);
  httpRequest.send();

proc onLoad() {.exportc.} =
  # makeRequest("http://penguin.linux.test:8000/periodic.json")
  makeRequest("periodic.json")

proc doFormStuff() {.exportc.} =
  let phrase = $(document.getElementById("phrase").value)
  setItem("phrase", phrase)
  window.location.reload()
