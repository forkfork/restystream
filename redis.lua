local redis = require "resty.redis"
local _M = {}

_M.init = function()
  local red = redis.new()
  red:connect("127.0.0.1", 6379)
  local _, err = red:get("checkauth")
  if err == "NOAUTH Authentication required." then
    red:auth("hello")
  end
  return red
end

_M.close = function(red)
  red:set_keepalive(25000, 10)
end

return _M
