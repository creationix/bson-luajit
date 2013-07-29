local prettyPrint = require("utils").prettyPrint
local ffi = require 'ffi'

local types, UInt32, Double, String, Document, Array, Binary, Undefined,
      ObjectID, Boolean, DateTime, Null, CString, DBPointer, JavaScript,
      Symbol, ScopedJavaScript, Int32, TimeStamp, Int64, Max, Min

function UInt32(buf, i)
  return ffi.cast("uint32_t*", buf + i)[0], 4
end

function Double(buf, i)
  return ffi.cast("double*", buf + i)[0], 8
end

function String(buf, i)
  local len, consumed = UInt32(buf, i)
  return ffi.string(buf + i + consumed, len - 1), len + consumed
end

function Document(buf, i)
  local length, consumed, last, doc, parser, name
  length, consumed = UInt32(buf, i)
  last = i + length - 1
  i = i + consumed
  doc = {}
  while i < last do
    parser = assert(types[buf[i]], "Invalid entry type: " .. buf[i])
    i = i + 1
    name, consumed = CString(buf, i)
    i = i + consumed
    doc[name] ,consumed = parser(buf, i)
    i = i + consumed
  end
  return doc, length
end

function Array(buf, i)
  local length, consumed, last, doc, parser, index
  length, consumed = UInt32(buf, i)
  last = i + length - 1
  i = i + consumed
  doc = {}
  while i < last do
    parser = assert(types[buf[i]], "Invalid entry type: " .. buf[i])
    i = i + 1
    index = buf[i] - 48
    assert(index == #doc, "Array keys must increment")
    assert(buf[i + 1] == 0, "Array key must be null terminated")
    i = i + 2
    doc[index + 1], consumed = parser(buf, i)
    i = i + consumed
  end
  return doc, length
end

function Binary(buf, i)
  error "TODO: Implement Binary"
end

function Undefined(buf, i)
  error "TODO: Implement Undefined"
end

function ObjectID(buf, i)
  error "TODO: Implement ObjectID"
end

function Boolean(buf, i)
  error "TODO: Implement Boolean"
end

function DateTime(buf, i)
  error "TODO: Implement DateTime"
end

function Null(buf, i)
  error "TODO: Implement Null"
end

function CString(buf, i)
  local string = ffi.string(buf + i)
  return string, #string + 1
end

function DBPointer(buf, i)
  error "TODO: Implement DBPointer"
end

function JavaScript(buf, i)
  error "TODO: Implement JavaScript"
end

function Symbol(buf, i)
  error "TODO: Implement Symbol"
end

function ScopedJavaScript(buf, i)
  error "TODO: Implement ScopedJavaScript"
end

function Int32(buf, i)
  return ffi.cast("int32_t*", buf + i)[0], 4
end

function TimeStamp(buf, i)
  error "TODO: Implement TimeStamp"
end

function Int64(buf, i)
  return ffi.cast("int64_t*", buf + i)[0], 8
end

function Max(buf, i)
  error "TODO: Implement Max"
end

function Min(buf, i)
  error "TODO: Implement Min"
end

types = {
  [1] = Double,
  [2] = String,
  [3] = Document,
  [4] = Array,
  [5] = Binary,
  [6] = Undefined,
  [7] = ObjectID,
  [8] = Boolean,
  [9] = DateTime,
  [10] = Null,
  [11] = CString,
  [12] = DBPointer,
  [13] = JavaScript,
  [14] = Symbol,
  [15] = ScopedJavaScript,
  [16] = Int32,
  [17] = TimeStamp,
  [18] = Int64,
  [127] = Max,
  [255] = Min,
}

local function parse(string)
  prettyPrint(string)
  local length = #string
  local doc, consumed = Document(ffi.cast("const char*", string), 0)
  assert(consumed == length, "Length mismatch")
  prettyPrint(doc)
end


parse "\22\0\0\0\2hello\0\6\0\0\0world\0\0"
parse "\49\0\0\0\4BSON\0\38\0\0\0\2\48\0\8\0\0\0awesome\0\1\49\0\51\51\51\51\51\51\20\64\16\50\0\194\7\0\0\0\0"
