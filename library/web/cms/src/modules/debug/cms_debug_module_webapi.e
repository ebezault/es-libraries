note
	description: "Summary description for {CMS_DEBUG_MODULE_WEBAPI}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	CMS_DEBUG_MODULE_WEBAPI

inherit
	CMS_MODULE_WEBAPI [CMS_DEBUG_MODULE]

	CMS_HOOK_AUTO_REGISTER

	SHARED_EXECUTION_ENVIRONMENT


create
	make

feature {NONE} -- Router/administration

	associated_router: detachable WSF_ROUTER

	setup_webapi_router (a_router: WSF_ROUTER; a_api: CMS_API)
			-- <Precursor>
		local
--			m: WSF_URI_MAPPING
--			h: WSF_URI_AGENT_HANDLER
			h: CMS_DEBUG_ROOT_WEBAPI_HANDLER
		do
			associated_router := a_router
			create h.make (a_api, a_router)
--			create h.make (agent execute (?, ?, a_api))
--			create m.make_trailing_slash_ignored ("/debug", h)
--			a_router.map (m, a_router.methods_get)
		end

feature -- Execution

	execute (req: WSF_REQUEST; res: WSF_RESPONSE; api: CMS_API)
		local
			r: JSON_WEBAPI_RESPONSE
		do
			create r.make (req, res, api)
			append_info_to ("SiteName", api.setup.site_name, r)
			append_info_to ("SiteUrl", api.setup.site_url, r)

			if attached api.setup.environment.cms_config_ini_path as l_loc then
				append_info_to ("Configuration file", l_loc.name, r)
			end

			append_info_to ("Current dir", execution_environment.current_working_path.utf_8_name, r)
--				append_info_to ("Base url", cms.base_url, r)
--				append_info_to ("Script url", cms.script_url, r)
			append_info_to ("Site dir", api.site_location.utf_8_name, r)
			append_info_to ("Www dir", api.setup.environment.www_path.utf_8_name, r)
			append_info_to ("Assets dir", api.setup.environment.assets_path.utf_8_name, r)
			append_info_to ("Config dir", api.setup.environment.config_path.utf_8_name, r)
			append_info_to ("Theme", api.theme_name, r)
			append_info_to ("Theme location", api.theme_location.utf_8_name, r)
			append_info_to ("Files location", api.files_location.utf_8_name, r)
			append_info_to ("Modules location", api.modules_location.utf_8_name, r)
			append_info_to ("Storage", api.storage.generator, r)

			append_info_to ("Url", r.url ("/", Void), r)
--				if attached r.user as u then
--					append_info_to ("User", u.name, r)
--					append_info_to ("User url", r.user_url (u), r)
--				end

			if attached associated_router as l_router then
				append_router_info_to (l_router, r)
			end

			r.execute
		end

	append_info_to (n: READABLE_STRING_8; v: detachable READABLE_STRING_GENERAL; r: JSON_WEBAPI_RESPONSE)
		do
			if v = Void then
				r.resource.put (Void, n)
--				r.add_string_field (n, "")
			else
				r.add_string_field (n, v)
			end
		end

	append_router_info_to (a_router: WSF_ROUTER; r: JSON_WEBAPI_RESPONSE)
		local
			jarr: JSON_ARRAY
		do
			create jarr.make_empty
			across
				a_router as ri
			loop
				jarr.extend (create {JSON_STRING}.make_from_string_general (ri.debug_output))
			end
			r.resource.put (jarr, "routes")
		end

note
	copyright: "2011-2025, Jocelyn Fiat, Javier Velilla, Eiffel Software and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end
