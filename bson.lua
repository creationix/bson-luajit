local ffi = require('ffi')
local types

local function Double(buf, i)
  return ffi.cast("double*", buf + i)[0], 8
end

local function CString(buf, i)
  local string = ffi.string(buf + i)
  return string, #string + 1
end

local function String(buf, i)
  local length = ffi.cast("uint32_t*", buf + i)[0]
  return ffi.string(buf + i + 4, length - 1), length + 4
end

local function Document(buf, i)
  local length = ffi.cast("uint32_t*", buf + i)[0]
  local last = i + length - 1
  i = i + 4
  local doc = {}
  while i < last do
    local parser = assert(types[buf[i]], "Invalid entry type: " .. buf[i])
    i = i + 1
    local name = ffi.string(buf + i)
    i = i + #name + 1
    local consumed
    doc[name], consumed = parser(buf, i)
    i = i + consumed
  end
  return doc, length
end

local function Array(buf, i)
  local length = ffi.cast("uint32_t*", buf + i)[0]
  local last = i + length - 1
  i = i + 4
  local doc = {}
  while i < last do
    local parser = assert(types[buf[i]], "Invalid entry type: " .. buf[i])
    i = i + 1
    local index = buf[i] - 48
    assert(index == #doc, "Array keys must increment")
    assert(buf[i + 1] == 0, "Array key must be null terminated")
    i = i + 2
    local consumed
    doc[index + 1], consumed = parser(buf, i)
    i = i + consumed
  end
  return doc, length
end

local function Binary(buf, i)
  local length = ffi.cast("uint32_t*", buf + i)[0]
  return {
    subtype = buf[i + 4],
    data = ffi.string(buf + i + 5, length)
  }, length + 5
end

local function Undefined(buf, i)
  return nil, 0
end

local function ObjectID(buf, i)
  return ffi.string(buf + i, 12), 12
end

local function Boolean(buf, i)
  return buf[i] > 0 and true or false, 1
end

local function DateTime(buf, i)
  return ffi.cast("uint64_t*", buf + i)[0], 8
end

local function Null(buf, i)
  return nil, 0
end

local function RegularExpression(buf, i)
  local start = i
  local pattern = ffi.string(buf + i)
  i = i + #pattern + 1
  local options = ffi.string(buf + i)
  i = i + #options + 1
  return {
    pattern = pattern,
    options = options
  }, i - start
end

local function DBPointer(buf, i)
  local start = i
  local name = ffi.string(buf + i)
  i = i + #name + 1
  local id = ffi.string(buf + i, 12)
  i = i + 12
  return {
    name = name,
    id = id
  }, i - start
end

local function JavaScript(buf, i)
  local js = ffi.string(buf + i)
  return js, #js + 1
end

local function Symbol(buf, i)
  local symbol = ffi.string(buf + i)
  return symbol, #symbol + 1
end

local function ScopedJavaScript(buf, i)
  local start = i
  local js = ffi.string(buf + i)
  i = i + #js + 1
  local scope, consumed = Document(buf, i)
  i = i + consumed
  return {
    js = js,
    scope = scope
  }, i - start
end

local function Int32(buf, i)
  return ffi.cast("int32_t*", buf + i)[0], 4
end

local function TimeStamp(buf, i)
  return ffi.cast("uint64_t*", buf + i)[0], 8
end

local function Int64(buf, i)
  return ffi.cast("int64_t*", buf + i)[0], 8
end

local function Max(buf, i)
  return math.huge, 0
end

local function Min(buf, i)
  return -math.huge, 0
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
  [11] = RegularExpression,
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

local function decode(string)
  local length = #string
  local doc, consumed = Document(ffi.cast("const char*", string), 0)
  assert(consumed == length, "Length mismatch")
  return doc
end

local function encode(doc)
  error "TODO: Implement encode"
end

return {
  decode = decode,
  encode = encode
}
