note
	description: "Summary description for {STORAGE_MODULE_WEBAPI}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	STORAGE_MODULE_WEBAPI

inherit
	CMS_MODULE_WEBAPI [STORAGE_MODULE]
		redefine
			setup_hooks,
			permissions
		end

	CMS_HOOK_WEBAPI_RESPONSE_ALTER

	CMS_HOOK_AUTO_REGISTER

create
	make

feature {NONE} -- Router/administration

	setup_webapi_router (a_router: WSF_ROUTER; a_api: CMS_API)
			-- <Precursor>
		local
			h: STORAGE_WEBAPI_HANDLER
		do
			if attached module.storage_api as l_mod_api then
				create {STORAGE_TABLES_WEBAPI_HANDLER} h.make (l_mod_api, a_router)
				create {STORAGE_TABLE_SCHEMA_WEBAPI_HANDLER} h.make (l_mod_api, a_router)
				create {STORAGE_TABLE_ITEMS_WEBAPI_HANDLER} h.make (l_mod_api, a_router)
				create {STORAGE_QUERY_WEBAPI_HANDLER} h.make (l_mod_api, a_router)
			end
		end

feature -- Access

	permissions: LIST [READABLE_STRING_8]
			-- List of permission ids, used by this module, and declared.
		do
			Result := Precursor
		end

feature -- Hooks configuration

	setup_hooks (a_hooks: CMS_HOOK_CORE_MANAGER)
			-- Module hooks configuration.
		do
			a_hooks.subscribe_to_webapi_response_alter_hook (Current)
			module.setup_hooks (a_hooks)
		end

feature -- Hook

	webapi_response_alter (rep: WEBAPI_RESPONSE)
		local
--			p: STRING_8
		do
--			if
--				attached {HM_WEBAPI_RESPONSE} rep as hm
--			then
--				if rep.is_root then
--					create p.make_from_string ({STORAGE_WEBAPI_HANDLER}.versioned_base_uri_template)
--					p.replace_substring_all ("{version}", {STORAGE_WEBAPI_HANDLER}.default_api_version)

--					hm.add_link ("api:" + {STORAGE_MODULE}.name, Void, rep.api.webapi_path (p) + {STORAGE_MODULE}.name)
--				end
--			end
		end

note
	copyright: "2011-2025, Jocelyn Fiat, Javier Velilla, Eiffel Software and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end

