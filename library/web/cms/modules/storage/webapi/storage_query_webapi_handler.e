note
	description: "WebAPI handler for executing SQL queries on storage."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	STORAGE_QUERY_WEBAPI_HANDLER

inherit
	STORAGE_WEBAPI_HANDLER

create
	make

feature {NONE} -- Router setup

	setup_router (a_router: WSF_ROUTER)
		do
			a_router.handle (versioned_base_uri_template + "storage/query", Current, a_router.methods_post)
		end

feature -- Execution

	execute (a_version: READABLE_STRING_GENERAL; req: WSF_REQUEST; res: WSF_RESPONSE)
		local
			rep: HM_WEBAPI_RESPONSE
			jarr: JSON_ARRAY
			jobj: JSON_OBJECT
			query: detachable READABLE_STRING_8
			limit: INTEGER
			rows: detachable LIST [STRING_TABLE [detachable ANY]]
			l_row: STRING_TABLE [detachable ANY]
			k: READABLE_STRING_GENERAL
		do
			rep := new_response (req, res)

				-- Check permission for query execution
			if not api.has_permission ({STORAGE_MODULE}.Permission_query_storage) then
				rep.add_boolean_field ("error", True)
				rep.add_string_field ("message", "Permission denied: query storage permission required")
				rep.execute
			else
					-- Get query from request body
				if attached json_value_from_request (req) as jv then
					if attached {JSON_OBJECT} jv as jvobj then
						if attached jvobj.string_item ("query") as jq then
							query := jq.unescaped_string_8
						end
						if attached jvobj.number_item ("limit") as jnum then
							limit := jnum.integer_64_item.to_integer_32
						else
							limit := 100  -- Default limit
						end
					end
				elseif attached req.query_parameter ("query") as q then
					query := q.string_representation.to_string_8 -- FIXME
					if
						attached req.query_parameter ("limit") as p_limit and then
						attached p_limit.string_representation as l
					then
						if l.is_integer_64 then
							limit := l.to_integer_32
						end
					else
						limit := 100
					end
				end

				if query = Void or else query.is_empty then
					rep.add_boolean_field ("error", True)
					rep.add_string_field ("message", "Missing or empty query parameter")
				else
					if attached storage_api.execute_query (query, Void, limit) as lst then
						rows := lst
						create jarr.make (rows.count)
						across
							rows as r
						loop
							l_row := r
							create jobj.make
							across
								l_row as entry
							loop
								k := @entry.key
								if attached entry as val then
									if attached {READABLE_STRING_GENERAL} val as s then
										jobj.put_string (s.to_string_8, k)
									elseif attached {INTEGER_64} val as i then
										jobj.put_integer (i, k)
									elseif attached {INTEGER_32} val as i32 then
										jobj.put_integer (i32.to_integer_64, k)
									elseif attached {REAL_64} val as r64 then
										jobj.put_real (r64, k)
									elseif attached {BOOLEAN} val as b then
										jobj.put_boolean (b, k)
									else
										jobj.put_string (val.out, k)
									end
								else
									jobj.put (Void, k)
								end
							end
							jarr.extend (jobj)
						end
						if attached {JSON_WEBAPI_RESPONSE} rep as jrep then
							jrep.resource.put (jarr, "rows")
						else
--							rep.add_field ("rows", jarr)
						end
						rep.add_integer_64_field ("count", rows.count)
						if limit > 0 and rows.count = limit then
							rep.add_boolean_field ("truncated", True)
						end
					else
						rep.add_boolean_field ("error", True)
						rep.add_string_field ("message", "Query execution failed or returned no results")
					end
				end
				rep.execute
			end
		end

feature {NONE} -- Helpers

	json_value_from_request (req: WSF_REQUEST): detachable JSON_VALUE
		local
			l_payload: STRING_8
			jp: JSON_PARSER
		do
			if attached req.content_type as ct and then ct.same_simple_type ({HTTP_MIME_TYPES}.application_json) then
				create l_payload.make (req.content_length_value.as_integer_32)
				req.read_input_data_into (l_payload)
				create jp.make
				jp.parse_string (l_payload)
				if jp.is_parsed and jp.is_valid then
					Result := jp.parsed_json_value
				end
			end
		end

note
	copyright: "2011-2025, Jocelyn Fiat, Javier Velilla, Eiffel Software and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end

