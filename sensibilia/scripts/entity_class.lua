entity_class = inherits_from {}

function entity_class:constructor(parent_group)
	self.parent_group = parent_group
end

function get_self(entity)
	return entity.scriptable.script_data
end

-- some specific entity may want to provide its own behaviour besides the basic process_all_entity_modules functions
-- in such a case these two functions should be called
function entity_class:loop()
	--self:all_modules("loop")
end

function entity_class:substep()
	--self:all_modules("substep")
	--print "substepping unoverrided character loop func"
end

-- perform a given method on all modules (components) of this entity
-- note: most of the components in scripts will have component:system 1:1 relationship
-- so it is an overkill to create separate system classes
-- I am calling these "modules" to distinguish them from basic components in my C++ core
function entity_class:all_modules(method, ...)
	for k, v in pairs(self) do
		if type(self[k]) == "table" and type(self[k][method]) == "function" then
			self[k][method](self[k], ...)
		end
	end
end

function entity_class:try_module_method(module_name, method_name, ...)
	-- do not process only if it is explicitly disabled,
	-- i.e. if no "enabled" flag was set for this module, or if it was set to true, then process it
	local m = self[module_name]
	
	if 
	-- this module exists
	m ~= nil
		and 
	-- this function in this module exists
	m[method_name] ~= nil 
		and
	-- module not explicitly disabled
	(m.enabled == nil or m.enabled == true) 
		then
	-- call method
		m[method_name](m, ...)
	end
end

global_entity_table = {}
global_scriptables_table = {}
global_message_table = {}

global_message_table[scriptable_component.DAMAGE_MESSAGE] = {}
global_message_table[scriptable_component.INTENT_MESSAGE] = {}

function flush_message_tables()
	for k, v in pairs(global_message_table) do
		global_message_table[k] = {}
	end
end

entity_basic_scriptable_info = create_scriptable_info {
	scripted_events = {
		[scriptable_component.LOOP] = function (subject, is_substepping)
			if not level_world.is_paused then
			
				local my_self = get_self(subject)
			
				if is_substepping then
					my_self:substep()
				else
					my_self:loop()
				end
			end
		end,
		
		[scriptable_component.DAMAGE_MESSAGE] = function (message)
			table.insert(global_message_table[scriptable_component.DAMAGE_MESSAGE], message)
		end,
		
		[scriptable_component.INTENT_MESSAGE] = function (message)
			table.insert(global_message_table[scriptable_component.INTENT_MESSAGE], message)
		end
	}
}


function process_all_entities(callback)
	for i=1, #global_entity_table do
		callback(global_entity_table[i])
	end
end

function process_all_entity_modules(module_name, method_name, ...)
	for i=1, #global_entity_table do
		global_entity_table[i]:try_module_method(module_name, method_name, ...)
	end
end

function spawn_entity(group_table, what_class, ...)
	if what_class == nil then what_class = entity_class end
	
	group_table = archetyped( { body = { scriptable = { } } }, group_table )
	
	--print (table.inspect(group_table))
	
	local my_new_entity_group = ptr_create_entity_group (group_table)
	local new_entity_script_data = what_class:create(my_new_entity_group, ...)
	-- there is no need to override the basic scriptable info as it provides entities with all needed functionality
	-- and in fact should not be modified
	--local new_scriptable_info = create_scriptable_info (scriptable_table)
	
	my_new_entity_group.body:get().scriptable.script_data = new_entity_script_data
	my_new_entity_group.body:get().scriptable.available_scripts = entity_basic_scriptable_info
	
	table.insert(global_entity_table, new_entity_script_data)
	--table.insert(global_scriptables_table, new_scriptable_info)
	
	return my_new_entity_group
end
