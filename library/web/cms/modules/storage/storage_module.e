note
	description: "Storage module for browsing internal SQL storage."
	date: "$Date$"
	revision: "$Revision$"

class
	STORAGE_MODULE

inherit
	CMS_MODULE_WITH_SQL_STORAGE
		rename
			module_api as storage_api
		redefine
			setup_hooks,
			initialize,
			install,
			permissions,
			storage_api
		end

	CMS_WITH_WEBAPI

	CMS_WITH_MODULE_ADMINISTRATION

	CMS_HOOK_AUTO_REGISTER

create
	make

feature {NONE} -- Initialization

	make
		do
			version := "0.1.0"
			description := "Storage browser for internal SQL storage"
			package := "custom"
		end

feature -- Access

	name: STRING = "storage"

feature {CMS_API} -- Module Initialization

	initialize (api: CMS_API)
			-- <Precursor>
		local
			l_mod_api: STORAGE_API
		do
			Precursor (api)
			if storage_api = Void then
				create l_mod_api.make (Current, api)
				storage_api := l_mod_api
			end
		end

feature {CMS_API} -- Module management

	install (api: CMS_API)
		local
			l_mod_api: like storage_api
		do
			Precursor {CMS_MODULE_WITH_SQL_STORAGE} (api)
			if is_installed (api) then
				l_mod_api := storage_api
				if l_mod_api = Void then
					create l_mod_api.make (Current, api)
					storage_api := l_mod_api
				end

					-- Configure permissions
				ensure_permissions_are_configured (api)
			end
		end

	ensure_permissions_are_configured (api: CMS_API)
		local
			r: CMS_USER_ROLE
		do
				-- storage-admin role
			r := api.user_api.user_role_by_name (admin_role_name)
			if r = Void then
				create r.make (admin_role_name)
			end
			r.add_permission (Permission_manage)
			r.add_permission (Permission_browse_tables)
			r.add_permission (Permission_query_storage)
			api.user_api.save_user_role (r)
		end

feature -- Access

	admin_role_name: STRING_8
		once
			Result := name + "-admin"
		end

	permissions: LIST [READABLE_STRING_8]
			-- List of permission ids, used by this module, and declared.
		do
			Result := Precursor
			Result.force (Permission_manage)
			Result.force (Permission_browse_tables)
			Result.force (Permission_query_storage)
		end

	Permission_manage: STRING_8 = "manage storage"
	Permission_browse_tables: STRING_8 = "browse storage tables"
	Permission_query_storage: STRING_8 = "query storage"

feature {CMS_API, CMS_MODULE_API, CMS_MODULE} -- Access: API

	storage_api: detachable STORAGE_API
			-- <Precursor>

feature {NONE} -- Administration

	administration: STORAGE_MODULE_ADMINISTRATION
			-- Administration module.
		do
			create Result.make (Current)
		end

feature {NONE} -- Webapi

	webapi: STORAGE_MODULE_WEBAPI
		do
			create Result.make (Current)
		end

feature -- Access: router

	setup_router (a_router: WSF_ROUTER; a_api: CMS_API)
			-- <Precursor>
		do
		end

feature -- Hooks

	setup_hooks (a_hooks: CMS_HOOK_CORE_MANAGER)
		do
			auto_subscribe_to_hooks (a_hooks)
		end

feature -- Mapping helper: uri template agent

	map_uri_template_agent (a_router: WSF_ROUTER; a_tpl: READABLE_STRING_8; proc: PROCEDURE [WSF_REQUEST, WSF_RESPONSE]; rqst_methods: detachable WSF_REQUEST_METHODS)
			-- Map `proc' as handler for `a_tpl' for request methods `rqst_methods'.
		require
			a_tpl_attached: a_tpl /= Void
			proc_attached: proc /= Void
		do
			a_router.map (create {WSF_URI_TEMPLATE_MAPPING}.make (a_tpl, create {WSF_URI_TEMPLATE_AGENT_HANDLER}.make (proc)), rqst_methods)
		end

note
	copyright: "2011-2025, Jocelyn Fiat, Javier Velilla, Eiffel Software and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end

