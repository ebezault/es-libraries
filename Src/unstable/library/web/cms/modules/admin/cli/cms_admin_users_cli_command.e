note
	description: "Summary description for {CMS_ADMIN_USERS_CLI_COMMAND}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	CMS_ADMIN_USERS_CLI_COMMAND

inherit
	CMS_CLI_COMMAND

	CMS_CLI_COMMAND_UTILITY

	CMS_API_ACCESS

create
	make

feature {NONE} -- Initialization	

	make (a_api: CMS_API)
		do
			cms_api := a_api
		end

	cms_api: CMS_API

feature -- Access

	name: IMMUTABLE_STRING_32 = "users"

	short_name: CHARACTER_32 = 'u'

	description: IMMUTABLE_STRING_32 = "Manage users: list, info"

	help: detachable IMMUTABLE_STRING_32
		do
--			Result := "Run tests suite"
		end

feature -- Execution

	execute (sh: CMS_CLI_SHELL; n: READABLE_STRING_32; a_arguments_string: detachable READABLE_STRING_32)
		local
			op: READABLE_STRING_32
			l_args: READABLE_STRING_32
		do
			if
				attached pop_arguments (a_arguments_string) as tu and then
				attached tu.arg as a
			then
				op := a
				l_args := tu.args
			else
				op := "help"
			end
			if op.same_string ("list") then
				list_users (sh, n + op, l_args)
			elseif op.same_string ("info") then
				show_info (sh, n + op, l_args)
			elseif op.same_string ("help") then
				sh.put_warning ({STRING_32} "Usage: list, info.%N")
				sh.put_warning ({STRING_32} "  list   : list accounts%N")
				sh.put_warning ({STRING_32} "  info   : display information about one account%N")
			else
				sh.put_error_line ({STRING_32} "Unsupported operation %"" + op + "%".")
			end
		end

	list_users (sh: CMS_CLI_SHELL; n: READABLE_STRING_32; args: detachable READABLE_STRING_32)
		local
			params: CMS_DATA_QUERY_PARAMETERS
			nb: INTEGER
			o: INTEGER
			len: INTEGER
			q: BOOLEAN
		do
			if attached cms_api.user_api as l_user_api then
				nb := l_user_api.users_count
				output_h1 (sh, nb.out + " users:%N")
				from
					o := 0
					len := 5
					q := False
				until
					q or o > nb
				loop
					create params.make (o.to_natural_64, len.to_natural_32)
					if attached l_user_api.recent_users (params) as lst then
						sh.output.put_string ("# " + (1 + o).out + " to " + (o + len).min (nb).out + "%N")
						across
							lst as u
						loop
							o := o + 1
							if u.is_active then
								sh.ansi.set_foreground_color_to_blue
								sh.output.put_string ("[" + u.id.out + "] ")
								sh.ansi.reset_foreground_color
								sh.ansi.set_bold
								sh.output.put_string_32 (u.name)
								if attached u.profile_name as pn then
									sh.output.put_character (' ')
									sh.output.put_character ('"')
									sh.ansi.set_italic
									sh.output.put_string_32 (pn)
									sh.ansi.unset_italic
									sh.output.put_character ('"')
								end
								sh.ansi.unset_bold

								sh.output.put_string (":")
								if attached u.email as e then
									sh.output.put_character (' ')
									sh.output.put_string (e)
								end
								sh.output.put_character (' ')
								sh.output.put_character ('<')
								if attached u.last_login_date as dt then
									sh.output.put_string (cms_api.date_time_to_iso8601_string (dt))
								else
									sh.output.put_string ("never")
								end
								sh.output.put_character ('>')
								sh.output.put_new_line
							end
						end
						if o < nb then
							sh.output.put_string ("Press [ENTER] for more (q to stop)...%N")
							io.read_line
							if io.last_string.starts_with ("q") then
								q := True
							end
						else
							q := True
						end
					end
				end
			end
		end

	show_info (sh: CMS_CLI_SHELL; n: READABLE_STRING_32; args: detachable READABLE_STRING_32)
		do
		end

note
	copyright: "2011-2025, Jocelyn Fiat, Javier Velilla, Eiffel Software and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end
