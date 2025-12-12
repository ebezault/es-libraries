note
	description: "Base handler for storage WebAPI."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	STORAGE_WEBAPI_HANDLER

inherit
	CMS_WEBAPI_HANDLER
		rename
			make as make_with_cms_api
		redefine
			new_response
		end

	WSF_URI_TEMPLATE_HANDLER
		rename
			execute as handler_execute
		end

feature {NONE} -- Initialization

	make (a_mod_api: STORAGE_API; a_router: WSF_ROUTER)
		do
			make_with_cms_api (a_mod_api.cms_api)
			storage_api := a_mod_api
			setup_router (a_router)
		end

feature -- API

	default_api_version: STRING_8 = "v1"

	storage_api: STORAGE_API

	new_response (req: WSF_REQUEST; res: WSF_RESPONSE): HM_WEBAPI_RESPONSE
		do
			Result := Precursor (req, res)
		end

feature -- Access

	is_authentication_required: BOOLEAN
		do
			Result := True
		end

feature -- Access

	versioned_base_uri_template: IMMUTABLE_STRING_8 = "/{version}/"

feature -- Basic operations

	setup_router (a_router: WSF_ROUTER)
			-- Setup url dispatching for Current handler.
			-- (note: `a_router` is already based with path prefix).
		deferred
		end

feature -- Execution

	handler_execute (req: WSF_REQUEST; res: WSF_RESPONSE)
			-- Execute handler for `req' and respond in `res'.
		do
			if attached {WSF_STRING} req.path_parameter ("version") as p_version then
				if
					is_authentication_required and then
					not api.user_is_authenticated
				then
					report_not_authenticated_error (req, res)
				else
					if
						is_authentication_required and then
						not api.has_permission ({STORAGE_MODULE}.Permission_browse_tables)
					then
						report_access_denied_error (req, res)
					else
						execute (p_version.value, req, res)
					end
				end
			else
				report_version_missing_error (req, res)
			end
		end

	report_not_authenticated_error (req: WSF_REQUEST; res: WSF_RESPONSE)
		do
			new_access_denied_error_response ("Authentication is required", req, res).execute
		end

	report_access_denied_error (req: WSF_REQUEST; res: WSF_RESPONSE)
		do
			new_access_denied_error_response ("Access is denied", req, res).execute
		end

	report_version_missing_error (req: WSF_REQUEST; res: WSF_RESPONSE)
		do
			new_bad_request_error_response ("Missing {version} parameter", req, res).execute
		end

	execute (a_version: READABLE_STRING_GENERAL; req: WSF_REQUEST; res: WSF_RESPONSE)
		deferred
		end

note
	copyright: "2011-2025, Jocelyn Fiat, Javier Velilla, Eiffel Software and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end

