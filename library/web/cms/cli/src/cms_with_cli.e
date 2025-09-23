note
	description: "Interface providing command line api for the module."
	author: "$Author$"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	CMS_WITH_CLI

feature -- Status

	is_initialized: BOOLEAN
		deferred
		end

feature -- CLI

	module_cli: like cli
			-- Associated CLI api module.
		do
			Result := internal_module_cli
			if Result = Void then
				Result := cli
				internal_module_cli := Result
			end
		end

feature {NONE} -- Implementation

	internal_module_cli: detachable like module_cli
			-- Cached version of `module_cli_api`.

feature {NONE} -- CLI API

	cli: CMS_MODULE_CLI [CMS_MODULE]
			-- CLI for module.
		deferred
		end

feature {NONE} -- Implementation

note
	copyright: "2011-2025, Jocelyn Fiat, Javier Velilla, Eiffel Software and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end
