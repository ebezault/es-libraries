note
	description: "WebAPI handler for retrieving table schema information."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	STORAGE_TABLE_SCHEMA_WEBAPI_HANDLER

inherit
	STORAGE_WEBAPI_HANDLER

create
	make

feature {NONE} -- Router setup

	setup_router (a_router: WSF_ROUTER)
		do
			a_router.handle (versioned_base_uri_template + "storage/tables/{table_name}/schema", Current, a_router.methods_get)
		end

feature -- Execution

	execute (a_version: READABLE_STRING_GENERAL; req: WSF_REQUEST; res: WSF_RESPONSE)
		local
			rep: HM_WEBAPI_RESPONSE
			jarr: JSON_ARRAY
			jobj: JSON_OBJECT
			schema: detachable LIST [TUPLE [name: STRING_8; type: STRING_8; nullable: BOOLEAN]]
			table_name: detachable READABLE_STRING_GENERAL
		do
			rep := new_response (req, res)
			if attached {WSF_STRING} req.path_parameter ("table_name") as p_table_name then
				table_name := p_table_name.value
				if attached storage_api.table_schema (table_name.to_string_8) as lst then
					schema := lst
					rep.add_string_field ("table_name", table_name.to_string_8)
					create jarr.make (schema.count)
					across
						schema as col
					loop
						create jobj.make
						jobj.put_string (col.name, "name")
						jobj.put_string (col.type, "type")
						jobj.put_boolean (col.nullable, "nullable")
						jarr.extend (jobj)
					end
					if attached {JSON_WEBAPI_RESPONSE} rep as jrep then
						jrep.resource.put (jarr, "columns")
					else
--						rep.add_field ("columns", jarr)
					end
					rep.add_integer_64_field ("column_count", schema.count)
				else
					rep.add_boolean_field ("error", True)
					rep.add_string_field ("message", "Table not found or unable to retrieve schema: " + table_name.to_string_8)
				end
			else
				rep.add_boolean_field ("error", True)
				rep.add_string_field ("message", "Missing table_name parameter")
			end
			rep.execute
		end

note
	copyright: "2011-2025, Jocelyn Fiat, Javier Velilla, Eiffel Software and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end

