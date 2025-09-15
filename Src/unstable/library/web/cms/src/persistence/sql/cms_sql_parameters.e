note
	description: "Summary description for {CMS_SQL_PARAMETERS}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	CMS_SQL_PARAMETERS

inherit
	STRING_TABLE [detachable ANY]
		redefine
			put
		end

create
	make,
	make_caseless

feature -- Element change

	put (new: detachable ANY; key: READABLE_STRING_GENERAL)
		do
			check
				valid_value:
					new = Void
					or else attached {DATE_TIME} new
					or else attached {READABLE_STRING_GENERAL} new
					or else attached {NUMERIC} new
					or else attached {BOOLEAN} new
					or else attached {MANAGED_POINTER} new
			end
			Precursor (new, key)
		end

note
	copyright: "2011-2025, Jocelyn Fiat, Javier Velilla, Eiffel Software and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end
