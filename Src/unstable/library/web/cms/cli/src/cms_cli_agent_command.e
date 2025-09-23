note
	description: "[
			Objects that ...
		]"
	date: "$Date$"

class
	CMS_CLI_AGENT_COMMAND

inherit
	CMS_CLI_COMMAND

create
	make

feature {NONE} -- Initialization

	make (a_name: READABLE_STRING_GENERAL; act: like action)
			-- Initialize `Current'.
		do
			name := a_name
			action := act
		end

feature -- Access

	action: PROCEDURE [CMS_CLI_SHELL, READABLE_STRING_GENERAL, detachable READABLE_STRING_GENERAL]

	name: IMMUTABLE_STRING_32

	short_name: CHARACTER_32

	description: detachable IMMUTABLE_STRING_32

	help: detachable IMMUTABLE_STRING_32

feature -- Change

	set_short_name (v: CHARACTER_32)
		do
			short_name := v
		end

	set_description (v: detachable READABLE_STRING_GENERAL)
		do
			if v = Void then
				description := Void
			else
				description := v
			end
		end

	set_help (v: detachable READABLE_STRING_GENERAL)
		do
			if v = Void then
				help := Void
			else
				help := v
			end
		end

feature -- Execution

	execute (sh: CMS_CLI_SHELL; a_command_name: READABLE_STRING_32; a_arguments_string: detachable READABLE_STRING_32)
		do
			action (sh, a_command_name, a_arguments_string)
		end

feature {NONE} -- Implementation

invariant
--	invariant_clause: True

note
	copyright: "2011-2025, Jocelyn Fiat, Javier Velilla, Eiffel Software and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end
