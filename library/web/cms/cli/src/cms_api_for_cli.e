note
	description: "[
			Objects that ...
		]"
	author: "$Author$"
	date: "$Date$"
	revision: "$Revision$"

class
	CMS_API_FOR_CLI

inherit
	CMS_API
		rename
			make as make_api
		redefine
			execution_variable, set_execution_variable, unset_execution_variable,
			output_log, time_stamp,
			site_url_suggestion
		end

	SHARED_EXECUTION_ENVIRONMENT

create
	make

feature {NONE} -- Initialization

	make (a_setup: CMS_SETUP; a_site_url: STRING_8)
			-- Create the API service with a setup `a_setup'
			-- and request `req', response `resp`.
		do
			default_site_url_suggestion := a_site_url
			create execution_variables_table.make (0)
			time_stamp := -1 -- FIXME
			make_api (a_setup)
		end

feature {NONE} -- Access: request

	default_site_url_suggestion: STRING_8

	site_url_suggestion: STRING_8
			-- Site_url from environment (request or cli)
		do
			Result := default_site_url_suggestion
		end

	time_stamp: INTEGER_64
			-- Execution time stamp (UTC)	 (unix time stamp)	

feature -- Access: request

	self_link: CMS_LOCAL_LINK
		local
			s: READABLE_STRING_8
			loc: READABLE_STRING_8
		do
			s := "CLI/execution/"
			if not s.is_empty and then s[1] = '/' then
				loc := s.substring (2, s.count)
			else
				loc := s
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
				io.error.put_string (m)
			else
			end
		end

feature -- Request utilities

	execution_variables_table: STRING_TABLE [detachable ANY]

	execution_variable (a_name: READABLE_STRING_GENERAL): detachable ANY
			-- Execution variable related to `a_name'
		do
			Result := execution_variables_table.item (a_name)
		end

	set_execution_variable (a_name: READABLE_STRING_GENERAL; a_value: detachable ANY)
		do
			execution_variables_table.force (a_value, a_name)
		end

	unset_execution_variable (a_name: READABLE_STRING_GENERAL)
		do
			execution_variables_table.remove (a_name)
		end


invariant
--	invariant_clause: True

note
	copyright: "2011-2025, Jocelyn Fiat, Javier Velilla, Eiffel Software and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end
