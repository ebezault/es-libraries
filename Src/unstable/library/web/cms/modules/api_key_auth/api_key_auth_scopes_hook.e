note
	description: "[
			CMS HOOK providing a way to handle API Key scopes collection.
		]"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	API_KEY_AUTH_SCOPES_HOOK

inherit
	CMS_HOOK

feature -- Hook	

	declare_scopes (a_scopes: API_KEY_AUTH_SCOPES_LIST)
			-- Declare scopes via `a_scopes`.
		deferred
		end

note
	copyright: "2011-2017, Jocelyn Fiat, Javier Velilla, Eiffel Software and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end



