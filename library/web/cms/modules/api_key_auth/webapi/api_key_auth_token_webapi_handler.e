note
	description: "Summary description for {API_KEY_AUTH_TOKEN_WEBAPI_HANDLER}."
	date: "$Date$"
	revision: "$Revision$"

class
	API_KEY_AUTH_TOKEN_WEBAPI_HANDLER

inherit
	CMS_WEBAPI_HANDLER
		rename
			make as make_with_cms_api
		end

	WSF_URI_TEMPLATE_HANDLER

create
	make

feature {NONE} -- Initialization

	make (mod: API_KEY_AUTH_MODULE_WEBAPI; a_api_key_auth_api: API_KEY_AUTH_API)
		do
			module := mod
			make_with_cms_api (a_api_key_auth_api.cms_api)
			api_key_auth_api := a_api_key_auth_api
		end

feature -- API

	module: API_KEY_AUTH_MODULE_WEBAPI

	api_key_auth_api: API_KEY_AUTH_API

feature -- Execution

	execute (req: WSF_REQUEST; res: WSF_RESPONSE)
			-- Execute handler for `req' and respond in `res'.
		local
			l_uid: READABLE_STRING_GENERAL
		do
			if attached {WSF_STRING} req.path_parameter ("uid") as p_uid then
				l_uid := p_uid.value
				if req.is_post_request_method then
					post_api_token (l_uid, req, res)
				elseif req.is_get_request_method then
					get_api_tokens (l_uid, req, res)
				else
					new_bad_request_error_response (Void, req, res).execute
				end
			else
				new_bad_request_error_response ("Missing {uid} parameter", req, res).execute
			end
		end

feature -- Helper

	user_by_uid (a_uid: READABLE_STRING_GENERAL): detachable CMS_USER
		do
			Result := api.user_api.user_by_id_or_name (a_uid)
		end

feature -- Request execution		

	get_api_tokens (a_uid: READABLE_STRING_GENERAL; req: WSF_REQUEST; res: WSF_RESPONSE)
			-- Execute handler for `req' and respond in `res'.
		local
			rep: HM_WEBAPI_RESPONSE
			tb: STRING_TABLE [detachable ANY]
			arr: ARRAYED_LIST [STRING_TABLE [detachable ANY]]
			l_scopes: detachable READABLE_STRING_GENERAL
		do
			if attached user_by_uid (a_uid) as l_user then
				if attached api.user as u then
					if u.same_as (l_user) or api.user_api.is_admin_user (u) then
						rep := new_response (req, res)
						if attached {WSF_STRING} req.query_parameter ("scopes") as p_scopes then
							l_scopes := p_scopes.value
						end

						if attached api_key_auth_api.user_tokens (l_user, l_scopes) as l_tokens and then not l_tokens.is_empty then
							create arr.make (l_tokens.count)
							across
								l_tokens as t
							loop
								create tb.make (2)
								tb.force (t.key, "token")
								tb.force (t.scopes_as_csv, "scopes")
								arr.extend (tb)
							end
						else
							create arr.make (0)
						end
						rep.add_iterator_field ("access_tokens", arr)
						create tb.make_equal (3)
						tb.force (l_user.name, "name")
						tb.force (l_user.id, "uid")
						rep.add_table_iterator_field ("user", tb)

						rep.add_self (req.percent_encoded_path_info)
						add_user_links_to (l_user, rep)
					else
							-- Only admin, or current user can see its access_token!
						rep := new_access_denied_error_response (Void, req, res)
					end
				else
					rep := new_access_denied_error_response (Void, req, res)
				end
			else
				rep := new_not_found_error_response ("User not found", req, res)
			end
			rep.execute
		end

	post_api_token (a_uid: READABLE_STRING_GENERAL; req: WSF_REQUEST; res: WSF_RESPONSE)
			-- Execute handler for `req' and respond in `res'.
		local
			tb: STRING_TABLE [detachable ANY]
			rep: like new_response
			l_scopes: detachable LIST [READABLE_STRING_GENERAL]
		do
			if attached user_by_uid (a_uid) as l_user then
				if attached api.user as u then
					if u.same_as (l_user) or api.user_api.is_admin_user (u) then
						if
							attached req.string_item ("op") as s_op and then
							s_op.is_case_insensitive_equal ("discard")
						then
							if
								attached {WSF_STRING} req.form_parameter ("token") as s_token
							then
								api_key_auth_api.discard_user_token (l_user, s_token.value)
								if attached api_key_auth_api.user_for_token (s_token.value) then
									rep := new_error_response ("Could not discard token", req, res)
								else
									rep := new_response (req, res)
								end
							else
								rep := new_error_response ("Could not discard token", req, res)
							end
						else
							if attached {WSF_STRING} req.form_parameter ("scopes") as s_scope then
								l_scopes := s_scope.value.split (',')
							end
							if attached api_key_auth_api.new_token (l_user, l_scopes) as l_new_token then
								rep := new_response (req, res)
								rep.add_string_field ("access_token", l_new_token.token.key)
							else
								rep := new_error_response ("Could not create new token", req, res)
							end
						end
						create tb.make_equal (2)
						tb.force (l_user.name, "name")
						tb.force (l_user.id, "uid")
						rep.add_table_iterator_field ("user", tb)
						rep.add_self (req.percent_encoded_path_info)
						add_user_links_to (l_user, rep)
					else
							-- Only admin, or current user can create the user access_token!
						rep := new_access_denied_error_response (Void, req, res)
					end
				else
					rep := new_access_denied_error_response (Void, req, res)
				end
			else
				rep := new_not_found_error_response ("User not found", req, res)
			end
			rep.execute
		end

note
	copyright: "2011-2017, Jocelyn Fiat, Javier Velilla, Eiffel Software and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end

