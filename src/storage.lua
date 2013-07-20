-- storage.lua
-- > redis = require 'redis'
-- > client= redis.connect('127.0.0.1', 6379)
-- > client:ping()
local collection = require 'collection'
local redis


local namespace = "jor"
local selectors = {
   compare = {"$gt","$gte","$lt","$lte"},
   sets = {"$in","$all","$not"}
}

local all_selectors = {}
for _,v in pairs(selectors) do
   for _,v2 in ipairs(v) do
      table.insert(all_selectors, v2)
   end
end

local function redis()
   local r= require 'redis'
   redis = redis or r.connect('127.0.0.1', 6379)
   return redis
end

function create_collection(name, options)
   options = options or {}
   local auto_inc = not not options.auto_increment
   local new
   new = internal_create_collection(name, auto_inc)
   if not new then
      error("CollectionNotValid")
   end
end

function internal_create_collection(name, auto_inc)
   local redis = redis()
   local is_new = redis:sadd(namespace .. "/collections", name)
   if is_new == 0 then
     return nil, "error"
   end
   redis:set(namespace .. "/collection/" .. name .. "/auto-increment", auto_inc )
   return name
end

function destroy_all()
   for _, name in pairs(collections()) do
      destroy_collection(name)
   end
end

function destroy_collection(name)
   local redis = redis()

   collection.delete_all(namespace , name)
   -- pipelined
   redis:srem(namespace.. "/collections", name)
   redis:del(namespace.. "/collection/".. name .."/auto-increment")
   -- pipelined-end
end

function find_collection(name)
   local redis = redis()
   local redis_auto_incr = redis.get(namespace.."/collection/".. name .."/auto-increment")
   if redis_auto_incr == "true" then
   elseif redis_auto_incr == "false" then
   else error("Collection " .. name .." doesn't exist")
   end
end
