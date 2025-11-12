note
	description: "[
			This content can be used to show modal information
			the rest of the page is blur
		]"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	CMS_MODAL_CONTENT_BLOCK

inherit
	CMS_CONTENT_BLOCK
		redefine
			to_html
		end

create
	make,
	make_raw

feature -- Access

	modal_div_id: detachable READABLE_STRING_8 assign set_modal_div_id
	close_link_html_text: detachable READABLE_STRING_8 assign set_close_link_html_text

feature -- Element change

	set_modal_div_id (v: like modal_div_id)
			-- Assign `modal_div_id` with `v`.
		require
			valid_v: v /= Void implies not v.is_whitespace
		do
			modal_div_id := v
		end

	set_close_link_html_text (v: like close_link_html_text)
			-- Assign `close_link_html_text` with `v`.
		do
			close_link_html_text := v
		end

feature -- Conversion

	to_html (a_theme: detachable CMS_THEME): READABLE_STRING_8
		local
			l_content: STRING_8
			l_modal_id: READABLE_STRING_8
			l_close_link_html_text: READABLE_STRING_8
		do
			if attached modal_div_id as v and then not v.is_whitespace then
				l_modal_id := v
			else
				l_modal_id := "{{blocname}}-modal"
			end
			create l_content.make_from_string (content)
			l_close_link_html_text := close_link_html_text
			if l_close_link_html_text = Void then
				l_close_link_html_text := "&#x2716;"
				l_content.prepend ("<a class=%"close-link%" style=%"position: relative; top: 0; right: 0%" id=%"{{blocname}}-close-link%" href=%"#%">"+ l_close_link_html_text +"</a>")
			else
				l_content.append ("<a class=%"close-link%" id=%"{{blocname}}-close-link%" href=%"#%">"+ l_close_link_html_text +"</a>")
			end

			l_content.append ("[
					<script>
						const style = document.createElement('style');
						style.textContent = `
						  #{{modal-id}} {
						    position: relative;
						    z-index: 2;
						  }
  						  #{{modal-id}} a.close-link {
						    display: block;
						    text-align: right;
						  }
						  #{{modal-id}} div.inner {
						    border: solid 1px #ddd;
						    border-radius: 0.5rem;
						    padding: 1rem;
						    margin: 1rem;
						  }
						  #{{modal-id}}:hover div.inner {
						    box-shadow: 0 1rem 1rem rgba(0,0,0,0.1);
							transition: transform 0.2s ease, box-shadow 0.2s ease, border 0.2s ease, margin-top: 0.2 ease, margin-bottom: 0.2 ease;
						    border: solid 1px #bbb;
						    margin-top: 0.9rem;
						    margin-bottom: 1.1rem;
						  }						  
						  #{{modal-id}}::before {
						    content: '';
						    position: fixed;
						    top: 0;
						    left: 0;
						    width: 100vw;
						    height: 100vh;
						    backdrop-filter: grayscale(50%) blur(5px);
						    z-index: -1;
						    pointer-events: none;
						  }
						  body.unmodaloverlay #{{modal-id}}::before {
						    display: none;
						  }
						`;
						document.head.appendChild(style);
						document.getElementById('{{modal-id}}').classList.add('modal-overlay');
						document.getElementById('{{blocname}}-close-link').addEventListener('click', function(e) {
							e.preventDefault();
							document.body.classList.add('unmodaloverlay');
							window.close()
							setTimeout(function() {
								if (window.history.length > 1) {
									window.history.back();
								} else {
									window.location.href = 'about:blank';
								}
							}, 100);
						});
					</script>
				]"
			)
			l_content.prepend ("<div id=%"{{blocname}}-modal%"><div class=%"inner%">")
			l_content.append ("</div></div>")
			l_content.replace_substring_all ("{{modal-id}}", "{{blocname}}-modal")
			l_content.replace_substring_all ("{{blocname}}", name)

			if attached format as f then
				Result := f.formatted_output (l_content)
			else
				Result := l_content
			end
		end

note
	copyright: "2011-2025, Jocelyn Fiat, Javier Velilla, Eiffel Software and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end
