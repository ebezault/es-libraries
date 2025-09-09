note
	description: "Summary description for {JWT_AUTH_TOKEN_PARAMS}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	JWT_AUTH_MAGIC_LINK_PARAMS

feature -- Access

	location: detachable READABLE_STRING_8 assign set_location
			-- Redirection location once magic link is used.

	is_external: BOOLEAN assign set_is_external
			-- Redirection location is external

feature -- Element changes

	set_location (v: like location)
		do
			location := v
		end

	set_is_external (v: like is_external)
		do
			is_external := v
		end

end
