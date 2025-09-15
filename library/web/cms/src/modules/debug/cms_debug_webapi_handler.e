note
	description: "Summary description for {CMS_DEBUG_WEBAPI_HANDLER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	CMS_DEBUG_WEBAPI_HANDLER

inherit
	CMS_WEBAPI_HANDLER
		rename
			make as make_with_cms_api
		redefine
			new_response
		end

feature {NONE} -- Initialization

	make (a_cms_api: CMS_API; a_router: WSF_ROUTER)
		do
			make_with_cms_api (a_cms_api)
			setup_router (a_router)
		end

feature -- API

	new_response (req: WSF_REQUEST; res: WSF_RESPONSE): JSON_WEBAPI_RESPONSE
		do
			create Result.make (req, res, api)
		end

feature -- Basic operations

	setup_router (a_router: WSF_ROUTER)
			-- Setup url dispatching for Current handler.
			-- (note: `a_router` is already based with path prefix).
		deferred
		end

note
	copyright: "2011-2025, Jocelyn Fiat, Javier Velilla, Eiffel Software and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end
