note
description: "{CMS_NONE_TEMPLATE_BLOCK} is basically using no template, returning the content untouched."
	date: "$Date$"

class
	CMS_NONE_TEMPLATE_BLOCK

inherit
	CMS_TEMPLATE_BLOCK

create
	make,
	make_raw

feature -- Conversion

	to_html (a_theme: detachable CMS_THEME): STRING_8
			-- <Precursor>
		local
			p: detachable PATH
			ut: FILE_UTILITIES
			f: PLAIN_TEXT_FILE
			txt: STRING_8
		do
			p := location
			if ut.file_path_exists (template_root_path.extended_path (p)) then
				create f.make_with_path (template_root_path.extended_path (p))
				create txt.make (f.count)
				f.open_read
				from
				until
					f.exhausted or f.end_of_file
				loop
					f.read_stream (1024)
					txt.append (f.last_string)
				end
				f.close
				Result := txt
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

