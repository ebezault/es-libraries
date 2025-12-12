note
	description: "[
			Module for handling API key authentication in the CMS system.
			Provides functionality for managing API keys, including creation, validation and cleanup.
			
			Example usage:
			curl -H "X-API-Key: abcd1234" http://localhost:9090/
		]"
	date: "$Date$"
	revision: "$Revision$"

class
	API_KEY_AUTH_MODULE

inherit
	CMS_MODULE_WITH_SQL_STORAGE
		rename
			module_api as api_key_auth_api
		redefine
			permissions,
			initialize,
			install,
			setup_hooks,
			api_key_auth_api
		end

	CMS_WITH_WEBAPI

	CMS_HOOK_AUTO_REGISTER

	CMS_HOOK_FORM_ALTER

	CMS_HOOK_CLEANUP

	CMS_WITH_MODULE_ADMINISTRATION

create
	make

feature {NONE} -- Initialization

	make
			-- Module initialization with version and dependencies
		do
			version := "1.0"
			description := "API Key authentication"
			package := "api_key_auth"
			add_optional_dependency ({CMS_SESSION_AUTH_MODULE})
		end

feature -- Access

	name: STRING = "api_key_auth"
			-- Module identifier

	permissions: LIST [READABLE_STRING_8]
			-- List of permission identifiers required by this module
		do
			Result := Precursor
			Result.force (perm_manage_own_api_keys)
		end

	perm_manage_own_api_keys: STRING = "manage own api keys"
			-- Permission string for managing user's own API keys

feature {CMS_API} -- Module Initialization			

	initialize (api: CMS_API)
			-- Initialize module with `api` configuration
		do
			Precursor (api)
			create api_key_auth_api.make (api)
		end

feature {CMS_API} -- Module management

	install (api: CMS_API)
			-- Install module database schema using `api` configuration
		do
			Precursor {CMS_MODULE_WITH_SQL_STORAGE} (api)
		end

feature {CMS_EXECUTION} -- Administration

	webapi: API_KEY_AUTH_MODULE_WEBAPI
			-- Web API interface for API key authentication
		do
			create Result.make (Current)
		end

feature {NONE} -- Administration

	administration: CMS_SELF_MODULE_ADMINISTRATION [API_KEY_AUTH_MODULE]
			-- Administration interface for this module
		do
			create Result.make (Current)
		end

feature {CMS_API, CMS_MODULE_API, CMS_MODULE} -- Access: API

	api_key_auth_api: detachable API_KEY_AUTH_API
			-- API interface for API key authentication operations

feature -- Access: router

	setup_router (a_router: WSF_ROUTER; a_api: CMS_API)
			-- Configure routing for API key endpoints using `a_router` and `a_api`
		local
			h: API_KEY_AUTH_TOKEN_USER_HANDLER
		do
			if attached api_key_auth_api as l_api_key_auth_api then
				create h.make (l_api_key_auth_api, current)
				a_router.handle ("/user/{uid}/api_keys/{keyid}", h, a_router.methods_get_post)
				a_router.handle ("/user/{uid}/api_keys/", h, a_router.methods_get_post)
				a_router.handle ("/user/{uid}/api_keys", h, a_router.methods_get_post)
			end
		end

feature -- Hooks configuration

	setup_hooks (a_hooks: CMS_HOOK_CORE_MANAGER)
			-- Configure module hooks using `a_hooks` manager
		do
			a_hooks.subscribe_to_form_alter_hook (Current)
			a_hooks.subscribe_to_cleanup_hook (Current)
		end

feature -- Hook

	cleanup (ctx: CMS_HOOK_CLEANUP_CONTEXT; a_response: detachable CMS_RESPONSE)
			-- Cleanup expired tokens using `ctx` context and `a_response`
		local
			dt: DATE_TIME
			cl: CELL [INTEGER]
		do
			if attached api_key_auth_api as l_api then
				ctx.log ("Cleanup expired API KEYs.")
				create dt.make_now_utc
				create cl.put (0)
				l_api.discard_expired_or_revoked_tokens (dt, cl)
				ctx.log (cl.item.out + " were discarded.")
			end
		end

	form_alter (a_form: CMS_FORM; a_form_data: detachable WSF_FORM_DATA; a_response: CMS_RESPONSE)
			-- Modify form `a_form` with API key management options using `a_form_data` and `a_response`
		do
			if
				attached api_key_auth_api as l_api_key_auth_api and then
				attached a_form.id as fid
			then
				if
					fid.same_string ({CMS_AUTHENTICATION_MODULE}.view_account_form_id) and then
					attached a_response.user as u and then
					a_response.has_permission (perm_manage_own_api_keys)
				then
					a_form.extend_html_text ("<hr/><h4>Authentication with API Key</h4><ul><li><a href=%"" + a_response.url ("/user/" + u.id.out + "/api_keys", Void) + "%">manage your keys.</a></li></ul>%N")
				end
			end
		end

end
