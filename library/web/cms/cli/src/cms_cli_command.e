note
	description: "Summary description for {CMS_CLI_COMMAND}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	CMS_CLI_COMMAND

feature -- Access

	name: IMMUTABLE_STRING_32
		deferred
		end

	short_name: CHARACTER_32
		deferred
		end

	description: detachable IMMUTABLE_STRING_32
		deferred
		end

	help: detachable IMMUTABLE_STRING_32
		deferred
		end

feature -- Status

	has_short_name: BOOLEAN
		do
			Result := short_name /= '%U'
		end

feature -- Execution

	execute (sh: CMS_CLI_SHELL; a_command_name: READABLE_STRING_32; a_arguments_string: detachable READABLE_STRING_32)
		deferred
		end

note
	copyright: "2011-2025, Jocelyn Fiat, Javier Velilla, Eiffel Software and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end
