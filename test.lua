local prettyPrint = require("utils").prettyPrint
local decode = require('bson').decode

local function testDecode(string)
  prettyPrint(string)
  local doc = decode(string)
  prettyPrint(doc)
end

testDecode "\22\0\0\0\2hello\0\6\0\0\0world\0\0"
testDecode "\49\0\0\0\4BSON\0\38\0\0\0\2\48\0\8\0\0\0awesome\0\1\49\0\51\51\51\51\51\51\20\64\16\50\0\194\7\0\0\0\0"
