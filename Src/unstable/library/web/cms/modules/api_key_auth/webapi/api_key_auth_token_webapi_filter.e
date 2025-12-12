note
	description: "Summary description for {API_KEY_AUTH_TOKEN_WEBAPI_FILTER}."
	date: "$Date$"
	revision: "$Revision$"

class
	API_KEY_AUTH_TOKEN_WEBAPI_FILTER

inherit
	CMS_WEBAPI_AUTH_FILTER
		rename
			make as make_filter
		end

create
	make

feature {NONE} -- Initialization

	make (a_api: CMS_API; a_api_key_auth_api: API_KEY_AUTH_API)
			-- Initialize Current handler with `a_api'.
		do
			make_filter (a_api)
			api_key_auth_api := a_api_key_auth_api
		end

feature -- API Service

	api_key_auth_api: API_KEY_AUTH_API

feature -- Basic operations

	execute (req: WSF_REQUEST; res: WSF_RESPONSE)
			-- Execute the filter.
		do
			if
				attached req.meta_string_variable ("HTTP_X_API_KEY") as l_x_api_key and then
				not l_x_api_key.is_empty
			then
				if
					attached api_key_auth_api.user_token_for_request_api_key (l_x_api_key) as l_tok and then
					attached l_tok.user as l_user and then
					l_user.is_active
				then
					if api.user_has_permission (l_user, {API_KEY_AUTH_MODULE_WEBAPI}.perm_use_api_key_auth) then
						api.set_user (l_user)
						api_key_auth_api.set_current_user_token (l_tok)
					end
				end
			end
			execute_next (req, res)
		end

note
	copyright: "2011-2017, Jocelyn Fiat, Javier Velilla, Eiffel Software and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end
