note
	description: "[
			CMS block with smarty template file content.
		]"
	date: "$Date$"
	revision: "$Revision$"

class
	CMS_SMARTY_TEMPLATE_BLOCK

inherit
	CMS_TEMPLATE_BLOCK

	SHARED_TEMPLATE_CONTEXT
		undefine
			is_equal, out
		end

create
	make,
	make_raw

feature -- Conversion

	to_html (a_theme: detachable CMS_THEME): STRING_8
			-- <Precursor>
		local
			p: detachable PATH
			tpl: detachable TEMPLATE_FILE
			ut: FILE_UTILITIES
			n: STRING_32
			l_table_inspector: detachable STRING_TABLE_OF_STRING_INSPECTOR
		do
				-- Process html generation
			p := location
			if ut.file_path_exists (template_root_path.extended_path (p)) then
				n := p.name
				template_context.set_template_folder (template_root_path)
				template_context.disable_verbose
				debug ("cms")
					template_context.enable_verbose
				end

				create tpl.make_from_file (n)

				across
					values as v
				loop
					tpl.add_value (v, @v.key)
				end


				create l_table_inspector.register (({detachable STRING_TABLE [STRING_8]}).name)
				create l_table_inspector.register (({detachable STRING_TABLE [STRING_32]}).name)
				create l_table_inspector.register (({detachable STRING_TABLE [READABLE_STRING_8]}).name)
				create l_table_inspector.register (({detachable STRING_TABLE [READABLE_STRING_32]}).name)
				tpl.analyze
				tpl.get_output
				l_table_inspector.unregister
--				l_table32_inspector.unregister

				if attached tpl.output as l_output then
					Result := l_output
				else
					Result := ""
					debug ("cms")
						Result := "Template block #" + name
					end
				end
			else
				Result := ""
				debug ("cms")
					Result := "Template block #" + name
				end
			end
		end

note
	copyright: "2011-2025, Jocelyn Fiat, Javier Velilla, Eiffel Software and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end
