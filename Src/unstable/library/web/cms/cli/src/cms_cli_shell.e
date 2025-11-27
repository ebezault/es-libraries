note
	description: "Summary description for {CMS_CLI_SHELL}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	CMS_CLI_SHELL

create
	make

feature {NONE} -- Initialization

	make
		do
			create commands.make_caseless (10)
			create aliases.make_caseless (10)
			create short_aliases.make (5)
			output := io.output
			error := io.error
			set_default_to_output
		end

feature -- Change

	register_command (cmd: CMS_CLI_COMMAND; mod_cli: detachable CMS_MODULE_CLI [CMS_MODULE])
		local
			k: STRING_32
			c: CHARACTER_32
		do
			if mod_cli /= Void then
				k := mod_cli.module.name + "::" + cmd.name
				commands [k] := cmd
			end

			if aliases.has_key (cmd.name) then
				put_warning_line ({STRING_32} "Command name conflict for %""+ cmd.name +"%"!")
				if k /= Void then
					put_warning_line ({STRING_32} " Use %""+ k +"%"!")
					aliases [k] := cmd
				end
			else
				aliases [cmd.name] := cmd
			end
			if cmd.has_short_name then
				c := cmd.short_name
				if short_aliases.has_key (c) then
					put_warning_line ({STRING_32} "alias name conflict for %""+ create {STRING_32}.make_filled (c, 1) +"%" -> ignore!")
				else
					short_aliases [c] := cmd
				end
			end
		end

feature -- Access

	commands: STRING_TABLE [CMS_CLI_COMMAND]

	aliases: STRING_TABLE [CMS_CLI_COMMAND]

	short_aliases: HASH_TABLE [CMS_CLI_COMMAND, CHARACTER_32]

feature -- Control

	ansi: CMS_CLI_SHELL_ANSI_CONTROL
		once
			create Result
		end

feature -- Query

	command (n: READABLE_STRING_GENERAL): detachable CMS_CLI_COMMAND
		do
			if n.count = 1 then
				Result := short_aliases [n [1]]
			end
			if Result = Void then
				Result := aliases [n]
				if Result = Void then
					Result := commands [n]
				end
			end
		end

feature -- Execution

	execute
		local
			s: STRING_32
			cmd: CMS_CLI_AGENT_COMMAND
		do
			pre_execute
			create cmd.make ("help", agent execute_help)
			cmd.set_description ("Display this help")
			cmd.set_short_name ('h')
			register_command (cmd, Void)

			create cmd.make ("quit", agent execute_quit)
			cmd.set_description ("Quit the shell instance")
			cmd.set_short_name ('q')
			register_command (cmd, Void)

			from
				exit_requested := False
			until
				exit_requested
			loop
				ansi.set_bold
				output.put_string ("> ")
				ansi.unset_bold
				io.input.read_unicode_line
				s := io.input.last_string_32
				if s.starts_with ("> ") then
					s.remove_head (2)
				end
				execute_line (s)
			end
			post_execute
		end

	pre_execute
		do
			ansi.set_background_color_to_black
			ansi.erase_display --_until_cursor
		end

	post_execute
		do
			ansi.reset_background_color
		end

	pre_execute_command
		do
--			ansi.set_background_color_to_black
			ansi.erase_display_from_cursor
		end

	post_execute_command
		do
			ansi.reset_attributes
			ansi.set_background_color_to_black
		end

	exit_requested: BOOLEAN

	exit (n: INTEGER)
		do
			exit_requested := True
		end

	execute_line (a_line: READABLE_STRING_32)
		local
			n, args: READABLE_STRING_32
		do
			if attached next_token (a_line) as tok then
				n := tok.token
				args := tok.args


				if n.is_whitespace then
					-- .... ignore
				else
					if attached command (n) as cmd then
						execute_command (cmd, n, args)
					else
						put_error_line ({STRING_32} "command not found %"" + n + "%"!")
					end
				end
			else
				check a_line.is_whitespace end
			end
		end

	next_token (s: detachable READABLE_STRING_32): detachable TUPLE [token: READABLE_STRING_32; args: detachable READABLE_STRING_32; end_index: INTEGER]
		local
			i,j: INTEGER
			n, args: READABLE_STRING_32
		do
			if s /= Void then
				from
					i := 1
					j := 0
				until
					i > s.count or s [i].is_space
				loop
					if s [i].is_space then
						if j = 0 then
							-- ignore first spaces
						end
					elseif j = 0 then
						j := i
					end
					i := i + 1
				end
				if j > 0 then
					n := s.substring (j, i - 1)
					args := s.substring (i + 1, s.count)
					Result := [n, args, i - 1]
				else
					Result := Void
				end
			end
		end


	execute_help (sh: CMS_CLI_SHELL; n:  READABLE_STRING_32; args: detachable READABLE_STRING_32)
		local
			tok: like next_token
			o: PLAIN_TEXT_FILE
		do
			o := sh.output
			tok := next_token (args)
			if tok /= Void then
				if attached command (tok.token) as c then
					sh.ansi.set_bold
					sh.ansi.set_foreground_color_to_yellow
					o.put_string_32 (c.name)
					if c.has_short_name then
						o.put_character ('|')
						o.put_string_32 (create {STRING_32}.make_filled (c.short_name, 1))
					end
					sh.ansi.reset_foreground_color
					sh.ansi.unset_bold
					if attached c.description as desc then
						o.put_character (':')
						o.put_character (' ')
						o.put_string_32 (desc)
					end
					o.put_character ('%N')
					if attached c.help as h then
						o.put_character ('%T')
						o.put_string_32 (h)
						o.put_character ('%N')
					end
				else
					sh.put_error_line ({STRING_32} "command not found %"" + tok.token + "%"!")
				end
			else
				across
					aliases as cmd
				loop
					o.put_character (' ')
					sh.ansi.set_bold
					sh.ansi.set_foreground_color_to_yellow
					o.put_string_32 (cmd.name)
					if cmd.has_short_name then
						o.put_character ('|')
						o.put_string_32 (create {STRING_32}.make_filled (cmd.short_name, 1))
					end
					sh.ansi.reset_foreground_color
					sh.ansi.unset_bold
					if attached cmd.description as desc then
						o.put_character (':')
						o.put_character (' ')
						o.put_string_32 (desc)
					end
					o.put_character ('%N')
				end
				o.put_character ('%N')
			end
		end

	execute_quit (sh: CMS_CLI_SHELL; n:  READABLE_STRING_32; args: detachable READABLE_STRING_32)
		do
			exit (0)
		end

	execute_command (cmd: CMS_CLI_COMMAND; n: READABLE_STRING_32; args: detachable READABLE_STRING_32)
		do
			pre_execute_command
			cmd.execute (Current, n, args)
			post_execute_command
		end

feature -- Streams

	default_output: PLAIN_TEXT_FILE

	output: PLAIN_TEXT_FILE

	error: PLAIN_TEXT_FILE

feature -- Streams change

	set_default_to_output
		do
			default_output := output
		end

	set_default_to_error
		do
			default_output := error
		end

feature -- Output helpers

	put_string (m: READABLE_STRING_GENERAL)
		do
			default_output.put_string_general (m)
		end

	put_bold (m: READABLE_STRING_GENERAL)
		do
			ansi.set_bold
			default_output.put_string_general (m)
			ansi.unset_bold
		end

	put_italic (m: READABLE_STRING_GENERAL)
		do
			ansi.set_italic
			default_output.put_string_general (m)
			ansi.unset_italic
		end

	put_success (m: READABLE_STRING_GENERAL)
		do
			ansi.set_foreground_color_to_green
			default_output.put_string_general (m)
			ansi.reset_foreground_color
		end

	put_error (m: READABLE_STRING_GENERAL)
		do
			ansi.set_foreground_color_to_red
			default_output.put_string_general (m)
			ansi.reset_foreground_color
		end

	put_warning (m: READABLE_STRING_GENERAL)
		do
			ansi.set_foreground_color_to_red
			default_output.put_string_general (m)
			ansi.reset_foreground_color
			put_new_line
		end

	put_error_line (m: READABLE_STRING_GENERAL)
		do
			ansi.set_bold
			if m.starts_with ("%N") then
				put_error ("%N[ERROR] ")
			else
				put_error ("[ERROR] ")
			end
			ansi.unset_bold
			if m.starts_with ("%N") then
				put_error (m.substring (2, m.count))
			else
				put_error (m)
			end
			put_new_line
		end

	put_warning_line (m: READABLE_STRING_GENERAL)
		do
			if m.starts_with ("%N") then
				put_warning ({STRING_32} "%N[WARNING] " + m.substring (2, m.count))
			else
				put_warning ({STRING_32} "[WARNING] " + m)
			end
			put_new_line
		end

	put_new_line
		do
			default_output.put_new_line
		end

invariant

note
	copyright: "2011-2025, Jocelyn Fiat, Javier Velilla, Eiffel Software and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end
