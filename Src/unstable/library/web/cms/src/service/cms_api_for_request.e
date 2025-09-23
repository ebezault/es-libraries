note
	description: "[
			Objects that ...
		]"
	author: "$Author$"
	date: "$Date$"
	revision: "$Revision$"

class
	CMS_API_FOR_REQUEST

inherit
	CMS_API
		rename
			make as make_api
		redefine
			response_api,
			execution_variable, set_execution_variable, unset_execution_variable,
			output_log, time_stamp,
			site_url_suggestion
		end

create
	make

feature {NONE} -- Initialization

	make (a_setup: CMS_SETUP; req: WSF_REQUEST; resp: WSF_RESPONSE)
			-- Create the API service with a setup `a_setup'
			-- and request `req', response `resp`.
		do
			request := req
			response := resp
			make_api (a_setup)
		end

feature {NONE} -- Access: request

	request: WSF_REQUEST
			-- Associated http request.
			--| note: here for the sole purpose of CMS_API.

	response: WSF_RESPONSE
			-- Associated http response.
			--| note: here for the sole purpose of CMS_API, mainly to report error.

feature -- Access: API

	response_api: CMS_RESPONSE_API
			-- API to send predefined cms responses.
		local
			l_api: like internal_response_api
		do
			l_api := internal_response_api
			if l_api = Void then
				create l_api.make (Current)
				internal_response_api := l_api
			end
			Result := l_api
		end

feature {NONE} -- Access: API

	internal_response_api: detachable like response_api
			-- Cached value for `response_api`.	

feature {NONE} -- Access: request

	site_url_suggestion: STRING_8
			-- Site_url from environment (request or cli)
		do
			Result := request.absolute_script_url ("/")
		end

	time_stamp: INTEGER_64
			-- Execution time stamp (UTC)	 (unix time stamp)	
		do
			Result := request.request_time_stamp
		end

feature -- Access: request

	self_link: CMS_LOCAL_LINK
		local
			s: READABLE_STRING_8
			loc: READABLE_STRING_8
		do
			s := request.percent_encoded_path_info
			if not s.is_empty and then s[1] = '/' then
				loc := s.substring (2, s.count)
			else
				loc := s
			end
			if attached request.query_string as q and then not q.is_whitespace then
				loc := loc + "?" + q
			end
			Result := local_link (Void, loc)
		end

feature {NONE} -- Logging / implementation

	output_log (m: STRING_8; a_level: INTEGER)
		do
			Precursor (m, a_level)
			inspect a_level
			when
				{CMS_LOG}.level_emergency,
				{CMS_LOG}.level_alert,
				{CMS_LOG}.level_critical,
				{CMS_LOG}.level_error,
				{CMS_LOG}.level_debug
			then
				response.put_error (m)
			else
			end
		end

feature -- Request utilities

	execution_variable (a_name: READABLE_STRING_GENERAL): detachable ANY
			-- Execution variable related to `a_name'
		do
			Result := request.execution_variable (a_name)
		end

	set_execution_variable (a_name: READABLE_STRING_GENERAL; a_value: detachable ANY)
		do
			request.set_execution_variable (a_name, a_value)
		end

	unset_execution_variable (a_name: READABLE_STRING_GENERAL)
		do
			request.unset_execution_variable (a_name)
		end

invariant
--	invariant_clause: True

note
	copyright: "2011-2025, Jocelyn Fiat, Javier Velilla, Eiffel Software and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end
