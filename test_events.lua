local redis = require "resty.redis"
local cjson = require "cjson"
local events = require "events"

local red = redis.new()
print(type(events))
red:connect("127.0.0.1", 6379)
events.post(red, "events", { action = "login", user = "tim@mit.com" })
local evs, ptr = events.get(red, "events")
print(cjson.encode({data = evs, lastId = ptr}))



--_M.post("events", { action = "login", user = "tim@mit.com" })
--local ptr = _M.get("events", { after = os.getenv("foo"), wait = true })
--_M.get("events", { after = ptr })
--local d, err = red:xrange(unpack{"events", "-", "+"})
--print(cjson.encode(d))
