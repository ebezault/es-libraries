note
	description: "[
				This class implements the CMS cli service
			]"

deferred class
	CMS_CLI_EXECUTION

inherit
	REFACTORING_HELPER

	CMS_SETUP_ACCESS

--	SHARED_LOGGER

--create
--	make

feature {NONE} -- Initialization

	make (a_site_url: STRING_8)
		do
			default_site_url := a_site_url
			initialize
			execute
		end

	default_site_url: STRING_8

	initialize
			-- Build a CMS service with `a_api'
		local
			l_setup: CMS_SETUP
		do
			l_setup := initial_cms_setup
			setup_storage (l_setup)
			setup_modules (l_setup)
			create {CMS_API_FOR_CLI} api.make (l_setup, default_site_url)
			if api.has_error then
				io.error.put_string ("ROC: Error during API initialization!")
				io.error.put_string (api.utf_8_encoded (api.string_representation_of_errors))
			elseif attached api.storage.error_handler.as_single_error as err then
				io.error.put_string ("ROC: Error during Storage initialization!")
				io.error.put_string (api.utf_8_encoded (err.string_representation))
				debug
					if attached api.setup.storage_configuration as l_storage_config then
						io.error.put_string ("ROC: storage -> " + api.utf_8_encoded (l_storage_config.connection_string))
					end
				end
			end
			modules := api.enabled_modules

			initialize_cms
--			Precursor
		end

	initialize_cms
		do
			create shell.make
		end

	initialize_modules
			-- Intialize modules and keep only enabled modules.
		do
			modules := api.enabled_modules
		ensure
			only_enabled_modules: across modules as mod all mod.is_enabled end
		end

feature -- Factory

	initial_cms_setup: CMS_SETUP
			-- Default setup object that Current interface can customize.
		deferred
		end

feature -- Access

	api: CMS_API
			-- API service.

	setup: CMS_SETUP
			-- CMS Setup.
		do
			Result := api.setup
		end

	modules: CMS_MODULE_COLLECTION
			-- Declared modules.

	shell: CMS_CLI_SHELL

feature -- CMS setup

	setup_modules (a_setup: CMS_SETUP)
			-- Setup additional modules.
		deferred
		end

	setup_storage (a_setup: CMS_SETUP)
		deferred
		end

	setup_shell
		local
			l_api: like api
			sh: like shell
		do
			l_api := api
			sh := shell
			across
				modules as mod
			loop
				if
					mod.is_initialized and then
					attached {CMS_WITH_CLI} mod as l_mod_shell
				then
					l_mod_shell.module_cli.setup_shell (sh, l_api)
				end
			end
		end

feature -- Request execution

	initialize_execution
			-- Initialize CMS execution.
		do
			initialize_cli_execution
		end

	initialize_cli_execution
			-- Initialize for site execution.
		do
			api.switch_to_cli_mode
			api.initialize_execution
			setup_shell
		end

	execute
			-- <Precursor>.
		do
			initialize_execution
			cli_execute
				-- Clean execution...
			if
				attached api.storage as l_storage and then
				not l_storage.is_reuseable
			then
				l_storage.close
			end
		end

	cli_execute
		do
			shell_execute
		end

	shell_execute
		do
			shell.execute
		end

note
	copyright: "2011-2025, Jocelyn Fiat, Javier Velilla, Eiffel Software and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
	source: "[
			Eiffel Software
			5949 Hollister Ave., Goleta, CA 93117 USA
			Telephone 805-685-1006, Fax 805-685-6869
			Website http://www.eiffel.com
			Customer support http://support.eiffel.com
		]"
end
