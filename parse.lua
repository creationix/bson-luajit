local p = require('utils').prettyPrint

test = "\22\0\0\0\2hello\0\6\0\0\0world\0\0"
test2 = "\49\0\0\0\4BSON\0\38\0\0\0\2\48\0\8\0\0\0awesome\0\1\49\0\51\51\51\51\51\51\20\64\16\50\0\194\7\0\0\0\0"

p(test2)
for i = 1, #test2 do
  p(test2:byte(i))
end

