note
	description: "Summary description for {CMS_DEFAULT_ROUTER_WEBAPI_RESPONSE}."
	date: "$Date$"
	revision: "$Revision$"

class
	CMS_DEFAULT_ROUTER_WEBAPI_RESPONSE

inherit
	JSON_WEBAPI_RESPONSE
		redefine
			execute
		end

create
	make_with_router

feature {NONE} -- Initialization

	make_with_router (req: WSF_REQUEST; res: WSF_RESPONSE; a_api: like api; a_router: like router)
			-- Initialize Current with request `req' and router `a_router'
			-- Initialize Current with request `req'
		do
			router := a_router
			make (req, res, a_api)
			request_method := req.request_method
			set_suggestion_only_method (True)

			if attached router.allowed_methods_for_request (request) as l_allowed_mtds and then not l_allowed_mtds.is_empty then
				suggested_methods := l_allowed_mtds
			end
			if attached req.query_parameter ("help") as p_help and then p_help.is_case_insensitive_equal ("yes") then
				is_help_mode := True
				if attached {WSF_STRING} req.query_parameter ("request_method") as p_request_method then
					set_request_method (p_request_method.url_encoded_value)
				end
				set_documentation_included (True)
			end
		end

feature -- Access

	router: WSF_ROUTER
			-- Associated router.

feature -- Settings

	documentation_included: BOOLEAN
			-- Include self-documentation from `router' in the response?

	suggestion_only_method: BOOLEAN
			-- Display only suggestion for `req' method ?

	request_method: READABLE_STRING_8
			-- Display only for `request_method`, it overrides the `request.request_method` value previously set.

	is_help_mode: BOOLEAN

feature -- Change

	set_documentation_included (b: BOOLEAN)
		do
			documentation_included := b
		end

	set_request_method (rm: detachable READABLE_STRING_8)
		do
			if rm = Void then
				request_method := request.request_method
			else
				request_method := rm
			end
		end

	set_suggestion_only_method (b: BOOLEAN)
			-- Set `suggestion_only_method' to `b'
		do
			suggestion_only_method := b
		ensure
			suggestion_only_method_set: suggestion_only_method = b
		end

feature -- Basic operation

	execute
			-- <Precursor/>
		do
			add_boolean_field ("error", True)
			if attached suggested_methods as l_suggested_methods then
					--| We give this precedence over 412 Precondition Failed or 404 Not Found,
					--| as we assume the existence of a handler for at least one method
					--| indicates existence of the resource. This is obviously not the
					--| case if the only method allowed is POST, but the handler ought
					--| to handle the 404 Not Found and 412 Precondition Failed cases in that case.
					--| Ditto for template URI handlers where not all template variable
					--| values map to existing resources.
				build_method_not_allowed_message (l_suggested_methods)
			elseif attached request.http_if_match as l_match and then l_match.same_string ("*") then
				build_precondition_failed_message
			else
					--| Other response codes are possible, such as 301 Moved permananently,
					--| 302 Found and 410 Gone. But these require handlers to implement,
					--| so no other code can be given at this point.
				build_not_found_message
			end
			check has_status_field: has_field ("status") end
			if not is_help_mode and suggested_methods = Void and attached request.request_method as l_red_method then
				if request.is_get_request_method then
					add_link ("help", "url", request.percent_encoded_path_info + "?help=yes&request_method=" + l_red_method)
				else
					add_link_with_description ("help", "url", request.percent_encoded_path_info + "?help=yes&request_method=" + l_red_method, "Use the same request method [" + l_red_method + "]")
				end
			end
			Precursor
		end

feature {NONE} -- Implementation

	suggested_methods: detachable WSF_REQUEST_METHODS

	build_precondition_failed_message
			-- Automatically generated response for 412 Precondition Failed response
		do
			set_status_code ({HTTP_STATUS_CODE}.precondition_failed)
			if attached {HTTP_STATUS_CODE_MESSAGES}.http_status_code_message (status_code) as st then
				add_string_field ("status", st)
			else
				add_string_field ("message", "Precondition failed")
			end
		end

	build_method_not_allowed_message (a_suggested_methods: WSF_REQUEST_METHODS)
		local
			vis: WSF_ROUTER_AGENT_ITERATOR
			jarr: JSON_ARRAY
		do
			set_status_code ({HTTP_STATUS_CODE}.method_not_allowed)
			if attached {HTTP_STATUS_CODE_MESSAGES}.http_status_code_message (status_code) as st then
				add_string_field ("status", st)
			else
				add_string_field ("message", "Method not allowed")
			end
			add_iterator_field ("suggested_methods", a_suggested_methods)
			if documentation_included then
				create jarr.make (10)
				create vis

				vis.on_item_actions.extend (agent (i: WSF_ROUTER_ITEM; a_json_items: JSON_ARRAY)
						local
							l_is_hidden: BOOLEAN
							jobj: JSON_OBJECT
							j_methods, j_descs: JSON_ARRAY
							l_doc: WSF_ROUTER_MAPPING_DOCUMENTATION
						do
							-- Keep only mapping for the request's method
							if
								not attached i.request_methods as l_methods or else
								l_methods.has (request_method)
							then
								if attached {WSF_SELF_DOCUMENTED_ROUTER_MAPPING} i.mapping as l_doc_mapping then
									l_doc := l_doc_mapping.documentation (i.request_methods)
									l_is_hidden := l_doc.is_hidden
								end
								if not l_is_hidden then
									create jobj.make_with_capacity (2)
									jobj.put_string (i.mapping.associated_resource, "resource")
									create j_methods.make_empty
									if attached i.request_methods as mtds then
										across
											mtds as md
										loop
											j_methods.extend (create {JSON_STRING}.make_from_string_general (md))
										end
									else
										j_methods.extend (create {JSON_STRING}.make_from_string_general ("*"))
									end
									if l_doc /= Void then
										if attached l_doc.descriptions as descs then
											create j_descs.make (descs.count)
											across
												descs as d
											loop
												if not d.is_whitespace then
													j_descs.extend (create {JSON_STRING}.make_from_string_general (d))
												end
											end
											if not j_descs.is_empty then
												jobj.put (j_descs, "descriptions")
											end
										end
									end
									jobj.put (j_methods, "methods")
									a_json_items.extend (jobj)
								end
							end
						end (?, jarr)
					)
				vis.process_router (router)
				resource.put (jarr, "suggestions")
			end
		end

	build_not_found_message
		local
			vis: WSF_ROUTER_AGENT_ITERATOR
			l_method: detachable READABLE_STRING_8
			jarr: JSON_ARRAY
		do
			set_status_code ({HTTP_STATUS_CODE}.not_found)
			if attached {HTTP_STATUS_CODE_MESSAGES}.http_status_code_message (status_code) as st then
				add_string_field ("status", st)
			else
				add_string_field ("message", "Not Found")
			end
			if documentation_included then
				create jarr.make (10)
				create vis

				if suggestion_only_method then
					l_method := request_method
				end
				vis.on_item_actions.extend (agent (i: WSF_ROUTER_ITEM; m: detachable READABLE_STRING_8; a_json_items: JSON_ARRAY)
						local
							l_is_hidden: BOOLEAN
							ok: BOOLEAN
							jobj: JSON_OBJECT
							j_methods, j_descs: JSON_ARRAY
							l_doc: WSF_ROUTER_MAPPING_DOCUMENTATION
						do
							if attached {WSF_SELF_DOCUMENTED_ROUTER_MAPPING} i.mapping as l_doc_mapping then
								l_doc := l_doc_mapping.documentation (i.request_methods)
								l_is_hidden := l_doc.is_hidden
							end
							if not l_is_hidden then
								ok := True
								create jobj.make_with_capacity (2)
								jobj.put_string (i.mapping.associated_resource, "resource")
								create j_methods.make_empty
								if attached i.request_methods as mtds then
									ok := False
									across
										mtds as md
									loop
										if m = Void or else m.is_case_insensitive_equal (md) then
											ok := True
										end
										j_methods.extend (create {JSON_STRING}.make_from_string_general (md))
									end
								else
									j_methods.extend (create {JSON_STRING}.make_from_string_general ("*"))
								end
								if ok then
									if l_doc /= Void then
										if attached l_doc.descriptions as descs then
											create j_descs.make (descs.count)
											across
												descs as d
											loop
												if not d.is_whitespace then
													j_descs.extend (create {JSON_STRING}.make_from_string_general (d))
												end
											end
											if not j_descs.is_empty then
												jobj.put (j_descs, "descriptions")
											end
										end
									end
									jobj.put (j_methods, "methods")
									a_json_items.extend (jobj)
								end
							end
						end (?, l_method, jarr))
				vis.process_router (router)
				resource.put (jarr, "suggestions")
			end
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

