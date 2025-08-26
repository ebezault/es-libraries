note
	description: "Summary description for {CMS_VERSION}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	CMS_VERSION

feature -- Access

	major: IMMUTABLE_STRING_8 = "2"
	minor: IMMUTABLE_STRING_8 = "0"
	patch: IMMUTABLE_STRING_8 = "1"
	label: IMMUTABLE_STRING_8 = ""

	version: STRING_8
		do
			create Result.make (6)
			Result.append (major)
			Result.append_character ('.')
			Result.append (minor)
			Result.append_character ('.')
			Result.append (patch)
			if attached label as lab and then not lab.is_empty then
				Result.append_character ('.')
				Result.append (lab)
			end
		ensure
			class
		end

note
	copyright: "2011-2025, Jocelyn Fiat, Javier Velilla, Eiffel Software and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end
