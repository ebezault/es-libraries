note
	description: "Summary description for {HTML_SOURCE_CONTENT_FORMAT}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	HTML_SOURCE_CONTENT_FORMAT

inherit
	CONTENT_FORMAT
		redefine
			default_create
		end

feature {NONE} -- Initialization

	default_create
		do
			Precursor
			create filters.make (2)
			filters.force (create {HTML_TO_TEXT_CONTENT_FILTER})
 			filters.force (create {URL_CONTENT_FILTER})
		end

feature -- Access

	name: STRING = "email_source_to_escaped_html"

	title: STRING_8 = "Filtered Email source to escaped HTML content and clickable links"

	filters: ARRAYED_LIST [CONTENT_FILTER]

end


