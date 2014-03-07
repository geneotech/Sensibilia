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
			self[k][method](self[k], table.unpack({...}))
		end
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
			local my_self = get_self(subject)
		
			if is_substepping then
				my_self:substep()
			else
				my_self:loop()
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


function process_all_entity_modules(module_name, method_name, ...)
	for k, v in ipairs(global_entity_table) do
		-- do not process only if it is explicitly disabled,
		-- i.e. if no "enabled" flag was set for this module, or if it was set to true, then process it
		
		if 
		-- this module exists
		v[module_name] ~= nil
			and 
		-- this function in this module exists
		v[module_name][method_name] ~= nil 
			and
		-- module not explicitly disabled
		(v[module_name].enabled == nil or v[module_name].enabled == true) 
			then
		-- call method
			v[module_name][method_name](v[module_name], table.unpack({...}))
		end
	end
end

function spawn_entity(group_table, what_class, ...)
	if what_class == nil then what_class = entity_class end
	
	group_table = archetyped( { body = { scriptable = { } } }, group_table )
	
	--print (table.inspect(group_table))
	
	local my_new_entity_group = ptr_create_entity_group (group_table)
	local new_entity_script_data = what_class:create(my_new_entity_group, table.unpack({...}))
	-- there is no need to override the basic scriptable info as it provides entities with all needed functionality
	-- and in fact should not be modified
	--local new_scriptable_info = create_scriptable_info (scriptable_table)
	
	my_new_entity_group.body:get().scriptable.script_data = new_entity_script_data
	my_new_entity_group.body:get().scriptable.available_scripts = entity_basic_scriptable_info
	
	table.insert(global_entity_table, new_entity_script_data)
	--table.insert(global_scriptables_table, new_scriptable_info)
	
	return my_new_entity_group
end
