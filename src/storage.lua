-- storage.lua

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

local function redis(config)
   return "redis"
end

local redis = redis()

function create_collection(name, options)
   options = options or {}

   if not collection_exists(name) then
      internal_create(name, options)
   else
      error("CollectionNotValid")
   end
end

function internal_create(name, options)
   redis.sadd(namespace .. "/collections", name)
end
