note
	description: "Summary description for {JWT_AUTH_MODULE}."
	date: "$Date$"
	revision: "$Revision$"

class
	JWT_AUTH_MODULE

inherit
	CMS_MODULE_WITH_SQL_STORAGE
		rename
			module_api as jwt_auth_api
		redefine
			permissions,
			initialize,
			install,
			setup_hooks,
			jwt_auth_api,
			uninstall, update
--		select
--			uninstall, update
		end

	CMS_AUTH_MODULE_I
		rename
			module_api as jwt_auth_api
		redefine
			make,
			setup_hooks,
			initialize,
			install,
			permissions,
			has_permission_to_use_authentication,
			jwt_auth_api,
			uninstall, update
		end

	CMS_WITH_WEBAPI

	CMS_HOOK_AUTO_REGISTER

	CMS_HOOK_FORM_ALTER

	CMS_HOOK_CLEANUP

	CMS_HOOK_BLOCK

	CMS_HOOK_AUTHENTICATION

	CMS_WITH_MODULE_ADMINISTRATION

create
	make

feature {NONE} -- Initialization

	make
		do
			Precursor {CMS_AUTH_MODULE_I}
			version := "1.1"
			description := "JWT authentication"
			package := "jwt_auth"
			add_optional_dependency ({CMS_SESSION_AUTH_MODULE})
		end

feature -- Access

	name: STRING = "jwt_auth"

	permissions: LIST [READABLE_STRING_8]
			-- List of permission ids, used by this module, and declared.
		do
			Result := Precursor
			Result.force (perm_request_magic_login)
			Result.force (perm_use_magic_login)
			Result.force (perm_use_client_sign_in)
			Result.force (perm_manage_own_tokens)
		end

	perm_request_magic_login: STRING = "request magic_login"
	perm_use_magic_login: STRING = "use magic_login"
	perm_use_client_sign_in: STRING = "use client_sign_in"
	perm_manage_own_tokens: STRING = "manage own jwt tokens"

	has_permission_to_use_authentication (api: CMS_API): BOOLEAN
		do
			Result := api.has_permission (perm_request_magic_login)
			if not Result then
				Result := attached api.setup.text_item ("modules." + name + ".login") as s and then s.is_case_insensitive_equal ("on")
			end
		end

feature {CMS_API} -- Module Initialization			

	initialize (api: CMS_API)
			-- <Precursor>
		do
			Precursor (api)
			create jwt_auth_api.make (api)
		end

feature {CMS_API} -- Module management

	install (api: CMS_API)
		do
				-- Schema
			if attached api.storage.as_sql_storage as l_sql_storage then
				l_sql_storage.sql_execute_file_script (api.module_resource_location (Current, (create {PATH}.make_from_string ("scripts")).extended ("install.sql")), Void)

				if l_sql_storage.has_error then
					api.logger.put_error ("Could not initialize database for module [" + name + "]", generating_type)
				else
					Precursor {CMS_MODULE_WITH_SQL_STORAGE} (api)
				end
			end
		end

	uninstall (api: CMS_API)
			-- (export status {CMS_API})
		do
			Precursor {CMS_MODULE_WITH_SQL_STORAGE} (api)
		end

	update (a_installed_version: READABLE_STRING_GENERAL; api: CMS_API)
			-- Update module from version `a_installed_version` to current `version`.		
		do
			Precursor {CMS_MODULE_WITH_SQL_STORAGE} (a_installed_version, api)
		end

feature {CMS_EXECUTION} -- Administration

	webapi: JWT_AUTH_MODULE_WEBAPI
		do
			create Result.make (Current)
		end

feature -- Access: auth strategy	

	login_title: STRING = "Sign In With Email"
			-- Module specific login title.

	login_location: STRING = "account/auth/roc-magic-login"

	logout_location: STRING = "account/auth/roc-magic-logout"

	is_authenticating (a_response: CMS_RESPONSE): BOOLEAN
			-- <Precursor>
		do
			-- TODO
		end

feature {NONE} -- Administration

	administration: CMS_SELF_MODULE_ADMINISTRATION [JWT_AUTH_MODULE]
			-- Administration module.
		do
			create Result.make (Current)
		end

feature {CMS_API, CMS_MODULE_API, CMS_MODULE} -- Access: API

	jwt_auth_api: detachable JWT_AUTH_API
			-- <Precursor>

feature -- Access: router

	setup_router (a_router: WSF_ROUTER; a_api: CMS_API)
			-- <Precursor>
		do
			if attached jwt_auth_api as l_jwt_auth_api then
				a_router.handle ("/user/{uid}/jwt_access_token", create {JWT_AUTH_TOKEN_USER_HANDLER}.make (l_jwt_auth_api), a_router.methods_get_post)
				a_router.handle ("/user/{uid}/magic-login/{token}", create {JWT_AUTH_MAGIC_LOGIN_HANDLER}.make (l_jwt_auth_api), a_router.methods_get)

				a_router.handle ("/auth/client-sign-in/{challenge}", create {JWT_AUTH_SIGN_IN_HANDLER}.make (l_jwt_auth_api, Current), a_router.methods_get_post)

				a_router.handle ("/" + login_location, create {WSF_URI_AGENT_HANDLER}.make (agent handle_login (l_jwt_auth_api, a_api, ?, ?)), a_router.methods_get_post)
				a_router.handle ("/" + logout_location, create {WSF_URI_AGENT_HANDLER}.make (agent handle_logout (a_api, l_jwt_auth_api, ?, ?)), a_router.methods_get_post)
--				a_router.handle ("/" + login_location, create {WSF_URI_AGENT_HANDLER}.make (agent handle_login_with_session (a_api, l_session_api, ?, ?)), a_router.methods_post)
			end
		end

feature {NONE} -- Implementation: routes		

	handle_login (a_jwt_auth_api: JWT_AUTH_API; api: CMS_API; req: WSF_REQUEST; res: WSF_RESPONSE)
		local
			r: CMS_RESPONSE
			u: CMS_USER
			l_subject, l_message: STRING_8
			m: CMS_EMAIL
			vals: CMS_VALUE_TABLE
		do
			create {GENERIC_VIEW_CMS_RESPONSE} r.make (req, res, api)
			if api.user_is_authenticated then
				r.add_error_message ("You are already signed in!")
			elseif req.is_post_request_method then
				if attached {WSF_STRING} req.form_parameter ("username") as p_username then
					u := api.user_api.user_by_name (p_username.value)
					if u = Void then
						u := api.user_api.user_by_email (p_username.value)
					end
					if u = Void then
						r.add_error_message ("Unknown user")
						get_block_into_response ("sign_in_with_email", Void, r)
					elseif attached u.email as l_u_email then
						if attached new_magic_login_link (u, 300) as lnk then

							l_subject := "Your temporary " + utf_8_encoded (api.setup.site_name) + " login magic link" -- + lnk.token
							create vals.make (4)
							vals ["username"] := p_username.value
							vals ["site_url"] := api.absolute_url ("", Void)
							vals ["site_name"] := html_encoded (api.setup.site_name)
							vals ["lnk"] := lnk.url
							vals ["token"] := lnk.token

							if attached email_html_message ("magic_link_message", r, vals) as tpl_msg then
								l_message := tpl_msg
							else
								l_message := "[
									<!doctype html>
									<html lang="en">
										<head>
										  <meta charset="utf-8">
										  <title>Sign In With Magic Link</title>
										  <meta name="description" content="Sign In With Magic Link">
										  <meta name="author" content="{$site_name/}">
										</head>
										<body>
											<h1>Sign in to {$site_name/}</h1>
											<p><strong>Code:</strong> {$token/}<p>
											<p>
											<a href="{$lnk/}">Sign in with Magic Link</a>
											</p>
											<p>If you didn't request this email, there's nothing to worry about - you can safely ignore it.</p>
											<p><a href="{$site_url/}">{$site_name/} website</a></p>
										</body>
									</html>
								]"
								across
									vals as v
								loop
									if attached {READABLE_STRING_GENERAL} v as s then
										l_message.replace_substring_all ("{$"+ url_encoded (@v.key) +"/}", html_encoded (s))
									else
										-- TODO
--										l_message.replace_substring_all ("{$"+ url_encoded (@v.key) +"/}", v)
									end
								end
							end

							m := api.new_html_email (l_u_email, l_subject, l_message)
							api.process_email (m)

							get_block_into_response ("sign_in_with_email_notification", vals, r)
--							r.set_main_content ("We sent a magic link to your inbox.")
							-- TODO: add "Resend magic link"
						else
							r.add_error_message ("Error: unable to create the magic link!")
						end
					else
						r.add_error_message ("Account is missing email information!")
					end
				else
					r.add_error_message ("Missing username or email address!")
					get_block_into_response ("sign_in_with_email", vals, r)
				end
			else
				get_block_into_response ("sign_in_with_email", vals, r)
			end
			r.execute
		end

	handle_logout (api: CMS_API; a_mod_api: JWT_AUTH_API ; req: WSF_REQUEST; res: WSF_RESPONSE)
		local
			r: CMS_RESPONSE
		do
			if attached api.user as l_user then
--				a_mod_api.process_user_logout (l_user, req, res)
				create {GENERIC_VIEW_CMS_RESPONSE} r.make (req, res, api)
			else
					-- Not loggued in ... redirect to home
				create {GENERIC_VIEW_CMS_RESPONSE} r.make (req, res, api)
				r.set_status_code ({HTTP_CONSTANTS}.found)
			end
			if attached api.logout_destination_location (req) as v then
				r.set_redirection (secured_url_content (v))
			elseif attached api.destination_location (req) as v then
				r.set_redirection (secured_url_content (v))
			else
				r.set_redirection (r.absolute_url ("", Void))
			end

			r.execute
		end

feature -- Link factory

	new_magic_login_link (a_user: CMS_USER; a_expiration_in_seconds: NATURAL_32): detachable TUPLE [url: READABLE_STRING_8; token: READABLE_STRING_8]
		do
			if attached jwt_auth_api as l_jwt_api then
				Result := l_jwt_api.new_magic_login_link (a_user, a_expiration_in_seconds)
			end
		end

feature -- Hooks configuration

	setup_hooks (a_hooks: CMS_HOOK_CORE_MANAGER)
			-- Module hooks configuration.
		do
			a_hooks.subscribe_to_form_alter_hook (Current)
			a_hooks.subscribe_to_cleanup_hook (Current)
			a_hooks.subscribe_to_block_hook (Current)
			a_hooks.subscribe_to_hook (Current, {CMS_HOOK_AUTHENTICATION})
		end

feature -- Auth hook

	get_login_redirection (a_response: CMS_RESPONSE; a_destination_url: detachable READABLE_STRING_8)
		local
			loc: READABLE_STRING_8
		do
			if has_permission_to_use_authentication (a_response.api) then
				loc := a_response.redirection
				if loc = Void or else loc.has_substring ("magic") then
					if a_destination_url /= Void then
						a_response.set_redirection (login_location + "?destination=" + secured_url_content (a_destination_url))
					else
						a_response.set_redirection (login_location)
					end
				end
			end
		end

	block_list: ITERABLE [like {CMS_BLOCK}.name]
		do
			Result := <<"?login">>
		end

	get_block_view (a_block_id: READABLE_STRING_8; a_response: CMS_RESPONSE)
		do
			if a_block_id.is_case_insensitive_equal_general ("login") then
				get_block_into_response ("sign_in_with_email", Void, a_response)
			end
		end

feature -- Hook

	cleanup (ctx: CMS_HOOK_CLEANUP_CONTEXT; a_response: CMS_RESPONSE)
			-- Process cron event
		local
			dt: DATE_TIME
			cl: CELL [INTEGER]
		do
			if attached jwt_auth_api as l_api then
				ctx.log ("Cleanup expired JWT Auth tokens.")
				create dt.make_now_utc
				create cl.put (0)
				l_api.discard_expired_tokens (dt, cl)
				ctx.log (cl.item.out + " were discarded.")
			end
		end

	form_alter (a_form: CMS_FORM; a_form_data: detachable WSF_FORM_DATA; a_response: CMS_RESPONSE)
			-- Hook execution on form `a_form' and its associated data `a_form_data',
			-- for related response `a_response'.
		do
			if
				attached jwt_auth_api as l_jwt_auth_api and then
				attached a_form.id as fid
			then
				if
					fid.same_string ({CMS_AUTHENTICATION_MODULE}.view_account_form_id) and then
					attached a_response.user as u and then
					a_response.has_permission (perm_manage_own_tokens)
				then
					a_form.extend_html_text ("<hr/><h4>Authentication with JWT token</h4><ul><li><a href=%"" + a_response.url ("/user/" + u.id.out + "/jwt_access_token", Void) + "%">manage your tokens.</a></li></ul>%N")
				end
			end
		end

feature {NONE} -- Block views

	get_block_into_response (a_block_id: READABLE_STRING_8; vals: detachable CMS_VALUE_TABLE; a_response: CMS_RESPONSE)
		local
			bk: CMS_CONTENT_BLOCK
			f: CMS_FORM
			b: STRING_8
			tf: WSF_FORM_TEXT_INPUT
			sub: WSF_FORM_SUBMIT_INPUT
		do
			if attached smarty_template_login_block (a_response.request, Current, a_block_id, a_response.api) as l_tpl_block then
					-- add the variable to the block
				l_tpl_block.set_value (a_response.api.user, "user")
				l_tpl_block.set_value (a_response.api.site_url, "site_url")
				if vals /= Void then
					a_response.api.hooks.invoke_value_table_alter (vals, a_response)
					across
						vals as v
					loop
						l_tpl_block.set_value (v, @v.key)
					end
				end
				a_response.add_block (l_tpl_block, "content")
			elseif a_block_id.is_case_insensitive_equal ("sign_in_with_email") then
				create f.make ("/" + login_location, "request-magic-link")
				f.set_method_post
				create tf.make ("username")
				tf.set_description ("Enter username or email")
				f.extend (tf)

				create sub.make_with_text ("op", "Request")
				f.extend (sub)

				create b.make_empty
				f.append_to_html (a_response.wsf_theme, b)

				create bk.make ("magic-login", Void, b, Void)
				a_response.add_block (bk, "content")
				debug ("cms")
					a_response.add_warning_message ("Error with block [" + a_block_id + "]")
				end
			elseif a_block_id.is_case_insensitive_equal ("sign_in_with_email_notification") then

			end
		end

	email_html_message (a_message_id: READABLE_STRING_8; a_response: CMS_RESPONSE; a_html_encoded_values: CMS_VALUE_TABLE): detachable STRING_8
			-- html message related to `a_message_id'.
		local
			res: PATH
			p: detachable PATH
			tpl: CMS_SMARTY_TEMPLATE_BLOCK
		do
			create res.make_from_string ("mail_templates")
			res := res.extended (a_message_id).appended_with_extension ("html")
			p := a_response.api.module_theme_resource_location (Current, res)
			if p /= Void then
				if attached p.entry as e then
					create tpl.make (a_message_id, Void, p.parent, e)
				else
					create tpl.make (a_message_id, Void, p.parent, p)
				end
				across
					a_html_encoded_values as v
				loop
					tpl.set_value (v, @v.key)
				end
				Result := tpl.to_html (a_response.theme)
			end
		end

end
