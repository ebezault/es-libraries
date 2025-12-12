note
	description: "WebAPI handler for listing storage tables."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	STORAGE_TABLES_WEBAPI_HANDLER

inherit
	STORAGE_WEBAPI_HANDLER

create
	make

feature {NONE} -- Router setup

	setup_router (a_router: WSF_ROUTER)
		do
			a_router.handle (versioned_base_uri_template + "storage/tables", Current, a_router.methods_get)
		end

feature -- Execution

	execute (a_version: READABLE_STRING_GENERAL; req: WSF_REQUEST; res: WSF_RESPONSE)
		local
			rep: HM_WEBAPI_RESPONSE
			jarr: JSON_ARRAY
			tables: detachable LIST [READABLE_STRING_8]
		do
			rep := new_response (req, res)
			if attached storage_api.tables as lst then
				tables := lst
				create jarr.make (tables.count)
				across
					tables as t
				loop
					jarr.extend (create {JSON_STRING}.make_from_string (t))
				end
				if attached {JSON_WEBAPI_RESPONSE} rep as jrep then
					jrep.resource.put (jarr, "rows")
				else
--					rep.add_field ("tables", jarr)
				end
				rep.add_integer_64_field ("count", tables.count)
			else
				rep.add_boolean_field ("error", True)
				rep.add_string_field ("message", "Unable to access SQL storage")
			end
			rep.execute
		end

note
	copyright: "2011-2025, Jocelyn Fiat, Javier Velilla, Eiffel Software and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end

