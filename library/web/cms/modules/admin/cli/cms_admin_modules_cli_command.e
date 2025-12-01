note
	description: "Summary description for {CMS_ADMIN_USERS_CLI_COMMAND}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	CMS_ADMIN_MODULES_CLI_COMMAND

inherit
	CMS_CLI_COMMAND

	CMS_CLI_COMMAND_UTILITY

	CMS_API_ACCESS

	CMS_SETUP_ACCESS

	CMS_ACCESS

create
	make

feature {NONE} -- Initialization	

	make (a_api: CMS_API)
		do
			cms_api := a_api
		end

	cms_api: CMS_API

feature -- Access

	name: IMMUTABLE_STRING_32 = "modules"

	short_name: CHARACTER_32 = 'm'

	description: IMMUTABLE_STRING_32 = "Manage modules: list, ..."

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
				list_modules (sh, n + op, l_args)
			elseif op.same_string ("update") or op.same_string ("up") then
				update_modules (sh, n + op, l_args)
			elseif op.same_string ("help") then
				sh.put_warning ({STRING_32} "Usage: list, update, ...%N")
				sh.put_warning ({STRING_32} "  list   : list modules%N")
			else
				sh.put_error_line ({STRING_32} "Unsupported operation %"" + op + "%".")
			end
		end

	list_modules (sh: CMS_CLI_SHELL; n: READABLE_STRING_32; args: detachable READABLE_STRING_32)
		local
			nb: INTEGER
			mod: CMS_MODULE
			n1, col1, n2, col2: INTEGER
			tn, sp: STRING_8
			mod_v, mod_inst_v, v: READABLE_STRING_8
			mod_up: BOOLEAN
		do
			nb := cms_api.setup.modules.count
			output_h1 (sh, nb.out + " modules:%N")

			across
				cms_api.setup.modules as m
			loop
				col1 := col1.max (m.name.count)
				col2 := col2.max (m.version.count + 1)
			end
			across
				cms_api.setup.modules as m
			loop
				mod := m
				n1 := mod.name.count
				sh.ansi.set_bold
				if mod.is_enabled then
					sh.ansi.set_foreground_color_to_green
				else
					sh.ansi.set_rgb_foreground_color (90, 90, 90)
				end
				sh.output.put_string (mod.name)
				sh.ansi.reset_foreground_color
				sh.ansi.unset_bold
				if n1 < col1 then
					create sp.make_filled (' ', col1 - n1)
					sh.output.put_string (sp)
				end

				sh.ansi.set_foreground_color_to_yellow
				mod_v := mod.version
				v := mod_v
				n2 := v.count
				mod_up := False
				if mod.is_enabled then
					mod_inst_v := cms_api.installed_module_version (mod)
					if mod_inst_v = Void then

					elseif not mod_v.same_string (mod_inst_v) then
						mod_up := True
						v := mod_inst_v
						n2 := v.count + 1
					end
				end
				sh.output.put_character (' ')
				sh.output.put_character ('[')
				if mod_up then
					sh.ansi.set_foreground_color_to_red
					sh.ansi.set_bold
					sh.output.put_string ("^")
				end
				if n2 < col2 then
					create sp.make_filled (' ', col2 - n2)
					sh.output.put_string (sp)
				end
				sh.output.put_string (v)
				if mod_up then
					sh.ansi.unset_bold
					sh.ansi.reset_foreground_color
					sh.ansi.set_foreground_color_to_yellow
				end
				sh.output.put_character (']')
				sh.ansi.reset_foreground_color

				sh.output.put_character (':')
				sh.output.put_character (' ')
				sh.ansi.set_italic
				sh.ansi.set_foreground_color_to_cyan
				sh.output.put_string (mod.description)
				sh.ansi.reset_foreground_color
				sh.ansi.unset_italic
				if attached mod.dependencies as deps then
					sh.output.put_string (" (depends-on:")
					across
						deps as dmod
					loop
						sh.output.put_character (' ')
						if dmod.is_required then
							sh.output.put_character ('*')
						end
						create tn.make_from_string (dmod.module_type.name.to_string_8)
						tn.prune_all ('?')
						tn.prune_all ('!')
						sh.output.put_string (tn)
					end
					sh.output.put_string (")")
				end
				sh.output.put_new_line
			end
		end

	update_modules (sh: CMS_CLI_SHELL; n: READABLE_STRING_32; args: detachable READABLE_STRING_32)
		local
			mod: CMS_MODULE
			n1, col1, n2: INTEGER
			l_modules_to_update: ARRAYED_LIST [CMS_MODULE]
			sp: STRING_8
			mod_v, mod_inst_v, v: READABLE_STRING_8
			mod_up: BOOLEAN
		do
			output_h1 (sh, "Update modules:%N")
			create l_modules_to_update.make (1)
			across
				cms_api.setup.modules as m
			loop
				mod := m

				mod_v := mod.version
				v := mod_v
				n2 := v.count
				mod_up := False
				if mod.is_enabled then
					mod_inst_v := cms_api.installed_module_version (mod)
					if mod_inst_v = Void then

					elseif not mod_v.same_string (mod_inst_v) then
						mod_up := True
						n2 := n2 + 1
					end
				end
				if mod_up then
					l_modules_to_update.force (m)
				end
			end
			if l_modules_to_update.count > 0 then
				across
					l_modules_to_update as m
				loop
					col1 := col1.max (m.name.count)
				end
				across
					l_modules_to_update as m
				loop
					mod := m
					n1 := mod.name.count
					sh.ansi.set_bold
					sh.ansi.set_foreground_color_to_green
					sh.output.put_string (mod.name)
					sh.ansi.reset_foreground_color
					sh.ansi.unset_bold
					if n1 < col1 then
						create sp.make_filled (' ', col1 - n1)
						sh.output.put_string (sp)
					end

					sh.ansi.set_foreground_color_to_yellow
					mod_inst_v := cms_api.installed_module_version (mod)

					if mod_inst_v /= Void then
						sh.output.put_string (" ")
						sh.output.put_string (mod_inst_v)
						sh.output.put_string (" -> ")
						sh.output.put_string (mod.version)
						sh.output.put_new_line
						if yes_no_question (sh, "Update to version " + mod.version + " ?", True, True, False) then
							cms_api.update_module (mod, mod_inst_v)
							if
								attached cms_api.installed_module_version (mod) as l_new_version and then
								l_new_version.same_string (mod.version)
							then
								sh.put_success (" updated")
							else
								sh.put_error (" failed")
							end
						end
					else
						sh.output.put_string (" ???")
					end
					sh.output.put_new_line
				end
			end
		end

note
	copyright: "2011-2025, Jocelyn Fiat, Javier Velilla, Eiffel Software and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end
