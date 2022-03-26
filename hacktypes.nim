import std/strutils
iterator linesInFile*(s: static string): string =
  const myFile = staticRead(s)
  try:
    for line in lines(s):
      yield line
  except:
    for line in splitLines(myFile):
      yield line
