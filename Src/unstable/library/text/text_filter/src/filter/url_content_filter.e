note
	description: "Summary description for {URL_CONTENT_FILTER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	URL_CONTENT_FILTER

inherit
	CONTENT_FILTER
		redefine
			help
		end

	STRING_HANDLER

feature -- Access

	name: STRING_8 = "url"

	title: STRING_8 = "URL filter"

	description: STRING_8 = "Turns web and e-mail addresses into clickable links."

	help: STRING = "Web page addresses and e-mail addresses turn into links automatically."

feature -- Conversion

	filter (a_text: STRING_GENERAL)
			-- Convert all URLs in `a_text` to HTML links.
			-- A URL is considered to start with "http://" or "https://".
		local
			i, j, k, start_pos, end_pos: INTEGER
			url_found: BOOLEAN
			url_prefix_http: STRING_GENERAL
			url_prefix_https: STRING_GENERAL
			local_url_string: STRING_GENERAL
			s: READABLE_STRING_GENERAL
			lnk: STRING_GENERAL
		do
			from
				i := 1
				url_prefix_http := "http://"
				url_prefix_https := "https://"
			until
				i > a_text.count
			loop
				url_found := False
				start_pos := a_text.substring_index (url_prefix_https, i)
				if start_pos = 0 then
					start_pos := a_text.substring_index (url_prefix_http, i)
					if start_pos > 0 then
						url_found := True
					end
				else
					url_found := True
				end

				if url_found then
					-- Find the end of the URL
					j := a_text.substring_index ("//", start_pos) + 2
					if j > 0 then
						end_pos := 0
						from
						until
							end_pos > 0 or else j >= a_text.count
						loop
							if j = a_text.count then
								end_pos := j
							elseif a_text [j].is_space then
								end_pos := j
							else
								inspect
									a_text [j]
								when '>', '<', '"', '%'' then
									end_pos := j
								when '&' then
									k := a_text.index_of (';', j + 1)
									if k > 0 then
										s := a_text.substring (j + 1 , k - 1)
										if
											s.same_string ("lt")
											or s.same_string ("gt")
											or s.same_string ("quot")
										then
											end_pos := j
										else
											j := k
										end
									end
								else
								end
							end
							j := j + 1
						end
						check has_end_pos: end_pos > 0 end
					end

					-- Extract the URL
					local_url_string := a_text.substring (start_pos, end_pos - 1)

					-- prepare the HTML link
					lnk := local_url_string.twin

					lnk.prepend ("<a href=%"")
					lnk.append ("%">")
					lnk.append (local_url_string)
					lnk.append ("</a>")

					if attached {STRING_32} a_text as s32 then
						s32.replace_substring (lnk, start_pos, end_pos - 1)
						i := end_pos + lnk.count - local_url_string.count
					elseif attached {STRING_8} a_text as s8 then
						s8.replace_substring (lnk.to_string_8, start_pos, end_pos - 1)
						i := end_pos + lnk.count - local_url_string.count
					else
						check expected_case: False end
						i := end_pos
					end
				else
					-- No more URLs found, append the rest of the string and exit the loop
					i := a_text.count + 1
				end
			end
		end

end

