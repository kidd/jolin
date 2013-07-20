-- collection.lua
local DEFAULT_OPTIONS = {
      max_documents = 1000,
      raw = false,
      only_ids = false,
      reversed = false,
      excluded_fields_to_index = {}
    }

local collection = {}

local function idx_set_key(namespace, name, id)
   local t= {namespace, name, "sidx", id}
   return table.concat(t, "/")
end

local function doc_sset_key(namespace, name)
   return(table.concat({namespace, name, "ssdocs"}, "/")
end

local function doc_key(namespace, name, id)
   return(table.concat({namespace, name, "docs", id}, "/"))
end

function collection.delete_all(coll_name, doc)
   if not coll_name then
      error("coll_name has to be there")
   end
   if not doc then
      error("doc error")
   end

   local ids = collection.find(doc, {only_ids=true, max_documents = -1})
   for _,id in ipairs(ids) do
      delete_element(coll_name, id)
   end
end

function collection.delete_element(coll_name ,id)
   local redis = redis()
   local indexes = redis:smembers(idx_set_key("jor", coll_name, id))
   for _,index in ipairs(indexes) do
      remove_index(index, id)
   end
   redis:del(idx_set_key("jor", coll_name, id))
   redis:zrem(doc_sset_key("jor", coll_name), id)
   redis:del(doc_key("jor", coll_name, id))
end

function remove_index(index, id)
   local key = string.sub(index, 1, -6)
   local action = string.sub(index, -5)
   if  action == "_srem" then
      redis:srem(key, id)
   elseif action == "_zrem"  then
      redis:zrem(key, id)
   else error("unknown index") end
end

function merge_with_default_options(opts)
   local res
   for k, v in pairs(opts) do
      res[k] = v
   end
   for k, v in pairs(DEFAULT_OPTIONS) do
      res[k] = res[k] or v
   end
   return res
end


return collection
