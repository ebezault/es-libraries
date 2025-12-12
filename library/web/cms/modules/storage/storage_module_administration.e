note
	description: "Summary description for {STORAGE_MODULE_ADMINISTRATION}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	STORAGE_MODULE_ADMINISTRATION

inherit
	CMS_MODULE_ADMINISTRATION [STORAGE_MODULE]
		redefine
			setup_hooks,
			permissions
		end

	CMS_HOOK_AUTO_REGISTER

	CMS_HOOK_MENU_SYSTEM_ALTER

create
	make

feature -- Security

	permissions: LIST [READABLE_STRING_8]
			-- List of permission ids, used by this module, and declared.
		do
			Result := Precursor;
--			Result.force ("admin custom blocks")
		end

feature {NONE} -- Router/administration

	setup_administration_router (a_router: WSF_ROUTER; a_api: CMS_API)
			-- Setup url dispatching for Current module administration.
			-- (note: `a_router` is already based with admin path prefix).
		local
		do
			if attached module.storage_api as l_api then
				a_router.handle ("/storage/", create {WSF_URI_AGENT_HANDLER}.make (agent handle_storage_browser (?, ?, l_api)), a_router.Methods_get)
			end
		end

feature -- Hooks

	setup_hooks (a_hooks: CMS_HOOK_CORE_MANAGER)
		do
			auto_subscribe_to_hooks (a_hooks)
		end

feature -- Hooks

	menu_system_alter (a_menu_system: CMS_MENU_SYSTEM; a_response: CMS_RESPONSE)
			-- Hook execution on collection of menu contained by `a_menu_system'
			-- for related response `a_response'.
		local
			lnk: CMS_LOCAL_LINK
		do
				 -- Add the link to the taxonomy to the main menu
			if a_response.has_permission ({STORAGE_MODULE}.Permission_browse_tables) or a_response.api.user_is_administrator then
				lnk := a_response.api.administration_link ("Storage", "storage/")
				lnk.set_weight (100)
				lnk.set_permission_arguments (<<{STORAGE_MODULE}.Permission_browse_tables, {STORAGE_MODULE}.permission_manage, {STORAGE_MODULE}.permission_query_storage>>)
				a_menu_system.management_menu.extend_into (lnk, "Admin", a_response.api.administration_path_location (""))

--				lnk := a_response.api.local_link ("Storage", "system/storage/browser")
--				a_menu_system.navigation_menu.extend (lnk)
--				a_menu_system.management_menu.extend (lnk)
			end
		end

feature -- Handler

	handle_storage_browser (req: WSF_REQUEST; res: WSF_RESPONSE; a_storage_api: STORAGE_API)
		local
			r: GENERIC_VIEW_CMS_RESPONSE
--			tpl: CMS_SMARTY_TEMPLATE_BLOCK
			tpl: CMS_MUSTACHE_TEMPLATE_BLOCK
			l_tpl_path: PATH
			p: detachable PATH
			api_path: STRING_8
		do
			create {GENERIC_VIEW_CMS_RESPONSE} r.make (req, res, a_storage_api.cms_api)
			if not a_storage_api.cms_api.has_permission ({STORAGE_MODULE}.Permission_browse_tables) then
				r.set_main_content ("<div class='error'><p>Access denied. You need 'browse storage tables' permission.</p></div>")
			else
				create l_tpl_path.make_from_string ("templates")
				l_tpl_path := l_tpl_path.extended ("storage_browser").appended_with_extension ("tpl")
				p := a_storage_api.cms_api.module_resource_location (Current, l_tpl_path)
				if p /= Void then
					api_path := a_storage_api.cms_api.webapi_path ("/v1/storage")
--					if attached a_storage_api.cms_api.file_content (p) as txt then
--						txt.replace_substring_all ("{{api_path}}", api_path)
--						r.set_main_content (txt)
--					end
					if attached p.entry as e then
						create tpl.make ("storage_browser", Void, p.parent, e)
					else
						create tpl.make ("storage_browser", Void, p.parent, p)
					end
					tpl.set_is_raw (True)
					tpl.set_value (api_path, "api_path")
					r.set_main_content (tpl.to_html (Void))

					r.set_title ("Storage Browser")
					r.set_page_class_css ("full")
				else
					-- Fallback if template not found
					r.set_main_content ("<div class='error'><p>Template file not found.</p></div>")
				end
			end
			r.execute
		end


end

