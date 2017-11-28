local redis = require "resty.redis"
local cjson = require "cjson"
local events = require "events"

local red = redis.new()
print(type(events))
red:connect("127.0.0.1", 6379)
events.post(red, "events", { action = "login", user = "tim@mit.com" })
local evs, ptr = events.get(red, "events")
print(cjson.encode({data = evs, lastId = ptr}))
