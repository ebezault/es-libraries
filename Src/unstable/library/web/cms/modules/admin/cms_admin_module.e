note
	description: "CMS module providing Administration support (back-end)."
	date: "$Date$"
	revision: "$Revision$"

class
	CMS_ADMIN_MODULE

inherit
	CMS_MODULE
		redefine
			permissions,
			is_installed,
			installed_version
		end

	CMS_ADMINISTRABLE

create
	make

feature {NONE} -- Initialization

	make
			-- Create Current module, disabled by default.
		do
			version := "1.0"
			description := "Service to Administrate CMS (users, modules, etc)"
			package := "core"
			enable -- Is enabled by default
		end

feature -- Access

	name: STRING = "admin"

feature {CMS_EXECUTION} -- Administration

	administration: CMS_ADMIN_MODULE_ADMINISTRATION
		do
			create Result.make (Current)
		end

feature {CMS_API} -- Module management

	installed_version (api: CMS_API): detachable READABLE_STRING_8
		do
			Result := version
		end

	is_installed (api: CMS_API): BOOLEAN
		do
			Result := True
		end

feature -- Access: router

	setup_router (a_router: WSF_ROUTER; a_api: CMS_API)
			-- <Precursor>
		do
		end

feature -- Security

	permissions: LIST [READABLE_STRING_8]
			-- List of permission ids, used by this module, and declared.
		do
			Result := Precursor
			Result.force (perm_access_admin)
			Result.force (perm_clear_blocks_cache)
		end

	perm_access_admin: STRING_8 = "access admin"
	perm_clear_blocks_cache: STRING_8 = "clear blocks cache"

note
	copyright: "2011-2015, Jocelyn Fiat, Javier Velilla, Eiffel Software and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end
