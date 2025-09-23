note
	description: "[
			Objects that ...
		]"
	author: "$Author$"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	CMS_MODULE_CLI [G -> CMS_MODULE]

inherit
	CMS_ACCESS

feature {NONE} -- Initialization

	make (a_module: G)
			-- Initialize `Current'.
		do
			module := a_module
		end

feature -- Access

	module: G

	name: STRING
		do
			Result := module.name
		end

	description: STRING
			-- Description of the module.
		do
			Result := module.description
		end

	package: STRING
			-- Associated package.
			-- Mostly to group modules by package/category.
		do
			Result := module.package
		end

	version: STRING
			-- Version of the module?		
		do
			Result := module.version
		end

	permissions: LIST [READABLE_STRING_8]
			-- List of permission ids, used by this module, and declared.
		require
			is_initialized: is_initialized
		do
			create {ARRAYED_LIST [READABLE_STRING_8]} Result.make (0)
		end

feature {CMS_API, CMS_MODULE_ADMINISTRATION, CMS_WITH_CLI} -- Access: API

	module_api: detachable CMS_MODULE_API
			-- Eventual module api.
		do
			Result := module.module_api
		end

feature -- Hooks configuration

	setup_hooks (a_hooks: CMS_HOOK_CORE_MANAGER)
			-- Module hooks configuration.
		require
			is_enabled: is_enabled
		do
		end

feature -- Setup

	setup_shell (a_shell: CMS_CLI_SHELL; a_api: CMS_API)
		require
			is_initialized: is_initialized
		deferred
		end

feature -- Status		

	frozen is_initialized: BOOLEAN
			-- Is Current module initialized?		
		do
			Result := module.is_initialized
		end

	frozen is_enabled: BOOLEAN
			-- Is Current module enabled?
		do
			Result := module.is_enabled
		end

note
	copyright: "2011-2025, Jocelyn Fiat, Javier Velilla, Eiffel Software and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end
