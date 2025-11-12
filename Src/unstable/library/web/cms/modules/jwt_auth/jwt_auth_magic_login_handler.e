note
	description: "Summary description for {JWT_AUTH_MAGIC_LOGIN_HANDLER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	JWT_AUTH_MAGIC_LOGIN_HANDLER

inherit
	CMS_HANDLER
		rename
			make as make_with_cms_api
		end

	WSF_URI_TEMPLATE_HANDLER

create
	make

feature {NONE} -- Initialization

	make (a_jwt_auth_api: JWT_AUTH_API)
		do
			make_with_cms_api (a_jwt_auth_api.cms_api)
			jwt_auth_api := a_jwt_auth_api
		end

feature -- API

	jwt_auth_api: JWT_AUTH_API

feature -- Execution

	execute (req: WSF_REQUEST; res: WSF_RESPONSE)
			-- Execute handler for `req' and respond in `res'.
		local
			l_uid: READABLE_STRING_GENERAL
		do
			if attached {WSF_STRING} req.path_parameter ("uid") as p_uid then
				l_uid := p_uid.value
				if req.is_get_request_method then
					handle_magic_login (l_uid, req, res)
				else
					send_bad_request (req, res)
				end
			else
				send_bad_request (req, res)
			end
		end

feature -- Helper

	user_by_uid (a_uid: READABLE_STRING_GENERAL): detachable CMS_USER
		do
			Result := api.user_api.user_by_id_or_name (a_uid)
		end

feature -- Request execution		

	handle_magic_login (a_uid: READABLE_STRING_GENERAL; req: WSF_REQUEST; res: WSF_RESPONSE)
			-- Execute handler for `req' and respond in `res'.
		local
			rep: CMS_RESPONSE
			l_redirection_location: READABLE_STRING_8
			l_is_external: BOOLEAN
			tok_loader: JWT_LOADER
			h: STRING_8
			bloc: CMS_MODAL_CONTENT_BLOCK
		do
			if attached user_by_uid (a_uid) as l_user then
				if
				 	l_user.is_active and then
					not api.user_api.is_admin_user (l_user) and then -- Forbid this magic link for administrator! (security)
					api.user_has_permission (l_user, {JWT_AUTH_MODULE}.perm_use_magic_login)
				then
					if attached {WSF_STRING} req.path_parameter ("token") as p_token then
						if
							attached jwt_auth_api.user_for_token (p_token.value) as l_token_user and then
							l_token_user.same_as (l_user)
						then
							create tok_loader
							if
								attached jwt_auth_api.token (p_token.value) as tok and then
								attached {JWT} tok.jwt as jwt
							then
								if attached jwt.claimset.string_8_claim ("external_location") as loc then
									l_redirection_location := loc
									l_is_external := True
								elseif attached jwt.claimset.string_8_claim ("location") as loc then
									l_redirection_location := loc
								end
							end

							if not l_is_external then
								if attached {CMS_SESSION_API} api.module_api ({CMS_SESSION_AUTH_MODULE}) as l_session_api then
									l_session_api.process_user_login (l_user, req, res)
								end
							end

							jwt_auth_api.discard_user_token (l_user, p_token.value)
							rep := new_generic_response (req, res)
							rep.set_title ({STRING_32} "Magic login for user " + api.real_user_display_name (l_user))
							if l_redirection_location /= Void then
								if l_is_external then
									if attached jwt_auth_api.new_token (l_user, Void) as tok then
										rep.set_redirection (l_redirection_location + "?auth=magic-link&uid="+ l_user.id.out +"&username=" + url_encoded (l_user.name) + "&token=" + tok.token + "&refresh=" + tok.refresh_key)
									else
										rep.set_redirection (l_redirection_location)
									end
								else
									rep.set_redirection (l_redirection_location)
								end
							elseif attached rep.destination_location as v then
								rep.set_redirection (v)
							else
								rep.set_redirection (api.absolute_url ("/", Void))
							end
							rep.add_success_message ("Successfully signed-in as user " +  api.user_html_link (l_user) + " .")
							rep.execute
						else
							rep := new_generic_response (req, res)
							rep.set_title ({STRING_32} "Magic login")
							rep.add_error_message ("Invalid token or already used!")
							h := "[
									This magic link is no longer valid.<br/> It may have already been used.
								]"
							rep.set_main_content ("")
							create bloc.make_raw ("magic-login-error", Void, h, Void)
							bloc.set_close_link_html_text ("Now, you can close this page")
							bloc.add_css_class ("modal-overlay")
							rep.add_block (bloc, "content")
							rep.execute
						end
					else
						send_bad_request (req, res)
					end
				else
					send_custom_access_denied ("You are not permitted to login with magic link", <<{JWT_AUTH_MODULE}.perm_use_magic_login>>, req, res)
				end
			else
				send_not_found (req, res)
			end
		end

note
	copyright: "2011-2020, Jocelyn Fiat, Javier Velilla, Eiffel Software and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"

end
