note
	description: "[
			Status code constants pertaining to the HTTP protocol
			See http://en.wikipedia.org/wiki/List_of_HTTP_status_codes
		]"
	legal: "See notice at end of class."
	status: "See notice at end of class."
	date: "$Date$"
	revision: "$Revision$"

class
	HTTP_STATUS_CODE

feature -- 1xx : Informational

	continue: INTEGER 				= 100
	switching_protocols: INTEGER 	= 101
	processing: INTEGER 			= 102 	-- WebDAV RFC 2518
	ie7_request_uri_too_long: INTEGER 	= 122 	-- non standard, IE7 only

feature -- 2xx : Success

	ok: INTEGER						= 200
	created: INTEGER 				= 201
	accepted: INTEGER 				= 202
	nonauthoritative_info: INTEGER 	= 203
	no_content: INTEGER 			= 204
	reset_content: INTEGER 			= 205
	partial_content: INTEGER 		= 206
	multistatus: INTEGER 			= 207	-- WebDAV RFC 4918
	im_used: INTEGER 				= 226	-- RFC 4918

	is_success_status (c: INTEGER): BOOLEAN
			-- Is `c' a success status code?
		do
			inspect c
			when
				ok, created, accepted,
				nonauthoritative_info,
				no_content, reset_content, partial_content,
				multistatus, im_used
			then
				Result := True
			else
				Result := False
			end
		ensure
			instance_free: class
		end

feature -- 3xx : Redirection

	multiple_choices: INTEGER		= 300
	moved_permanently: INTEGER 		= 301
	found: INTEGER 					= 302
	see_other: INTEGER 				= 303
	not_modified: INTEGER 			= 304
	use_proxy: INTEGER 				= 305
	switch_proxy: INTEGER 			= 306
	temp_redirect: INTEGER 			= 307

	is_redirection_status (c: INTEGER): BOOLEAN
			-- Is `c' a redirection status code?
		do
			inspect c
			when
				multiple_choices,
				moved_permanently,
				found,
				see_other,
				not_modified,
				use_proxy,
				switch_proxy,
				temp_redirect
			then
				Result := True
			else
				Result := False
			end
		ensure
			instance_free: class
		end

feature -- 4xx : Client Error

	bad_request: INTEGER 					= 400
	unauthorized: INTEGER 					= 401
	payment_required: INTEGER 				= 402
	forbidden: INTEGER 						= 403
	not_found: INTEGER 						= 404
	method_not_allowed: INTEGER 			= 405
	not_acceptable: INTEGER 				= 406
	proxy_auth_required: INTEGER 			= 407
	request_timeout: INTEGER 				= 408
	conflict: INTEGER 						= 409
	gone: INTEGER 							= 410
	length_required: INTEGER 				= 411
	precondition_failed: INTEGER 			= 412
	request_entity_too_large: INTEGER 		= 413
	request_uri_too_long: INTEGER 			= 414
	unsupported_media_type: INTEGER 		= 415
	request_range_not_satisfiable: INTEGER 	= 416
	expectation_failed: INTEGER 			= 417
	teapot: INTEGER							= 418
	authentication_timeout: INTEGER 		= 419
	enhance_your_calm: INTEGER 				= 420

	is_client_error_status (c: INTEGER): BOOLEAN
			-- Is `c' a client error status code?
		do
			inspect c
			when
				bad_request, unauthorized, payment_required, forbidden, not_found, method_not_allowed,
				not_acceptable, proxy_auth_required, request_timeout, conflict, gone,
				length_required, precondition_failed, request_entity_too_large, request_uri_too_long,
				unsupported_media_type, request_range_not_satisfiable, expectation_failed, teapot,
				authentication_timeout, enhance_your_calm
			then
				Result := True
			else
				Result := False
			end
		ensure
			instance_free: class
		end

feature -- 4xx : Client Error : WebDAV errors

	too_many_connections: INTEGER			= 421
	unprocessable_entity: INTEGER 			= 422
	locked: INTEGER 						= 423
	failed_dependency: INTEGER 				= 424
	unordered_collection: INTEGER 			= 425

	upgrade_required: INTEGER 				= 426
	no_response: INTEGER 					= 444
	retry_with: INTEGER 					= 449
	blocked_parental: INTEGER 				= 450
	client_closed_request: INTEGER 			= 499

	is_client_error_status_webdav (c: INTEGER): BOOLEAN
			-- Is `c' a client error status code for WebDAV?
		do
			inspect c
			when
				too_many_connections,
				unprocessable_entity,
				locked,
				failed_dependency,
				unordered_collection,
				upgrade_required,
				no_response,
				retry_with,
				blocked_parental,
				client_closed_request
			then
				Result := True
			else
				Result := False
			end
		ensure
			instance_free: class
		end

feature -- 5xx : Server Error

	internal_server_error: INTEGER			= 500
	not_implemented: INTEGER 				= 501
	bad_gateway: INTEGER 					= 502
	service_unavailable: INTEGER 			= 503
	gateway_timeout: INTEGER 				= 504
	http_version_not_supported: INTEGER 	= 505
	variant_also_negotiates: INTEGER 		= 506
	insufficient_storage: INTEGER 			= 507	-- WebDAV RFC 4918

	bandwidth_limit_exceeded: INTEGER		= 509
	not_extended: INTEGER 					= 510

	user_access_denied: INTEGER 			= 530

	is_server_error_status (c: INTEGER): BOOLEAN
			-- Is `c' a server error status code?
		do
			inspect c
			when
				internal_server_error,
				not_implemented,
				bad_gateway,
				service_unavailable,
				gateway_timeout,
				http_version_not_supported,
				variant_also_negotiates,
				insufficient_storage,
				bandwidth_limit_exceeded,
				not_extended,
				user_access_denied
			then
				Result := True
			else
				Result := False
			end
		ensure
			instance_free: class
		end

note
	copyright: "2011-2012, Jocelyn Fiat, Eiffel Software and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
	source: "[
			Eiffel Software
			5949 Hollister Ave., Goleta, CA 93117 USA
			Telephone 805-685-1006, Fax 805-685-6869
			Website http://www.eiffel.com
			Customer support http://support.eiffel.com
		]"
end
