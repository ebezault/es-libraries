note
	description: "CMS module providing Administration support in CLI (back-end)."
	date: "$Date$"

class
	CMS_ADMIN_MODULE_FOR_CLI

inherit
	CMS_ADMIN_MODULE

	CMS_WITH_CLI

create
	make

feature {NONE} -- CLI API

	cli: CMS_ADMIN_CLI
		do
			create Result.make (Current)
		end

feature {NONE} -- Implementation

end

