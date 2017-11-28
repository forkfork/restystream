local cjson = require "cjson"

local _M = {}

-- luacheck: globals ngx

_M.post = function(red, stream, data)
  local kvs = { stream, "*" }
  for k, v in pairs(data) do
    table.insert(kvs, k)
    table.insert(kvs, v)
  end
  red:xadd(unpack(kvs))
end

local function parse_xread_response (rr)
  local evs = {}
  -- only 1 stream
  local ourstream = rr[1]
  -- 1st element is stream name, 2nd is data
  local ourevents = ourstream[2]
  for i = 1, #ourevents do
    local r_ev = ourevents[i][2]
    local ev = {}
    for n = 1, #r_ev, 2 do
      ev[r_ev[n]] = r_ev[n+1]
    end
    table.insert(evs, ev)
  end
  -- last item has last id
  local lastevent = ourevents[#ourevents]
  -- 1st element is id, 2nd is data
  local last_id = lastevent[1]
  return evs, last_id
end

_M.str = function(evs, last_id)
  if #evs == 0 then
    return '{"data":[],"last_id":"' .. (last_id or "0-0") .. '"}'
  end

  return cjson.encode({data = evs, last_id = last_id})
end

_M.get = function(red, stream, opts)
  opts = opts or {}
  assert(type(stream) == "string", "stream name must be string")
  local rargs = {}
  if opts.wait then
    table.insert(rargs, "BLOCK")
    table.insert(rargs, "30000")
  end
  table.insert(rargs, "COUNT")
  table.insert(rargs, opts.count or 100)
  table.insert(rargs, "STREAMS")
  table.insert(rargs, stream)
  table.insert(rargs, opts.after or "0-0")
  local rr = red:xread(unpack(rargs))
  if rr == ngx.null then
    return {}, opts.after
  end
  local evs, last_id = parse_xread_response(rr)
  return evs, last_id
end

return _M
