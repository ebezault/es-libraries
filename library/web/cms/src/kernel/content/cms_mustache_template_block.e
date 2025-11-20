note
	description: "Summary description for {CMS_MUSTACHE_TEMPLATE_BLOCK}."
	date: "$Date$"

class
	CMS_MUSTACHE_TEMPLATE_BLOCK

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
			n: STRING_8
			f: PLAIN_TEXT_FILE
			txt: STRING_8
			i,j,k, nb: INTEGER
			utf: UTF_CONVERTER
		do
				-- Process html generation
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
				from
					i := 1
					nb := txt.count
					create utf
					create Result.make (nb)
				until
					i > nb
				loop
					j := txt.substring_index ("{{", i)
					if j > 0 then
						Result.append (txt.substring (i, j - 1))
						k := txt.substring_index ("}}", j + 2)
						if k > 0 then
							n := txt.substring (j + 2, k - 1)
							n.adjust
							if attached values [n] as v then
								if attached {READABLE_STRING_GENERAL} v as s then
									n := utf.utf_32_string_to_utf_8_string_8 (s)
								else
									-- FIXME
									n := v.out
								end
								Result.append (n)
							else
								Result.append (txt.substring (j, k + 2))
							end
							i := k + 2
						else
							i := nb + 1
						end
					else
						Result.append (txt.substring (i, nb))
						i := nb + 1
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

