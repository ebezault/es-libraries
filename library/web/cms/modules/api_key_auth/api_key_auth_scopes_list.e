note
	description: "Summary description for {API_KEY_AUTH_SCOPES_LIST}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	API_KEY_AUTH_SCOPES_LIST

inherit
	ITERABLE [READABLE_STRING_8]

create
	make

feature {NONE} -- Initialization

	make
		do
			create {ARRAYED_LIST [READABLE_STRING_8]} items.make (3)
		end

feature -- Access

	items: LIST [READABLE_STRING_8]

	new_cursor: ITERATION_CURSOR [READABLE_STRING_8]
		do
			Result := items.new_cursor
		end

feature -- Element change

	extend (a_scope: READABLE_STRING_8)
		do
			items.force (a_scope)
		end

end
