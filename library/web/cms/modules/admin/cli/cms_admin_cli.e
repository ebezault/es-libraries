note
	description: "Summary description for {CMS_ADMIN_CLI}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	CMS_ADMIN_CLI

inherit
	CMS_MODULE_CLI [CMS_ADMIN_MODULE]
		redefine
			setup_hooks,
			permissions
		end

	CMS_HOOK_AUTO_REGISTER

	SHARED_EXECUTION_ENVIRONMENT

create
	make

feature -- Access		

	permissions: LIST [READABLE_STRING_8]
			-- List of permission ids, used by this module, and declared.
		do
			Result := Precursor
		end

feature -- Hooks configuration

	setup_hooks (a_hooks: CMS_HOOK_CORE_MANAGER)
			-- Module hooks configuration.
		do
			module.setup_hooks (a_hooks)
		end

feature -- Setup

	setup_shell (a_shell: CMS_CLI_SHELL; a_api: CMS_API)
		local
			cmd: CMS_CLI_AGENT_COMMAND
		do
			create cmd.make ("info", agent list_info (a_api, ?, ?, ?))
			cmd.set_short_name ('i')
			cmd.set_description ("Display CMS information")
			a_shell.register_command (cmd, Current)

			create cmd.make ("users-list", agent list_users (a_api, ?, ?, ?))
			cmd.set_short_name ('u')
			cmd.set_description ("List users")
			a_shell.register_command (cmd, Current)

			create cmd.make ("modules-list", agent list_modules (a_api, ?, ?, ?))
			cmd.set_short_name ('m')
			cmd.set_description ("List modules")
			a_shell.register_command (cmd, Current)

			create cmd.make ("cleanup", agent process_cleanup (a_api, ?, ?, ?))
			cmd.set_description ("Process CMS cleanup")
			a_shell.register_command (cmd, Current)
		end

feature -- Execution

	output_h1 (sh: CMS_CLI_SHELL; s: READABLE_STRING_GENERAL)
		do
			sh.ansi.set_foreground_color_to_cyan
			sh.ansi.set_bold

			sh.output.put_string_general (s)

			sh.ansi.unset_bold
			sh.ansi.reset_foreground_color
		end

	output_h2 (sh: CMS_CLI_SHELL; s: READABLE_STRING_GENERAL)
		do
--			sh.ansi.set_foreground_color_to_cyan
			sh.ansi.set_bold

			sh.output.put_string_general (s)

			sh.ansi.unset_bold
--			sh.ansi.reset_foreground_color
		end

	output_key (sh: CMS_CLI_SHELL; s: READABLE_STRING_GENERAL)
		do
			sh.ansi.set_foreground_color_to_yellow
			sh.ansi.set_bold
			sh.output.put_string_general (s)
			sh.ansi.unset_bold
			sh.ansi.reset_foreground_color
		end

	output_help (sh: CMS_CLI_SHELL; s: READABLE_STRING_GENERAL)
		do
			sh.ansi.set_foreground_color_to_default
			sh.ansi.set_italic
			sh.output.put_string_general (s)
			sh.ansi.unset_italic
			sh.ansi.reset_foreground_color
		end

	list_info (api: CMS_API; sh: CMS_CLI_SHELL; n:  READABLE_STRING_32; args: detachable READABLE_STRING_32)
		local
			n1, col1, n2, col2: INTEGER
			k: READABLE_STRING_GENERAL
			sp: STRING_8
			l_mailer: NOTIFICATION_MAILER
		do
			output_h1 (sh, "System information:%N")

			across
				api.setup.system_info as v
			loop
				k := @v.key
				col1 := col1.max (k.count)
				col2 := col2.max (v.count)
			end
			across
				api.setup.system_info as v
			loop
				k := @v.key
				n1 := k.count
				n2 := v.count
				sh.output.put_string (" ")
				output_key (sh, k)
--				sh.ansi.set_foreground_color_to_yellow
				if n1 < col1 then
					create sp.make_filled (' ', col1 - n1)
					sh.output.put_string (sp)
				end
				sh.output.put_character (':')
				sh.output.put_character (' ')
--				if n2 < col2 then
--					create sp.make_filled (' ', col2 - n2)
--					sh.output.put_string (sp)
--				end
				sh.output.put_string (v)
--				sh.ansi.reset_foreground_color
				sh.output.put_new_line
			end

			output_h1 (sh, "Storage:%N")
			sh.output.put_string ("  ")
			sh.output.put_string (api.storage.description)
			sh.output.put_new_line

			output_h1 (sh, "Mailer:%N")
			l_mailer := api.setup.mailer
			from until l_mailer = Void loop
				sh.output.put_string (" -> ")
--				sh.output.put_string (l_mailer.generator)
				if attached {NOTIFICATION_CHAIN_MAILER} l_mailer as l_chain_mailer then
					if attached l_chain_mailer.active as l_active then
						output_key (sh, l_active.generator)
					end
					l_mailer := l_chain_mailer.next
				else
					output_key (sh, l_mailer.generator)
					l_mailer := Void
				end
			end
			sh.output.put_new_line
			if args /= Void and then args.same_string ("all") then
				output_h1 (sh, "Environment:%N")
				output_h2 (sh, "- from setup:%N")
				if attached api.setup.environment_items as l_site_envs then
					across
						l_site_envs as env
					loop
						sh.output.put_string ("  ")
						output_key (sh, @env.key)
						sh.output.put_character (':')
						sh.output.put_character (' ')
						if attached env as v then
							sh.output.put_string_32 (v)
						end
						sh.output.put_new_line
					end
				end
				output_h2 (sh, "- from process:%N")
				if attached execution_environment.starting_environment as l_proc_envs then
					across
						l_proc_envs as env
					loop
						sh.output.put_string ("  ")
						output_key (sh, @env.key)
						sh.output.put_character (':')
						sh.output.put_character (' ')
						sh.output.put_string_32 (env)
						sh.output.put_new_line
					end
				end
			else
				output_help (sh, "%NUse %""+ n +" all%" to display all available informations...%N")
			end
		end

	list_users (api: CMS_API; sh: CMS_CLI_SHELL; n:  READABLE_STRING_32; args: detachable READABLE_STRING_32)
		local
			params: CMS_DATA_QUERY_PARAMETERS
			nb: INTEGER
			o: INTEGER
			len: INTEGER
			q: BOOLEAN
		do
			if attached api.user_api as l_user_api then
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
					if attached api.user_api.recent_users (params) as lst then
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
									sh.output.put_string (api.date_time_to_iso8601_string (dt))

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

	list_modules (api: CMS_API; sh: CMS_CLI_SHELL; n:  READABLE_STRING_32; args: detachable READABLE_STRING_32)
		local
			nb: INTEGER
			mod: CMS_MODULE
			n1, col1, n2, col2: INTEGER
			tn, sp: STRING_8
		do
			nb := api.setup.modules.count
			output_h1 (sh, nb.out + " modules:%N")

			across
				api.setup.modules as m
			loop
				col1 := col1.max (m.name.count)
				col2 := col2.max (m.version.count)
			end
			across
				api.setup.modules as m
			loop
				mod := m
				n1 := mod.name.count
				n2 := mod.version.count
				sh.ansi.set_bold
				if mod.is_enabled then
					sh.ansi.set_foreground_color_to_green
				else
					sh.ansi.set_rgb_foreground_color (90, 90, 90)
				end
				sh.output.put_string (mod.name)
				sh.ansi.reset_foreground_color
				sh.ansi.unset_bold
				sh.ansi.set_foreground_color_to_yellow
				if n1 < col1 then
					create sp.make_filled (' ', col1 - n1)
					sh.output.put_string (sp)
				end
				sh.output.put_character (' ')
				sh.output.put_character ('[')
				if n2 < col2 then
					create sp.make_filled (' ', col2 - n2)
					sh.output.put_string (sp)
				end

				sh.output.put_string (mod.version)

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
						tn := dmod.module_type.name.twin
						tn.prune_all ('?')
						tn.prune_all ('!')
						sh.output.put_string (tn)
					end
					sh.output.put_string (")")
				end
				sh.output.put_new_line
			end
		end

	process_cleanup (api: CMS_API; sh: CMS_CLI_SHELL; n:  READABLE_STRING_32; args: detachable READABLE_STRING_32)
		local
			ctx: CMS_HOOK_CLEANUP_CONTEXT
		do
			sh.output.put_string ("Invoke clean.%N")
			create ctx.make (Void)
			api.hooks.invoke_cleanup (ctx, Void)
			across
				ctx.logs as log
			loop
				sh.output.put_string (log)
				sh.output.put_new_line
			end
		end

note
	copyright: "2011-2025, Jocelyn Fiat, Javier Velilla, Eiffel Software and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end
